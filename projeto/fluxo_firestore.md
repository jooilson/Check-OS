# Fluxo de Dados Firestore - CheckOS

## Visão Geral

O CheckOS utiliza Firebase Firestore como banco de dados principal. Este documento detalha todas as coleções, estruturas de dados e fluxos de operação.

---

## 1. COLEÇÕES DO FIRESTORE

### 1.1 Estrutura de Coleções

```
firestore
│
├── users                    # Usuários do sistema
│   └── {uid}
│       ├── email
│       ├── name
│       ├── companyId
│       ├── role
│       ├── isOwner
│       ├── isActive
│       ├── createdAt
│       └── updatedAt
│
├── companies               # Empresas cadastradas
│   └── {companyId}
│       ├── name
│       ├── cnpj
│       ├── phone
│       ├── address
│       ├── email
│       ├── logoUrl
│       ├── plan
│       ├── isActive
│       ├── ownerId
│       ├── createdAt
│       └── updatedAt
│
├── employees               # Funcionários
│   └── {uid}
│       ├── name
│       ├── email
│       ├── role
│       ├── phone
│       ├── cpf
│       ├── companyId
│       ├── isActive
│       ├── createdAt
│       └── updatedAt
│
├── os                      # Ordens de Serviço
│   └── {osId}
│       ├── numeroOs
│       ├── nomeCliente
│       ├── servico
│       ├── relatoCliente
│       ├── responsavel
│       ├── temPedido
│       ├── numeroPedido
│       ├── funcionarios        # Array de UIDs
│       ├── kmInicial
│       ├── kmFinal
│       ├── horaInicio
│       ├── intervaloInicio
│       ├── intervaloFim
│       ├── horaTermino
│       ├── osfinalizado
│       ├── garantia
│       ├── pendente
│       ├── pendenteDescricao
│       ├── relatoTecnico
│       ├── assinatura
│       ├── imagens            # URLs
│       ├── totalKm
│       ├── companyId
│       ├── createdAt
│       └── updatedAt
│
├── diarios                 # Diários de Bordo
│   └── {diarioId}
│       ├── osId
│       ├── numeroOs
│       ├── numeroDiario
│       ├── nomeCliente
│       ├── servico
│       ├── data
│       ├── ... (campos similares a OS)
│       ├── companyId
│       ├── createdAt
│       └── updatedAt
│
└── logs                    # Auditoria
    └── {logId}
        ├── action
        ├── entityType
        ├── entityId
        ├── userId
        ├── userName
        ├── companyId
        ├── details
        └── timestamp
```

---

## 2. CRIAÇÃO DE DADOS

### 2.1 Criar Empresa

```dart
// CompanyRepository.createCompany()
firestore.collection('companies').doc(companyId).set({
  'name': 'Nome da Empresa',
  'ownerId': uid,
  'cnpj': '00.000.000/0001-00',
  'plan': 'free',
  'isActive': true,
  'createdAt': FieldValue.serverTimestamp(),
  'updatedAt': FieldValue.serverTimestamp(),
})
```

### 2.2 Criar Usuário

```dart
// UserRepository.createUser()
firestore.collection('users').doc(uid).set({
  'email': 'email@empresa.com',
  'name': 'Nome Usuário',
  'companyId': companyId,
  'role': 'owner', // ou 'admin', 'user'
  'isOwner': true,
  'isActive': true,
  'createdAt': FieldValue.serverTimestamp(),
  'updatedAt': FieldValue.serverTimestamp(),
})
```

### 2.3 Criar Funcionário

```dart
// EmployeeRepository.addEmployee()
firestore.collection('employees').doc(uid).set({
  'name': 'Nome Funcionário',
  'email': 'func@empresa.com',
  'role': 'user',
  'phone': '(11) 99999-9999',
  'cpf': '000.000.000-00',
  'companyId': companyId,
  'isActive': true,
  'createdAt': FieldValue.serverTimestamp(),
  'updatedAt': FieldValue.serverTimestamp(),
})
```

### 2.4 Criar OS

```dart
// OsRepository.addOs()
firestore.collection('os').doc(osId).set({
  'numeroOs': 1,
  'nomeCliente': 'Cliente XPTO',
  'servico': 'Instalação',
  'companyId': companyId,
  'createdAt': FieldValue.serverTimestamp(),
  'updatedAt': FieldValue.serverTimestamp(),
})
```

### 2.5 Criar Diário

```dart
// DiarioRepository.addDiario()
firestore.collection('diarios').doc(diarioId).set({
  'osId': osId,
  'numeroOs': os.numeroOs,
  'data': DateTime.now(),
  'companyId': companyId,
  'createdAt': FieldValue.serverTimestamp(),
  'updatedAt': FieldValue.serverTimestamp(),
})
```

---

## 3. ATUALIZAÇÃO DE DADOS

### 3.1 Padrão de Update

```dart
// Para todas as coleções
firestore.collection('colecao').doc(id).update({
  'campo': valor,
  'updatedAt': FieldValue.serverTimestamp(),
})
```

### 3.2 Atualização de OS

```dart
// OsRepository.updateOs()
await osRef.update({
  'servico': 'Serviço atualizado',
  'osfinalizado': true,
  'horaTermino': DateTime.now(),
  'updatedAt': FieldValue.serverTimestamp(),
})
```

### 3.3 Atualização de Status

```dart
// OsRepository.updateOsStatus()
await osRef.update({
  'osfinalizado': true,
  'pendente': false,
  'updatedAt': FieldValue.serverTimestamp(),
})
```

### 3.4 Cálculo de Total KM

```dart
// OsRepository.calcularAtualizarTotalKm()
final total = kmFinal - kmInicial;
await osRef.update({
  'totalKm': total,
  'updatedAt': FieldValue.serverTimestamp(),
})
```

---

## 4. CONSULTA DE DADOS

### 4.1 Buscar por ID

```dart
// UserRepository.getUserById()
final doc = await firestore.collection('users').doc(uid).get();
if (doc.exists) {
  return UserModel.fromFirestore(doc);
}
```

### 4.2 Buscar por Empresa

```dart
// EmployeeRepository.getEmployeesByCompany()
final snapshot = await firestore
  .collection('employees')
  .where('companyId', isEqualTo: companyId)
  .get();
```

### 4.3 Buscar OS por Status

```dart
// OsRepository.getOsList()
final snapshot = await firestore
  .collection('os')
  .where('companyId', isEqualTo: companyId)
  .orderBy('createdAt', descending: true)
  .limit(20)
  .get();
```

### 4.4 Buscar com Stream (Tempo Real)

```dart
// OsRepository.getOs()
return firestore
  .collection('os')
  .where('companyId', isEqualTo: companyId)
  .snapshots();
```

### 4.5 Buscar Diários por OS

```dart
// DiarioRepository.getDiarios()
final snapshot = await firestore
  .collection('diarios')
  .where('osId', isEqualTo: osId)
  .orderBy('data', descending: true)
  .get();
```

---

## 5. CONSULTA AVANÇADA

### 5.1 Busca Textual

```dart
// Buscar OS por nome do cliente
final snapshot = await firestore
  .collection('os')
  .where('nomeCliente', isGreaterThanOrEqualTo: 'Jo')
  .where('nomeCliente', isLessThanOrEqualTo: 'Jo\uf8ff')
  .get();
```

### 5.2 Busca por Múltiplos Campos

```dart
// Busca por empresa + data
final snapshot = await firestore
  .collection('os')
  .where('companyId', isEqualTo: companyId)
  .where('createdAt', isGreaterThan: dataInicio)
  .where('createdAt', isLessThan: dataFim)
  .get();
```

### 5.3 Busca com Paginação

```dart
// OsRepository.getOsPaginated()
final lastDoc = ...; // último documento da página anterior

final snapshot = await firestore
  .collection('os')
  .where('companyId', isEqualTo: companyId)
  .orderBy('updatedAt', descending: true)
  .startAfterDocument(lastDoc)
  .limit(20)
  .get();
```

---

## 6. RELACIONAMENTOS

### 6.1 Empresa → Usuários

```
company (1) ──────< users (N)
  id                    companyId
```

Busca: `users.where('companyId', '==', companyId)`

### 6.2 Empresa → Funcionários

```
company (1) ──────< employees (N)
  id                    companyId
```

Busca: `employees.where('companyId', '==', companyId)`

### 6.3 Empresa → OS

```
company (1) ──────< os (N)
  id                    companyId
```

Busca: `os.where('companyId', '==', companyId)`

### 6.4 OS → Diários

```
os (1) ──────< diarios (N)
  id                    osId
```

Busca: `diarios.where('osId', '==', osId)`

### 6.5 OS → Funcionários

```
os (N) ──────< funcionarios (N)  [array]
  funcionarios[]             id
```

Campo `funcionarios` é array de UIDs na OS

---

## 7. ÍNDICES DO FIRESTORE

### 7.1 Índices Compostos Recomendados

Para otimizar consultas, criar índices em:

| Coleção | Campos | Ordenação |
|---------|--------|-----------|
| os | companyId, updatedAt | desc |
| os | companyId, createdAt | desc |
| os | companyId, numeroOs | desc |
| diarios | osId, data | desc |
| diarios | companyId, createdAt | desc |
| employees | companyId, name | asc |
| users | companyId, role | asc |

### 7.2 Criar Índice via Firebase Console

1. Acesse Firebase Console
2. Firestore → Índices → Composite
3. Adicione índice conforme necessidade

---

## 8. REGRAS DE SEGURANÇA

### 8.1 Estrutura Atual (firestore.rules)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Usuários: apenas própria leitura/escrita
    match /users/{userId} {
      allow read: if request.auth != null 
                   && request.auth.uid == userId;
      allow write: if request.auth != null 
                   && request.auth.uid == userId;
    }
    
    // Empresas: membros da empresa
    match /companies/{companyId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // OS: apenas membros da empresa
    match /os/{osId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 8.2 Regras Recomendadas

```javascript
// Empresas: apenas owner/admin
match /companies/{companyId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null;
  allow update, delete: if request.auth != null 
    && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['owner', 'admin'];
}

// OS: apenas funcionários da empresa
match /os/{osId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null;
  allow update: if request.auth != null;
  allow delete: if request.auth != null 
    && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['owner', 'admin'];
}
```

---

## 9. OPERAÇÕES ATÔMICAS

### 9.1 Transaction

```dart
// Exemplo: Transferir OS para outra empresa
await firestore.runTransaction((transaction) async {
  final osDoc = await transaction.get(osRef);
  final osData = osDoc.data();
  
  transaction.update(osRef, {
    'companyId': novaEmpresaId,
    'updatedAt': FieldValue.serverTimestamp(),
  });
  
  // Atualizar diário também
  final diarios = await diariosRef.get();
  for (final diario in diarios.docs) {
    transaction.update(diario.reference, {
      'companyId': novaEmpresaId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
});
```

### 9.2 Batch Write

```dart
// Exemplo: Deletar empresa e todos os dados
final batch = firestore.batch();

// Deletar empresa
batch.delete(empresaRef);

// Deletar usuários
final users = await usersRef.get();
for (final user in users.docs) {
  batch.delete(user.reference);
}

// Deletar OS
final osList = await osRef.get();
for (final os in osList.docs) {
  batch.delete(os.reference);
}

await batch.commit();
```

---

## 10. SOFT DELETE

### 10.1 Padrão

O sistema usa soft delete (desativar, não deletar):

```dart
// UserRepository.deleteUser()
await firestore.collection('users').doc(userId).update({
  'isActive': false,
  'updatedAt': FieldValue.serverTimestamp(),
});

// EmployeeRepository.deleteEmployee()
await firestore.collection('employees').doc(employeeId).update({
  'isActive': false,
  'updatedAt': FieldValue.serverTimestamp(),
});
```

### 10.2 Buscar Apenas Ativos

```dart
// Sempre filtrar por isActive
final snapshot = await firestore
  .collection('employees')
  .where('companyId', isEqualTo: companyId)
  .where('isActive', isEqualTo: true)
  .get();
```

---

## 11. LIMITAÇÕES E OTIMIZAÇÕES

### 11.1 Limitações Firestore

| Recurso | Limite |
|---------|--------|
| Writes/segundo | 1 por documento |
| Writes/segundo | 10.000 por coleção |
| Reads/segundo | 10.000 por documento |
| Tamanho documento | 1 MB |
| Campos | 20.000 por documento |

### 11.2 Otimizações

1. **Evitar writes frequentes**
   - Não atualizar `updatedAt` em cada keystroke
   - Usar debounce

2. **Pagination**
   - Sempre usar `.limit(20)` em listas
   - Implementar scroll infinito

3. **Índices**
   - Criar índices para consultas compostas
   - Monitorar consultas lentas no Console

4. **Cache Local**
   - Usar SharedPreferences para dados pequenos
   - Considerar Firebase Offline Persistence

---

## 12. ESTRUTURA DE DADOS POR COLEÇÃO

### 12.1 Companies

```dart
{
  id: String,              // UUID
  name: String,            // Nome fantasia
  cnpj: String?,          // CNPJ (opcional)
  phone: String?,         // Telefone
  address: String?,       // Endereço
  email: String?,         // Email
  logoUrl: String?,       // URL do logo (Storage)
  plan: String,           // 'free' | 'basic' | 'premium'
  isActive: bool,         // Empresa ativa
  ownerId: String,        // UID do dono
  createdAt: DateTime,
  updatedAt: DateTime,
}
```

### 12.2 Users

```dart
{
  id: String,              // Firebase Auth UID
  email: String,
  name: String?,
  companyId: String?,     // FK para company
  role: String,           // 'owner' | 'admin' | 'user'
  isOwner: bool,
  isActive: bool,
  createdAt: DateTime,
  updatedAt: DateTime,
}
```

### 12.3 Employees

```dart
{
  id: String,              // Firebase Auth UID
  name: String,
  email: String,
  role: String,
  phone: String?,
  cpf: String?,
  companyId: String,      // FK para company
  isActive: bool,
  createdAt: DateTime,
  updatedAt: DateTime,
}
```

### 12.4 OS

```dart
{
  id: String,              // UUID
  numeroOs: int,
  nomeCliente: String,
  servico: String,
  relatoCliente: String?,
  responsavel: String?,
  temPedido: bool,
  numeroPedido: String?,
  funcionarios: List<String>,  // UIDs
  kmInicial: int?,
  kmFinal: int?,
  horaInicio: DateTime?,
  intervaloInicio: DateTime?,
  intervaloFim: DateTime?,
  horaTermino: DateTime?,
  osfinalizado: bool,
  garantia: bool,
  pendente: bool,
  pendenteDescricao: String?,
  relatoTecnico: String?,
  assinatura: String?,    // Base64 ou URL
  imagens: List<String>,  // URLs do Storage
  totalKm: int?,
  companyId: String,
  createdAt: DateTime,
  updatedAt: DateTime,
}
```

### 12.5 Diarios

```dart
{
  id: String,              // UUID
  osId: String,           // FK para OS
  numeroOs: int,
  numeroDiario: int,
  nomeCliente: String,
  servico: String,
  data: DateTime,
  // ... campos similares a OS
  companyId: String,
  createdAt: DateTime,
  updatedAt: DateTime,
}
```

### 12.6 Logs

```dart
{
  id: String,              // UUID
  action: String,          // 'create' | 'update' | 'delete'
  entityType: String,     // 'os' | 'diario' | 'user'
  entityId: String,
  userId: String,
  userName: String?,
  companyId: String,
  details: Map<String, dynamic>?,
  timestamp: DateTime,
}
```

