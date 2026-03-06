# Mapa de Repositories - CheckOS

## Visão Geral

Este documento explica como o padrão Repository está sendo utilizado no projeto CheckOS, listando todos os repositories e suas responsabilidades.

---

## 1. REPOSITORIES DO PROJETO

### 1.1 Estrutura

```
lib/data/repositories/
├── company_repository.dart
├── employee_repository.dart
├── user/
│   └── user_repository_impl.dart
├── diario_repository.dart
├── log_repository.dart
└── os_repository.dart

lib/domain/repositories/
└── user/
    └── user_repository.dart (interface)
```

---

## 2. USERREPOSITORY (INTERFACE)

### 2.1 Arquivo

`lib/domain/repositories/user/user_repository.dart`

### 2.2 Responsabilidade

Define o contrato para operações de usuário. Apenas interface, sem implementação.

### 2.3 Métodos Definidos

```dart
abstract class UserRepository {
  Future<UserEntity?> getUserById(String id);
  Future<void> createUser(UserEntity user);
  Future<void> updateUser(UserEntity user);
}
```

---

## 3. USERREPOSITORYIMPL

### 3.1 Arquivo

`lib/data/repositories/user/user_repository_impl.dart`

### 3.2 Responsabilidade

Implementação do UserRepository para Firestore.

### 3.3 Integrações

```
UserRepositoryImpl
  └── FirebaseFirestore
```

### 3.4 Métodos

| Método | Descrição |
|--------|-----------|
| `getUserById()` | Buscar usuário por ID |
| `getUserByEmail()` | Buscar usuário por email |
| `getUsersByCompany()` | Listar usuários da empresa |
| `createUser()` | Criar novo usuário |
| `updateUser()` | Atualizar usuário |
| `updateUserCompany()` | Vincular usuário a empresa |
| `updateUserRole()` | Alterar role |
| `setUserActive()` | Ativar/desativar usuário |
| `deleteUser()` | Deletar usuário (soft delete) |
| `hasOwner()` | Verificar se tem owner |
| `getOwner()` | Buscar owner da empresa |

### 3.5 Coleção

**Firestore**: `users`

---

## 4. COMPANYREPOSITORY

### 4.1 Arquivo

`lib/data/repositories/company_repository.dart`

### 4.2 Responsabilidade

Gerenciar dados de empresas no Firestore.

### 4.3 Integrações

```
CompanyRepository
  └── FirebaseFirestore
```

### 4.4 Métodos

| Método | Descrição |
|--------|-----------|
| `getCompanyById()` | Buscar empresa por ID |
| `getCompanyByCNPJ()` | Buscar empresa por CNPJ |
| `createCompany()` | Criar nova empresa |
| `updateCompany()` | Atualizar dados |
| `setCompanyActive()` | Ativar/desativar empresa |
| `updateCompanyPlan()` | Atualizar plano |
| `cnpjExists()` | Verificar se CNPJ existe |

### 4.5 Coleção

**Firestore**: `companies`

---

## 5. EMPLOYEEREPOSITORY

### 5.1 Arquivo

`lib/data/repositories/employee_repository.dart`

### 5.2 Responsabilidade

Gerenciar dados de funcionários no Firestore.

### 5.3 Integrações

```
EmployeeRepository
  └── FirebaseFirestore
```

### 5.4 Métodos

| Método | Descrição |
|--------|-----------|
| `getEmployeesStream()` | Stream de funcionários |
| `getEmployeesList()` | Lista de funcionários |
| `getActiveEmployeesList()` | Lista de ativos |
| `getEmployeeById()` | Buscar por ID |
| `getCompanyIdByUid()` | Buscar companyId pelo UID |
| `addEmployee()` | Adicionar funcionário |
| `updateEmployee()` | Atualizar funcionário |
| `deleteEmployee()` | Deletar funcionário |

### 5.5 Coleção

**Firestore**: `employees`

---

## 6. OSREPOSITORY

### 6.1 Arquivo

`lib/data/repositories/os_repository.dart`

### 6.2 Responsabilidade

Gerenciar Ordens de Serviço no Firestore.

### 6.3 Integrações

```
OsRepository
  └── FirebaseFirestore
```

### 6.4 Métodos

| Método | Descrição |
|--------|-----------|
| `addOs()` | Criar nova OS |
| `updateOs()` | Atualizar OS |
| `deleteOs()` | Deletar OS |
| `getOsById()` | Buscar por ID |
| `getOsList()` | Listar OS |
| `getOs()` | Stream de OS |
| `getOsPaginated()` | OS com paginação |
| `updateOsStatus()` | Atualizar status |
| `calcularAtualizarTotalKm()` | Calcular total KM |

### 6.5 Coleção

**Firestore**: `os`

---

## 7. DIARIOREPOSITORY

### 7.1 Arquivo

`lib/data/repositories/diario_repository.dart`

### 7.2 Responsabilidade

Gerenciar Diários de Bordo no Firestore.

### 7.3 Integrações

```
DiarioRepository
  └── FirebaseFirestore
```

### 7.4 Métodos

| Método | Descrição |
|--------|-----------|
| `addDiario()` | Criar diário |
| `updateDiario()` | Atualizar diário |
| `deleteDiario()` | Deletar diário |
| `getDiario()` | Buscar diário |
| `getDiarios()` | Listar diários |
| `getDiariosStream()` | Stream de diários |
| `getDiariosPaginated()` | Diários com paginação |
| `getAllDiarios()` | Todos os diários |

### 7.5 Coleção

**Firestore**: `diarios`

---

## 8. LOGREPOSITORY

### 8.1 Arquivo

`lib/data/repositories/log_repository.dart`

### 8.2 Responsabilidade

Gerenciar logs de auditoria no Firestore.

### 8.3 Integrações

```
LogRepository
  └── FirebaseFirestore
```

### 8.4 Métodos

| Método | Descrição |
|--------|-----------|
| `addLog()` | Criar log |
| `getLogs()` | Listar logs |
| `getLogsByCompany()` | Logs da empresa |
| `getLogsByUser()` | Logs do usuário |
| `getLogsByEntity()` | Logs de uma entidade |

### 8.5 Coleção

**Firestore**: `logs`

---

## 9. PADRÃO REPOSITORY

### 9.1 O que é?

O Repository Pattern abstrai o acesso a dados:

```
Presentation Layer
       │
       ▼
   Repository (abstract)
       │
       ▼
Repository Implementation
       │
       ▼
   Firestore / API / Cache
```

### 9.2 Benefícios

| Benefício | Descrição |
|-----------|-----------|
| Abstração | Código não sabe origem dos dados |
| Testabilidade | Pode mockar repositório |
| Manutenção | Mudanças centralizadas |
| Organização | Lógica de dados encapsulada |

### 9.3 Implementação Atual

O projeto usa implementação parcial:

```dart
// Interface (domain)
abstract class UserRepository {
  Future<UserEntity?> getUserById(String id);
}

// Implementação (data)
class UserRepositoryImpl implements UserRepository {
  @override
  Future<UserEntity?> getUserById(String id) async {
    // Acesso Firestore
  }
}
```

---

## 10. REPOSITORY VS SERVICE

### 10.1 Diferença

| Aspecto | Repository | Service |
|---------|------------|---------|
| Foco | Dados (CRUD) | Lógica de negócio |
| Abstração | Banco de dados | Sistemas externos |
| Dependência | Firestore/API | Firebase Auth, Storage |
| Uso | Pages/UseCases | Pages/Services |

### 10.2 Exemplo

```dart
// Repository: dados
class UserRepository {
  Future<User> getUser(String id);  // Busca dados
}

// Service: lógica de negócio
class AuthService {
  Future<User> login(email, password);  // Valida e loga
}
```

---

## 11. IMPLEMENTAÇÃO ATUAL

### 11.1 Padrão Usado

O projeto implementa repositories como classes que acessam Firestore diretamente:

```dart
class EmployeeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  CollectionReference get _employeesCollection => 
      _firestore.collection('employees');
  
  Future<List<EmployeeEntity>> getEmployeesList(String companyId) async {
    final snapshot = await _employeesCollection
        .where('companyId', isEqualTo: companyId)
        .get();
    return snapshot.docs
        .map((doc) => EmployeeModel.fromFirestore(doc))
        .toList();
  }
}
```

### 11.2 Não Usa Interface

A maioria dos repositories **não** implementa interface:

```
company_repository.dart     → Sem interface
employee_repository.dart    → Sem interface
diario_repository.dart      → Sem interface
log_repository.dart         → Sem interface
os_repository.dart          → Sem interface
user_repository_impl.dart   → USA interface
```

---

## 12. PROBLEMAS IDENTIFICADOS

### 12.1 Inconsistência

- Apenas UserRepository tem interface
- Demais repositories não têm contrato definido
- Dificulta testabilidade e swapping

### 12.2 Instanciação

```dart
// Problema: Instância direta
class Page extends StatelessWidget {
  final EmployeeRepository _repo = EmployeeRepository(); // Ruim
}
```

### 12.3 Falta de Tratamento de Erros

- Pouca Tratamento de exceções
- Sem retry logic
- Sem fallback

---

## 13. RESUMO

| Repository | Interface | Coleção | Responsabilidade |
|------------|-----------|---------|------------------|
| UserRepositoryImpl | ✓ (UserRepository) | users | Usuários |
| CompanyRepository | ✗ | companies | Empresas |
| EmployeeRepository | ✗ | employees | Funcionários |
| OsRepository | ✗ | os | Ordens de Serviço |
| DiarioRepository | ✗ | diarios | Diários de Bordo |
| LogRepository | ✗ | logs | Auditoria |

---

## 14. MELHORIAS RECOMENDADAS

### 14.1 Criar Interfaces

Para todos os repositories:

```dart
abstract class CompanyRepository {
  Future<CompanyEntity?> getById(String id);
  Future<String> create(CompanyEntity company);
  // ...
}
```

### 14.2 Injeção de Dependência

```dart
getIt.registerLazySingleton<CompanyRepository>(
  () => CompanyRepositoryImpl(),
);
```

### 14.3 Tratamento de Erros

```dart
Future<CompanyEntity?> getById(String id) async {
  try {
    // Busca
  } on FirebaseException catch (e) {
    // Log e rethrow
    throw RepositoryException(e.message);
  }
}
```

### 14.4 Cache

Adicionar cache em memória para减少 Firestore reads.

