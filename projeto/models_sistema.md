# Mapa de Models - CheckOS

## Visão Geral

Este documento lista todos os modelos (models) do projeto CheckOS, explicando seus campos, finalidades e relações com o Firestore.

---

## 1. MODELS DO PROJETO

### 1.1 Estrutura de Models

```
lib/data/models/
├── company/
│   └── company_model.dart
├── employee/
│   └── employee_model.dart
├── user/
│   └── user_model.dart
├── diario_model.dart
├── log_model.dart
├── os_model.dart
└── os_model_bkp.dart (backup)
```

---

## 2. USERMODEL

### 2.1 Arquivo

`lib/data/models/user/user_model.dart`

### 2.2 Herança

```
UserModel → UserEntity → Equatable
```

### 2.3 Campos

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| id | String | ✓ | Firebase Auth UID |
| email | String | ✓ | Email do usuário |
| name | String | ✗ | Nome de exibição |
| companyId | String? | ✗ | ID da empresa |
| role | UserRole | ✗ | Papel (owner/admin/user) |
| isOwner | bool | ✗ | É dono da empresa |
| isActive | bool | ✗ | Usuário ativo |
| createdAt | DateTime | ✓ | Data de criação |
| updatedAt | DateTime | ✓ | Última atualização |

### 2.4 Relação com Firestore

**Coleção**: `users`

**Conversão**:
```dart
// Firestore → Model
UserModel.fromFirestore(DocumentSnapshot doc)

// Model → Firestore
userModel.toFirestore() → Map<String, dynamic>
```

### 2.5 Métodos

- `fromFirestore()` - Cria modelo do documento
- `toFirestore()` - Converte para formato Firestore
- `toMap()` - Converte para Map
- `fromMap()` - Cria do Map
- `copyWith()` - Cria cópia com alterações
- `empty()` - Cria usuário vazio

---

## 3. COMPANYMODEL

### 3.1 Arquivo

`lib/data/models/company/company_model.dart`

### 3.2 Herança

```
CompanyModel → CompanyEntity → Equatable
```

### 3.3 Campos

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| id | String | ✓ | ID único da empresa |
| name | String | ✓ | Nome fantasia |
| cnpj | String? | ✗ | CNPJ |
| phone | String? | ✗ | Telefone |
| address | String? | ✗ | Endereço |
| email | String? | ✗ | Email de contato |
| logoUrl | String? | ✗ | URL do logo (Storage) |
| plan | String | ✗ | Plano (free/basic/premium) |
| isActive | bool | ✗ | Empresa ativa |
| ownerId | String? | ✗ | UID do dono |
| createdAt | DateTime | ✓ | Data de criação |
| updatedAt | DateTime | ✓ | Última atualização |
| subscriptionExpiresAt | DateTime? | ✗ | Expiração da assinatura |

### 3.4 Relação com Firestore

**Coleção**: `companies`

### 3.5 Métodos

- `fromFirestore()` - Cria modelo do documento
- `toFirestore()` - Converte para formato Firestore
- `toMap()` - Converte para Map
- `fromMap()` - Cria do Map
- `copyWith()` - Cria cópia com alterações

---

## 4. EMPLOYEEMODEL

### 4.1 Arquivo

`lib/data/models/employee/employee_model.dart`

### 4.2 Herança

```
EmployeeModel → EmployeeEntity → Equatable
```

### 4.3 Campos

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| id | String | ✓ | UID (mesmo do Firebase Auth) |
| name | String | ✓ | Nome do funcionário |
| email | String | ✓ | Email |
| role | String | ✗ | Papel (user/admin) |
| phone | String? | ✗ | Telefone |
| cpf | String? | ✗ | CPF |
| companyId | String | ✓ | ID da empresa |
| isActive | bool | ✗ | Funcionário ativo |
| createdAt | DateTime | ✓ | Data de criação |
| updatedAt | DateTime | ✓ | Última atualização |

### 4.4 Relação com Firestore

**Coleção**: `employees`

---

## 5. OSMODEL

### 5.1 Arquivo

`lib/data/models/os_model.dart`

### 5.2 Campos

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| id | String | ✓ | ID único |
| numeroOs | int | ✓ | Número da OS |
| nomeCliente | String | ✓ | Nome do cliente |
| servico | String | ✓ | Serviço realizado |
| relatoCliente | String? | ✗ | Relato do cliente |
| responsavel | String? | ✗ | Responsável |
| temPedido | bool | ✗ | Tem pedido? |
| numeroPedido | String? | ✗ | Número do pedido |
| funcionarios | List<String> | ✗ | IDs dos funcionários |
| kmInicial | int? | ✗ | KM inicial |
| kmFinal | int? | ✗ | KM final |
| horaInicio | DateTime? | ✗ | Hora de início |
| intervaloInicio | DateTime? | ✗ | Início do intervalo |
| intervaloFim | DateTime? | ✗ | Fim do intervalo |
| horaTermino | DateTime? | ✗ | Hora de término |
| osfinalizado | bool | ✗ | OS finalizada |
| garantia | bool | ✗ | Tem garantia |
| pendente | Bool? | ✗ | Pendente |
| pendenteDescricao | String? | ✗ | Descrição da pendência |
| relatoTecnico | String? | ✗ | Relatório técnico |
| assinatura | String? | ✗ | Assinatura (base64) |
| imagens | List<String> | ✗ | URLs das imagens |
| totalKm | int? | ✗ | Total de KM |
| companyId | String | ✓ | ID da empresa |
| createdAt | DateTime | ✓ | Data de criação |
| updatedAt | DateTime | ✓ | Última atualização |

### 5.3 Relação com Firestore

**Coleção**: `os`

### 5.4 Relacionamentos

- **companyId**: FK para companies
- **funcionarios**: Array de UIDs para employees

---

## 6. DIARIOMODEL

### 6.1 Arquivo

`lib/data/models/diario_model.dart`

### 6.2 Campos

Muitos campos são similares ao OsModel, mais:

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| id | String | ✓ | ID único |
| osId | String | ✓ | ID da OS vinculada |
| numeroOs | int | ✓ | Número da OS |
| numeroDiario | int | ✓ | Número do diário |
| data | DateTime | ✓ | Data do registro |
| (demais campos OS) | ... | ... | Ver OsModel |

### 6.3 Relação com Firestore

**Coleção**: `diarios`

### 6.4 Relacionamentos

- **osId**: FK para os
- **companyId**: FK para companies

---

## 7. LOGMODEL

### 7.1 Arquivo

`lib/data/models/log_model.dart`

### 7.2 Campos

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| id | String | ✓ | ID único |
| action | String | ✓ | Ação (create/update/delete) |
| entityType | String | ✓ | Tipo de entidade |
| entityId | String | ✓ | ID da entidade |
| userId | String | ✓ | ID do usuário |
| userName | String? | ✗ | Nome do usuário |
| companyId | String | ✓ | ID da empresa |
| details | Map<String, dynamic>? | ✗ | Detalhes adicionais |
| timestamp | DateTime | ✓ | Data/hora |

### 7.3 Relação com Firestore

**Coleção**: `logs`

---

## 8. RELAÇÃO ENTRE MODELS

### 8.1 Diagrama de Relações

```
┌──────────────────┐     companyId      ┌──────────────────┐
│    Company       │────────────────────│      User        │
│  CompanyModel   │                    │    UserModel     │
└──────────────────┘                    └──────────────────┘
        │                                       │
        │ companyId                             │ companyId
        ▼                                       ▼
┌──────────────────┐                    ┌──────────────────┐
│      OS          │                    │    Employee      │
│    OsModel      │◄───────────────────│  EmployeeModel   │
└──────────────────┘    companyId       └──────────────────┘
        │
        │ osId
        ▼
┌──────────────────┐
│     Diario       │
│  DiarioModel    │
└──────────────────┘
```

### 8.2 Relacionamentos Detalhados

| De | Para | Tipo | Campo |
|----|------|------|-------|
| Company | User | 1:N | companyId |
| Company | Employee | 1:N | companyId |
| Company | OS | 1:N | companyId |
| OS | Diario | 1:N | osId |
| OS | Employee | N:M | funcionarios[] |

---

## 9. MODEL-ENTITY SEPARATION

### 9.1 Por que separar?

O projeto usa duas camadas:
- **Entity**: classes de domínio (puro, sem dependências)
- **Model**: mapeamento para Firestore

### 9.2 Exemplo

```dart
// Domain/Entity (puro)
class UserEntity extends Equatable {
  final String id;
  final String email;
  // ... campos
}

// Data/Model (com Firestore)
class UserModel extends UserEntity {
  // ... campos + métodos de conversão
  factory UserModel.fromFirestore(DocumentSnapshot doc) { ... }
  Map<String, dynamic> toFirestore() { ... }
}
```

---

## 10. MÉTODOS COMUNS

### 10.1 copyWith

Todos os models implementam `copyWith()`:

```dart
UserModel copyWith({
  String? name,
  String? email,
  // ...
}) {
  return UserModel(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    // ...
  );
}
```

### 10.2 fromFirestore

```dart
factory Model.fromFirestore(DocumentSnapshot doc) {
  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  return Model(
    id: doc.id,
    campo: data['campo'],
    // ...
  );
}
```

### 10.3 toFirestore

```dart
Map<String, dynamic> toFirestore() {
  return {
    'campo': campo,
    'outroCampo': Timestamp.fromDate(outroCampo),
    // ...
  };
}
```

---

## 11. PROBLEMAS IDENTIFICADOS

### 11.1 Duplicação de Dados

- Users e Employees têm dados semelhantes
- companyId pode ser null em UserModel

### 11.2 OSModel Grande

- Muita campos em um único documento
- Considerar subdividir em subcoleções

### 11.3 Backup Antigo

- `os_model_bkp.dart` parece ser backup não utilizado

---

## 12. RESUMO

| Model | Arquivo | Coleção | Entidade Pai |
|-------|---------|---------|---------------|
| UserModel | user/user_model.dart | users | UserEntity |
| CompanyModel | company/company_model.dart | companies | CompanyEntity |
| EmployeeModel | employee/employee_model.dart | employees | EmployeeEntity |
| OsModel | os_model.dart | os | - |
| DiarioModel | diario_model.dart | diarios | - |
| LogModel | log_model.dart | logs | - |

