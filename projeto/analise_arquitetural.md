# Análise Arquitetural - CheckOS

## Visão Geral

Este documento identifica pontos fracos, riscos de escalabilidade, acoplamento alto e possíveis bugs estruturais do projeto CheckOS.

---

## 1. PONTOS FRACOS DA ARQUITETURA

### 1.1 Duplicação de Dados

**Problema**: Users e Employees contêm dados semelhantes em coleções separadas.

```
users                    employees
├── id (uid)            ├── id (uid)
├── name                ├── name
├── email               ├── email
├── companyId           ├── companyId
├── role                ├── role
└── ...                 ├── phone
                        ├── cpf
                        └── ...
```

**Impacto**:
- Sincronização manual obrigatória
- Risco de inconsistência
- Duplicação de armazenamento

**Recomendação**: Unificar em uma única coleção.

---

### 1.2 companyId Nullable

**Problema**: O campo `companyId` pode ser null em UserModel.

```dart
// Em user_model.dart
String? companyId;  // Nullable!

// Verificações distribuídas pelo código
if (employee.companyId == null) {
  // mostra erro
}
```

**Impacto**:
- NullPointerException em várias partes
- Dados órfãos
- Risco de segurança (acesso a dados sem empresa)

**Recomendação**: companyId deveria ser obrigatório, não anulável.

---

### 1.3 Falta de Interface nos Repositories

**Problema**: Apenas UserRepository tem interface.

```
company_repository.dart     → Sem interface
employee_repository.dart    → Sem interface
diario_repository.dart      → Sem interface
os_repository.dart          → Sem interface
user_repository_impl.dart   → USA interface ✓
```

**Impacto**:
- Difícil testar unitariamente
- Acoplamento direto com implementação
- Não permite trocar Firestore por API REST

**Recomendação**: Criar interface para todos os repositories.

---

### 1.4 Instanciação Direta

**Problema**: Services e Repositories são instanciados diretamente nas classes.

```dart
// Em várias pages
class AlgumaPage extends StatelessWidget {
  final AuthService _authService = AuthService();  // Ruim!
  final EmployeeRepository _repo = EmployeeRepository();
}
```

**Impacto**:
- Acoplamento alto
- Difícil alterar implementação
- Impossível testar com mocks

**Recomendação**: Usar injeção de dependência (get_it já está nas dependências).

---

### 1.5 Falta de tratamento de erros

**Problema**:try-catch raramente usado, erros não são tratados adequadamente.

```dart
// Exemplo comum no código
await osRepository.addOs(os);
// Sem try-catch!
```

**Impacto**:
- App pode crashar silenciosamente
- Usuário não sabe o que aconteceu
- Difícil debugar

---

## 2. RISCOS DE ESCALABILIDADE

### 2.1 Writes por Segundo

**Risco**: Firestore tem limite de 1 write/segundo por documento.

**Cenário de risco**:
- Múltiplos usuários editando mesma OS
- Importação em massa de dados
- Logs em tempo real

**Mitigação atual**: Nenhuma.

**Recomendação**: Implementar debounce e batch writes.

---

### 2.2 Tamanho de Documento

**Risco**: OsModel pode crescer muito com imagens (URLs) e array de funcionários.

```
OsModel
├── imagens: List<String>  ← pode ter muitas URLs
├── funcionarios: List<String>
└── ...
```

**Limite Firestore**: 1 MB por documento.

**Mitigação**: Armazenar imagens no Storage, não no documento.

---

### 2.3 Queries Complexas

**Risco**: Queries com múltiplos filtros podem ficar lentas.

```dart
// Exemplo de query complexa
.where('companyId', isEqualTo: companyId)
.where('status', isEqualTo: 'pendente')
.orderBy('createdAt', descending: true)
```

**Solução**: Criar índices compostos no Firestore.

---

### 2.4 Sem Cache

**Risco**: A cada abertura de tela, dados são buscados do Firestore.

**Impacto**:
- Lento para o usuário
- Custo alto de leitura
- Funciona offline? Não

**Recomendação**: Implementar cache local com SharedPreferences ou Hive.

---

### 2.5 Sem Paginação em Algumas Telas

**Risco**: ListaPage pode carregar todos os dados de uma vez.

**Impacto**:
- Memória esgota com muitos dados
- Lento para carregar
- Custo alto

**Solução parcial**: getOsPaginated() existe mas não é usado everywhere.

---

## 3. ACOPLAMENTO ALTO

### 3.1 Pages ↔ Services

**Problema**: Pages dependem diretamente de Services.

```
NovaOsPage
  ├── OsRepository (diretamente instanciado)
  ├── EmployeeRepository
  ├── LogRepository
  └── AuthService
```

**Melhoria**: Injeção de dependência.

---

### 3.2 AuthService Acoplado

**Problema**: AuthService faz de tudo.

```dart
class AuthService {
  ├── FirebaseAuth
  ├── UserRepositoryImpl
  ├── CompanyRepository
  └── Lógica de negócio
}
```

**Solução**: Separar responsabilidades.

---

### 3.3 Firestore Duro no Código

**Problema**: Repositories têm FirebaseFirestore hardcoded.

```dart
class AlgumRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;  // Duro!
}
```

**Solução**: Injetar via construtor.

---

## 4. DUPLICAÇÃO DE LÓGICA

### 4.1 Validação de companyId

**Duplicação**: Verificação de companyId分散ada no código.

```dart
// Em AuthWrapper
if (user.companyId == null) ...

// Em HomePage
if (employee.companyId == null) ...

// Em ListaPage
if (employee.companyId == null) ...

// Em mais 10+ lugares
```

**Solução**: Criar service helper.

---

### 4.2 Tratamento de Erros

**Duplicação**: Mesmo padrão de erro repetido.

```dart
// Em vários lugares
catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Erro: $e')),
  );
}
```

**Solução**: Criar utilitário de erros.

---

### 4.3 Conversion Models

**Duplicação**: fromFirestore/toFirestore repetido em cada Model.

**Solução**: Gerar automaticamente ou usar json_serializable.

---

## 5. POSSÍVEIS BUGS ESTRUTURAIS

### 5.1 NullPointerException em AuthWrapper

**Cenário**: Usuário existe no Firebase Auth mas não tem Employee.

```dart
// Em AuthWrapper
employee = EmployeeModel.fromFirestore(doc);
// Se doc não existe → null!
// Depois: employee.companyId → NullPointerException
```

**Bug**: Não há verificação se employee é null.

---

### 5.2 Condição de Corrida (Race Condition)

**Cenário**: Dois admins criam funcionário simultaneamente.

```
Admin 1: Cria func@empresa.com
Admin 2: Cria func@empresa.com (mesmo email)
```

**Bug**: Firebase Auth pode aceitar, mas pode falhar silenciosamente.

---

### 5.3 Dados Órfãos ao Deletar Empresa

**Cenário**: Deletar empresa não deleta OS, diários, etc.

```dart
// CompanyRepository
deleteCompany(companyId);
// Não deleta:
//   - users da empresa
//   - employees
//   - os
//   - diarios
```

**Bug**: Dados órfãos no Firestore.

---

### 5.4 Perda de Dados ao Atualizar

**Cenário**: updateOs() pode sobrescrever campos não enviados.

```dart
// Se enviar apenas campos modificados,
// campos antigos podem ser perdidos
```

**Bug**: Não usa merge corretamente?

---

### 5.5 Sessão Persistente em Ambiente Compartilhado

**Cenário**: Usuário faz logout mas dados SharedPreferences persistem.

**Bug**: Dados de um usuário podem ser visíveis para outro.

---

## 6. FALTA DE VALIDAÇÃO SERVER-SIDE

### 6.1 Regras de Firestore Básicas

**Problema**: Regras permitem muito acesso.

```javascript
// firestore.rules (atual)
match /os/{osId} {
  allow read, write: if request.auth != null;
  // QUALQUER USUÁRIO AUTENTICADO PODE LER/TUDO!
}
```

**Risco**: Usuário pode acessar dados de outra empresa.

---

### 6.2 Sem Validação de CNPJ

**Problema**: CNPJ não é validado server-side.

**Risco**: CNPJ inválido pode ser salvo.

---

### 6.3 Sem Verificação de Permissões em Writes

**Problema**: Qualquer usuário pode criar OS.

**Risco**: Usuário inativo ainda pode criar dados.

---

## 7. ARQUITETURA INCOMPLETA

### 7.1 domain/usecases/ Não Usado

**Problema**: Pasta existe mas está vazia.

```
lib/domain/usecases/
└── user/
    └── get_user_details.dart  ← Existe mas não é usado!
```

**Impacto**: Camada de domínio não está sendo utilizada.

---

### 7.2 data/datasources/ Vazio

**Problema**: Estrutura de datasources existe mas não tem implementação.

```
lib/data/datasources/
├── local/    ← vazio
└── remote/   ← vazio
```

**Impacto**: Não há abstração de fonte de dados.

---

### 7.3 core/context/ Subutilizado

**Problema**: AuthContext existe mas não é usado.

```
lib/core/context/
├── auth_context.dart    ← Definido mas não usado?
└── employee_context.dart ← Usado parcialmente
```

---

## 8. FALTA DE OBSERVABILIDADE

### 8.1 Sem Analytics

**Problema**: Não há Google Analytics ou similar.

**Impacto**: Não sabe como usuários usam o app.

---

### 8.2 Sem Crashlytics

**Problema**: Não há Firebase Crashlytics.

**Impacto**: Não sabe quando app crasha.

---

### 8.3 Logs Limitados

**Problema**: LogRepository existe mas logs não são usados efetivamente.

**Impacto**: Difícil auditar ações.

---

## 9. SECURITY CONCERNS

### 9.1 Senhas em Texto

**Problema**: Ao criar funcionário, senha temporária pode ser enviada.

```dart
// Em AuthService.registerEmployee
password: 'SenhaTemporaria123',  // Senha hardcoded?
```

**Risco**: Segurança comprometida.

---

### 9.2 URLs de Imagens Públicas

**Problema**: Imagens no Storage podem ter URLs públicas.

**Risco**: Qualquer um com URL pode acessar imagens.

---

### 9.3 App Check Desabilitado em Desenvolvimento

**Problema**: App Check está desabilitado no código.

```dart
// Em main.dart
// App Check desabilitado para desenvolvimento
```

**Risco**: App vulnerável a ataques automatizados em produção.

---

## 10. RESUMO DE PROBLEMAS

| # | Problema | Severidade | Impacto |
|---|----------|------------|---------|
| 1 | Duplicação users/employees | Alta | Inconsistência |
| 2 | companyId nullable | Alta | NullPointer |
| 3 | Sem interfaces | Média | Testabilidade |
| 4 | Instanciação direta | Média | Acoplamento |
| 5 | Regras Firestore fracas | Alta | Segurança |
| 6 | Sem cache | Média | Performance |
| 7 | domain/usecases não usado | Baixa | Arquitetura |
| 8 | Sem tratamento de erros | Alta | Estabilidade |
| 9 | Dados órfãos | Alta | Integridade |
| 10 | Sem observabilidade | Média | Manutenção |

---

## 11. PRIORIDADE DE CORREÇÕES

### Alta Prioridade
1. Corrigir companyId nullable
2. Implementar validação server-side
3. Fortalecer regras Firestore
4. Tratar erros adequadamente

### Média Prioridade
5. Injeção de dependência
6. Criar interfaces
7. Implementar cache
8. Unificar users/employees

### Baixa Prioridade
9. Adicionar analytics
10. Usar domain/usecases
11. Separar datasources

