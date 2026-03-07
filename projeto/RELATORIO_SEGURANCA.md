# RELATÓRIO DE VULNERABILIDADES - CheckOS

## Problema Identificado

**Sintoma**: Ao criar nova conta e entrar no aplicativo, o usuário visualiza Ordens de Serviço (OS) de outros usuários/empresas.

**Causa Raiz**: Falha no isolamento de dados entre empresas (multi-tenant). O sistema permite consultas sem filtro adequado por `companyId`.

---

## Vulnerabilidades Identificadas

### 🔴 CRÍTICO #1: Queries Firestore sem companyId obrigatório

**Arquivo**: `lib/data/repositories/os_repository.dart`

**Problema**: Os métodos de consulta aceitam `companyId` como **parâmetro opcional**, permitindo consultas globais quando não fornecido.

```dart
// LINHA 44-54 - Stream sem filtro obrigatório
Stream<List<OsModel>> getOs({String? companyId}) {
  Query query = _firestore.collection('os');
  
  // Filtrar por companyId se fornecido  ← PROBLEMA AQUI!
  if (companyId != null) {
    query = query.where('companyId', isEqualTo: companyId);
  }
  // SE companyId for null → RETORNA TODAS AS OS!
```

**Linhas afetadas**: 44-54, 60-85, 89-102

**Risco**: Qualquer desenvolvedor que esquecer de passar o companyId expoe TODOS os dados de OS.

---

### 🔴 CRÍTICO #2: DiarioRepository - companyId opcional em métodos

**Arquivo**: `lib/data/repositories/diario_repository.dart`

**Problema**: Métodos como `getDiariosStream`, `getDiarios`, `getAllDiarios` podem ser chamados sem companyId.

```dart
// Mesmo tendo companyId como parâmetro, não é obrigatório
Stream<List<DiarioModel>> getDiariosStream(String companyId, String osId)
Future<List<DiarioModel>> getDiarios(String companyId, String osId)
```

**Risco**: Exposição de diários de todas as empresas.

---

### 🔴 CRÍTICO #3: EmployeeRepository - companyId opcional

**Arquivo**: `lib/data/repositories/employee_repository.dart`

**Problema**: Queries podem ser executadas sem companyId.

```dart
// LINHA 12-21 - Stream sem filtro obrigatório
Stream<List<EmployeeModel>> getEmployeesStream({String? companyId}) {
  Query query = _employeeCollection.orderBy('name');
  
  if (companyId != null) {  // ← PROBLEMA
    query = _employeeCollection.where('companyId', isEqualTo: companyId).orderBy('name');
  }
  // SE não passar → RETORNA TODOS OS FUNCIONÁRIOS!
```

**Linhas afetadas**: 12-21, 24-38, 41-53

**Risco**: Exposição de dados de funcionários de todas as empresas.

---

### 🟠 ALTO #4: Regras de Segurança Firestore - Leitura irrestrita de companies

**Arquivo**: `firestore.rules`

**Problema**: Qualquer usuário autenticado pode ler TODAS as empresas.

```javascript
// LINHA 35-38
match /companies/{companyId} {
  allow read: if isAuthenticated();  ← MUITO INSEGURO!
}
```

**Risco**: Qualquer usuário logado pode ver dados de todas as empresas (nome, CNPJ, telefone, etc).

---

### 🟠 ALTO #5: Regras de Segurança - Leitura de OS com resource.data

**Arquivo**: `firestore.rules`

**Problema**: A regra usa `resource.data.companyId`, que só funciona se o documento TIVER o campo companyId. Se não tiver, a verificação falha e pode permitir acesso.

```javascript
// LINHA 72-77
match /ordens_servico/{osId} {
  allow read: if belongsToCompany(resource.data.companyId);
  // SE companyId for null → belongsToCompany retorna false (correto)
  // MAS SE O CAMPO NÃO EXISTIR NO DOC → erro de acesso pode ocorrer
}
```

**Recomendação**: Usar `request.resource.data` para validar na criação e `resource.data` na leitura.

---

### 🟡 MÉDIO #6: Possível inconsistência na criação de dados

**Arquivo**: `lib/services/firebase/auth_service.dart`

**Problema**: O fluxo de criação parece correto, mas não há validação transacional.

```dart
// LINHA 32-60 - createAccountWithCompany
// 1. Cria usuário no Auth
// 2. Cria empresa no Firestore
// 3. Cria usuário no Firestore
// SE步骤 2 ou 3 falhar → dados inconsistentes!
```

**Risco**: Dados órfãos (usuário sem empresa ou empresa sem dono).

---

### 🟡 MÉDIO #7: Fallback entre collections pode expor dados

**Arquivo**: `lib/presentation/pages/auth/auth_wrapper.dart`

**Problema**: Se employee não for encontrado em `employees`, busca em `users`. Se ambos não existirem, o fluxo redireciona para login, mas o fallback pode causar confusão.

```dart
// LINHA 40-58
var employee = await employeeRepo.getEmployeeById(uid);
// Fallback: se não encontrar em employees, busca em users
if (employee == null) {
  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();
  // ...
}
```

**Risco**: Baixo - o fluxo verifica companyId após fallback.

---

### ✅ PONTOS CORRETOS

1. **EmployeeProvider**: Usa companyId obrigatório e inicializa corretamente
2. **DiarioRepository.addDiario**: companyId é parâmetro obrigatório
3. **Fluxo de criação de empresa**: Cria Auth → Company → User com companyId
4. **Modelos de dados**: Todos têm campo companyId

---

## Resumo dos Arquivos Afetados

| Arquivo | Linhas | Severidade | Tipo |
|---------|--------|------------|------|
| `lib/data/repositories/os_repository.dart` | 44-102 | 🔴 CRÍTICO | Query sem filtro |
| `lib/data/repositories/diario_repository.dart` | 50-150 | 🔴 CRÍTICO | Query sem filtro |
| `lib/data/repositories/employee_repository.dart` | 12-53 | 🔴 CRÍTICO | Query sem filtro |
| `firestore.rules` | 35-38 | 🟠 ALTO | Regra insegura |
| `firestore.rules` | 72-77 | 🟠 ALTO | Regra vulnerável |
| `lib/services/firebase/auth_service.dart` | 32-60 | 🟡 MÉDIO | Falta transação |

---

## Análise da Causa Raiz

O problema relatado ("usuário vê OS de outros") ocorre porque:

1. **Ou** o código cliente está chamando `getOsList()` sem passar `companyId`
2. **Ou** existe algum fluxo onde o `companyId` está sendo passado como `null`
3. **Ou** as regras de segurança do Firestore não estão bloqueando acesso inadequado

---

## Recomendação Imediata

1. **Modificar todos os repositories** para tornar `companyId` um parâmetro **obrigatório** (não opcional)
2. **Corrigir firestore.rules** para permitir leitura de companies apenas para usuários da mesma empresa
3. **Adicionar validação** que lança exceção se `companyId` for nulo

---

*Relatório gerado em: $(date)*
*Analista: BlackBoxAI Security*

