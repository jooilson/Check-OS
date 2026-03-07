# PLANO DE CORREÇÃO DE DADOS - CheckOS

## Objetivo

Corrigir as vulnerabilidades de isolamento de dados para garantir que:
- Um usuário NUNCA possa visualizar dados de outro usuário ou empresa
- O sistema funcione corretamente no modelo multiempresa (multi-tenant)
- Queries Firestore sempre filtrem por `companyId`

---

## Fase 1: Correções nos Repositories (Alta Prioridade)

### 1.1 Corrigir OsRepository

**Arquivo**: `lib/data/repositories/os_repository.dart`

**Mudanças necessárias**:

```dart
// ANTES (VULNERÁVEL)
Stream<List<OsModel>> getOs({String? companyId}) {
  Query query = _firestore.collection('os');
  if (companyId != null) {  // ← Opcional!
    query = query.where('companyId', isEqualTo: companyId);
  }
  return query.snapshots();
}

// DEPOIS (SEGURO)
Stream<List<OsModel>> getOs({required String companyId}) {  // ← Obrigatório!
  return _firestore
      .collection('os')
      .where('companyId', isEqualTo: companyId)
      .snapshots();
}
```

**Arquivos a alterar**:
- `getOs()` - linha ~44
- `getOsPaginated()` - linha ~60
- `getOsList()` - linha ~89
- `deleteAllOs()` - linha ~102

---

### 1.2 Corrigir DiarioRepository

**Arquivo**: `lib/data/repositories/diario_repository.dart`

**Mudanças necessárias**:
- Todos os métodos já têm companyId como parâmetro, mas devem torná-lo **obrigatório**
- Adicionar validação que lança exceção se companyId for nulo/vazio

```dart
// ANTES
Stream<List<DiarioModel>> getDiariosStream(String companyId, String osId)

// DEPOIS - adicionar validação
Stream<List<DiarioModel>> getDiariosStream(String companyId, String osId) {
  if (companyId.isEmpty) {
    throw ArgumentError('companyId é obrigatório para buscar diários');
  }
  // ... resto do código
}
```

---

### 1.3 Corrigir EmployeeRepository

**Arquivo**: `lib/data/repositories/employee_repository.dart`

**Mudanças necessárias**:

```dart
// ANTES (VULNERÁVEL)
Stream<List<EmployeeModel>> getEmployeesStream({String? companyId}) {
  Query query = _employeeCollection.orderBy('name');
  if (companyId != null) {  // ← Opcional!
    query = _employeeCollection.where('companyId', isEqualTo: companyId).orderBy('name');
  }
  return query.snapshots();
}

// DEPOIS (SEGURO)
Stream<List<EmployeeModel>> getEmployeesStream({required String companyId}) {
  if (companyId.isEmpty) {
    throw ArgumentError('companyId é obrigatório');
  }
  return _employeeCollection
      .where('companyId', isEqualTo: companyId)
      .where('isActive', isEqualTo: true)
      .orderBy('name')
      .snapshots();
}
```

**Arquivos a alterar**:
- `getEmployeesStream()` - linha ~12
- `getEmployeesList()` - linha ~24
- `getActiveEmployeesList()` - linha ~41

---

## Fase 2: Correções nas Regras de Segurança

### 2.1 Corrigir firestore.rules

**Arquivo**: `firestore.rules`

**Mudanças necessárias**:

```javascript
// ANTES (VULNERÁVEL)
match /companies/{companyId} {
  allow read: if isAuthenticated();  // ← Qualquer usuário logado!
}

// DEPOIS (SEGURO)
match /companies/{companyId} {
  allow read: if belongsToCompany(companyId);  // ← Apenas da mesma empresa!
}
```

**Regras completas corrigidas**:

```javascript
// === COLLECTION: companies ===
match /companies/{companyId} {
  // Apenas usuários da empresa podem ler
  allow read: if belongsToCompany(companyId);
  
  // Owner e Admin podem criar empresa
  allow create: if isAuthenticated() && request.resource.data.ownerId == request.auth.uid;
  
  // Owner e Admin podem editar
  allow update: if isAdmin(companyId);
  
  // Apenas Owner pode excluir
  allow delete: if isOwner(companyId);
}
```

**Também corrigir leitura de OS e diários**:

```javascript
// === COLLECTION: ordens_servico ===
match /ordens_servico/{osId} {
  allow read: if request.resource.data.companyId != null && 
               belongsToCompany(request.resource.data.companyId);
  // ...
}
```

---

## Fase 3: Validação no Auth Service

### 3.1 Adicionar validação transacional

**Arquivo**: `lib/services/firebase/auth_service.dart`

**Melhoria recomendada**: Usar `runTransaction` para garantir atomicidade:

```dart
Future<UserCredential> createAccountWithCompany({...}) async {
  return await _firestore.runTransaction((transaction) async {
    // 1. Cria usuário no Firebase Auth (fora da transação)
    UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(...);
    final uid = userCredential.user!.uid;
    
    // 2. Cria empresa na transação
    final companyRef = _firestore.collection('companies').doc();
    transaction.set(companyRef, {...});
    
    // 3. Cria usuário na transação
    final userRef = _firestore.collection('users').doc(uid);
    transaction.set(userRef, {...});
    
    return userCredential;
  });
}
```

---

## Fase 4: Estrutura Correta de Banco

### 4.1 Estrutura de Dados Recomendada

Todas as coleções DEVEM conter os seguintes campos obrigatórios:

```
companies/{companyId}
├── id                    # UUID
├── name                  # Nome fantasia
├── cnpj                  # CNPJ (único)
├── ownerId               # UID do dono (obrigatório)
├── plan                  # free/basic/premium
├── isActive              # true
├── createdAt             # timestamp
└── updatedAt             # timestamp

users/{uid}
├── id                    # Firebase Auth UID
├── email                 # Email único
├── name                  # Nome
├── companyId             # FK para companies (OBRIGATÓRIO)
├── role                  # owner/admin/user
├── isOwner               # true/false
├── isActive              # true
├── createdAt             # timestamp
└── updatedAt             # timestamp

employees/{uid}
├── id                    # Firebase Auth UID
├── name                  # Nome
├── email                 # Email
├── role                  # owner/admin/user
├── phone                 # Telefone
├── cpf                   # CPF
├── companyId             # FK para companies (OBRIGATÓRIO)
├── isActive              # true
├── createdAt             # timestamp
└── updatedAt             # timestamp

os/{osId}
├── numeroOs              # Número sequencial
├── nomeCliente           # Nome do cliente
├── servico               # Serviço
├── relatoCliente         # Relato
├── responsavel           # UID do responsável
├── funcionarios          # Array de UIDs
├── kmInicial             # KM inicial
├── kmFinal               # KM final
├── osfinalizado          # bool
├── pendente              # bool
├── companyId             # FK para companies (OBRIGATÓRIO)
├── createdBy             # UID de quem criou
├── createdAt             # timestamp
└── updatedAt             # timestamp

diarios/{diarioId}
├── osId                  # FK para OS
├── numeroOs              # Número da OS
├── numeroDiario          # Número do diário
├── nomeCliente           # Nome do cliente
├── servico               # Serviço
├── data                  # Data
├── companyId             # FK para companies (OBRIGATÓRIO)
├── createdBy             # UID de quem criou
├── createdAt             # timestamp
└── updatedAt             # timestamp
```

---

## Fase 5: Lista de Arquivos a Alterar

| # | Arquivo | Ação | Prioridade |
|---|---------|------|------------|
| 1 | `lib/data/repositories/os_repository.dart` | companyId obrigatório | 🔴 ALTA |
| 2 | `lib/data/repositories/diario_repository.dart` | Adicionar validação | 🔴 ALTA |
| 3 | `lib/data/repositories/employee_repository.dart` | companyId obrigatório | 🔴 ALTA |
| 4 | `firestore.rules` | Corrigir regras | 🔴 ALTA |
| 5 | `lib/services/firebase/auth_service.dart` | Adicionar transação | 🟡 MÉDIA |

---

## Fase 6: Plano de Migração de Dados (se necessário)

### Verificar dados existentes

Execute no Firebase Console ou shell:

```javascript
// Verificar OS sem companyId
db.collection('os').where('companyId', '==', null).get()

// Verificar diários sem companyId  
db.collection('diarios').where('companyId', '==', null).get()

// Verificar usuários sem companyId
db.collection('users').where('companyId', '==', null).get()
```

### Script de correção (se necessário)

```javascript
// Script para adicionar companyId a documentos órfãos
// Execute apenas se identificar dados órfãos

const osSemCompany = await db.collection('os').where('companyId', '==', null).get();

osSemCompany.forEach(async (doc) => {
  // Tentar inferir companyId baseado em outros dados
  // ou marcar para revisão manual
  await doc.ref.update({
    'companyId': 'PENDENTE_REVISAO',
    'needsReview': true
  });
});
```

---

## Checklist de Implementação

- [ ] 1. Modificar OsRepository para companyId obrigatório
- [ ] 2. Modificar DiarioRepository com validação
- [ ] 3. Modificar EmployeeRepository para companyId obrigatório
- [ ] 4. Corrigir firestore.rules - companies
- [ ] 5. Corrigir firestore.rules - os
- [ ] 6. Corrigir firestore.rules - diarios
- [ ] 7. Testar fluxo de login com novo usuário
- [ ] 8. Verificar se OS de outra empresa não aparece
- [ ] 9. Verificar dados no Console Firebase

---

## Teste de Validação

Após implementar as correções:

1. **Criar nova conta** com email teste2@exemplo.com
2. **Verificar** que NÃO aparecem OS da conta teste1@exemplo.com
3. **Acessar Console Firebase** e confirmar que documents têm companyId correto
4. **Testar regras de segurança** tentando acessar dados de outra empresa (deve bloquear)

---

*Plano gerado em: $(date)*
*Analista: BlackBoxAI Security*

