# Diagrama de Dependências do Sistema CheckOS

## Visão Geral das Dependências

Este documento mostra as dependências entre arquivos do projeto CheckOS, baseado nos imports encontrados.

---

## 1. DEPENDÊNCIAS PRINCIPAIS (Entry Point)

```
main.dart
  ├── app.dart
  ├── firebase_options.dart
  ├── firebase_core (Firebase.initializeApp)
  ├── firebase_app_check
  ├── push_notification_service.dart
  └── logger.dart
```

---

## 2. FLUXO DE AUTENTICAÇÃO

```
app.dart (MyApp)
  ├── ThemeProvider
  ├── EmployeeContext
  ├── AppRouter
  └── AppTheme

AuthWrapper
  ├── AuthService
  │   └── FirebaseAuth
  ├── EmployeeRepository
  │   └── FirebaseFirestore
  └── AuthContext

AuthService (services/firebase/auth_service.dart)
  ├── FirebaseAuth
  ├── UserRepositoryImpl
  │   └── FirebaseFirestore
  ├── CompanyRepository
  │   └── FirebaseFirestore
  └── UserModel
      └── UserEntity
```

---

## 3. FLUXO DE DADOS (Models → Repositories → Firestore)

### User Flow
```
UserModel (data/models/user/)
  └── UserEntity (domain/entities/user/)

UserRepositoryImpl (data/repositories/user/)
  ├── UserRepository interface (domain/repositories/user/)
  ├── UserModel
  └── FirebaseFirestore
```

### Company Flow
```
CompanyModel (data/models/company/)
  └── CompanyEntity (domain/entities/company/)

CompanyRepository (data/repositories/)
  └── FirebaseFirestore
```

### Employee Flow
```
EmployeeModel (data/models/employee/)
  └── EmployeeEntity (domain/entities/employee/)

EmployeeRepository (data/repositories/)
  └── FirebaseFirestore
```

### OS Flow
```
OsModel (data/models/)
  └── Firestore

OsRepository (data/repositories/)
  └── FirebaseFirestore
```

### Diario Flow
```
DiarioModel (data/models/)
  └── Firestore

DiarioRepository (data/repositories/)
  └── FirebaseFirestore
```

---

## 4. MAPA COMPLETO DE IMPORTS

### main.dart
```
- checkos/app.dart
- checkos/core/utils/logger.dart
- checkos/firebase_options.dart
- checkos/services/push_notification_service.dart
- firebase_core
- firebase_app_check
```

### app.dart
```
- checkos/core/constants/app_route_names.dart
- checkos/core/context/employee_context.dart
- checkos/core/routes/app_router.dart
- checkos/core/theme/app_theme.dart
- theme/theme_provider.dart
- provider
```

### AuthWrapper (presentation/pages/auth/)
```
- checkos/services/firebase/auth_service.dart
- checkos/data/repositories/employee_repository.dart
- checkos/data/repositories/company_repository.dart
- checkos/core/context/auth_context.dart
- checkos/presentation/pages/login/login_page.dart
- checkos/presentation/pages/home/home_page.dart
- checkos/presentation/pages/cadastro_empresa/cadastro_empresa_page.dart
- checkos/core/routes/app_router.dart
- checkos/core/constants/app_route_names.dart
```

### AuthService
```
- checkos/data/models/user/user_model.dart
- checkos/data/models/company/company_model.dart
- checkos/data/repositories/company_repository.dart
- checkos/data/repositories/user/user_repository_impl.dart
- checkos/domain/entities/user/user_entity.dart
- firebase_auth
```

### PermissionService
```
- checkos/domain/entities/user/user_entity.dart
- firebase_auth (indirect)
```

---

## 5. DEPENDÊNCIAS CRÍTICAS

### AuthService (CRÍTICO)
```
✓ Responsável por toda autenticação
✓ Cria usuários no Firebase Auth
✓ Gerencia vínculo usuário-empresa
✓ Depende de: FirebaseAuth, UserRepositoryImpl, CompanyRepository
```

### EmployeeRepository (CRÍTICO)
```
✓ Gerencia funcionários no Firestore
✓ Busca dados para contexto de autenticação
✓ Depende de: FirebaseFirestore
```

### OsRepository (CRÍTICO)
```
✓ Persistência de Ordens de Serviço
✓ Opera com dados sensíveis de clientes
✓ Depende de: FirebaseFirestore
```

---

## 6. ANÁLISE DE ACOPLAMENTO

### Alto Acoplamento Identificado

1. **AuthService**
   -依存 多: FirebaseAuth + UserRepositoryImpl + CompanyRepository
   - RISCO: Mudanças em qualquer dependência afetam autenticação

2. **AuthWrapper**
   -依存 多: AuthService, EmployeeRepository, CompanyRepository
   - RISCO: Ponto único de falha para login

3. **Pages dependem de Services/Repositories diretamente**
   - Pages instanciam services diretamente
   - Sem injeção de dependência formal

### Acoplamento Moderado

1. **Models ↔ Entities**
   - UserModel → UserEntity
   - CompanyModel → CompanyEntity
   - EmployeeModel → EmployeeEntity
   - BOM: Separação clara de concerns

2. **Repositories ↔ FirebaseFirestore**
   - BOM: Abstrai acesso ao banco

---

## 7. POSSÍVEIS CICLOS DE DEPENDÊNCIA

### Ciclo Identificado
```
AuthService → UserRepositoryImpl → UserModel → UserEntity
     ↑                                    ↓
     └────────────────────────────────────┘
     (necessário para validação de tipos)
```

**Veredicto**: Ciclo benigno - Entity é classe base imutável

---

## 8. ARQUITETURA FRÁGIL IDENTIFICADA

### Pontos de Fragilidade

1. **Duplicação de Dados**
   ```
   employees (EmployeeModel) ←→ users (UserModel)
   - Dados duplicados manualmente
   - Risco de inconsistência
   ```

2. **companyId Nullable**
   ```
   user.companyId pode ser null
   - Verificações distribuídas no código
   - Risco de NullPointerException
   ```

3. **Instanciação Direta**
   ```
   new AuthService()
   new UserRepositoryImpl()
   - Sem injeção de dependência
   - Difícil testar unitariamente
   ```

4. **Contexts com Provider**
   ```
   AuthContext (definido mas não usado consistentemente)
   EmployeeContext (usado para estado global)
   - Estado分散ado
   ```

---

## 9. RESUMO DE DEPENDÊNCIAS

### Por Camada

| Camada | Depende De |
|--------|-----------|
| main.dart | Firebase, Services |
| app.dart | Core, Theme |
| services/ | Firebase, Models |
| data/repositories/ | Firebase, Models, Entities |
| data/models/ | Entities, Firestore |
| domain/entities/ | Equatable |
| presentation/pages/ | Services, Repositories, Widgets |
| presentation/widgets/ | Models |

### Por Serviço Externo

| Serviço | Dependências |
|---------|--------------|
| Firebase Auth | firebase_auth |
| Firestore | cloud_firestore |
| Storage | firebase_storage |
| Push Notifications | firebase_messaging |
| App Check | firebase_app_check |

---

## 10. RECOMENDAÇÕES

1. **Introduzir Injeção de Dependência**
   - Usar get_it (já está nas dependências)
   - Criar módulos de injeção

2. **Consolidar Dados**
   - Unificar employees e users
   - Eliminar duplicação

3. **Usar Repository Interface Consistentemente**
   - Todos repositories devem implementar interface
   - Facilitar mocking para testes

4. **Centralizar companyId**
   - Criar serviço/função utilitária
   - Evitar verificações dispersas

