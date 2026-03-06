# Mapa de Services - CheckOS

## Visão Geral

Este documento lista todos os serviços do projeto CheckOS, explicando suas responsabilidades e integrações.

---

## 1. SERVICES DO PROJETO

### 1.1 Estrutura

```
lib/services/
├── firebase/
│   └── auth_service.dart
├── import_export_service.dart
├── logo_service.dart
├── permission_service.dart
├── push_notification_service.dart
├── employee_exemplos.dart        (exemplo)
├── funcionarios_em_os_exemplos.dart (exemplo)
└── import_export_exemplos.dart    (exemplo)
```

---

## 2. AUTHSERVICE

### 2.1 Arquivo

`lib/services/firebase/auth_service.dart`

### 2.2 Responsabilidades

- Autenticação de usuários com Firebase Auth
- Criação de contas (usuário + empresa)
- Cadastro de funcionários
- Gerenciamento de sessão
- Recuperação de senha

### 2.3 Integrações

```
AuthService
  ├── FirebaseAuth
  ├── UserRepositoryImpl
  │   └── FirebaseFirestore
  └── CompanyRepository
      └── FirebaseFirestore
```

### 2.4 Métodos

| Método | Descrição |
|--------|-----------|
| `signInWithEmailAndPassword()` | Login com email/senha |
| `createAccountWithCompany()` | Criar conta + empresa |
| `registerEmployee()` | Cadastrar funcionário |
| `getFullUserData()` | Buscar usuário + empresa |
| `needsCompanyRegistration()` | Verificar se precisa cadastrar empresa |
| `linkUserToCompany()` | Vincular usuário à empresa |
| `getUserRole()` | Buscar role do usuário |
| `signOut()` | Logout |
| `sendPasswordResetEmail()` | Enviar email de redefinição |
| `updatePassword()` | Atualizar senha |
| `updateProfile()` | Atualizar perfil |

### 2.5 Propriedades

| Propriedade | Tipo | Descrição |
|-------------|------|-----------|
| `authStateChanges` | Stream<User?> | Stream de estado de auth |
| `currentUser` | User? | Usuário atual |

---

## 3. PERMISSIONSERVICE

### 3.1 Arquivo

`lib/services/permission_service.dart`

### 3.2 Responsabilidades

- Verificar permissões de usuários
- Controlar acesso a funcionalidades
- Validar operações baseadas em role

### 3.3 Integrações

```
PermissionService
  └── UserEntity (para verificar roles)
```

### 3.4 Métodos

| Método | Descrição |
|--------|-----------|
| `canAccess()` | Pode acessar funcionalidade |
| `canEditThisUser()` | Pode editar usuário específico |
| `canDeleteThisUser()` | Pode excluir usuário específico |
| `canChangeRole()` | Pode alterar role |
| `getUserPermissions()` | Listar permissões do usuário |
| `getAccessDeniedMessage()` | Mensagem de acesso negado |

---

## 4. PUSHNOTIFICATIONSERVICE

### 4.1 Arquivo

`lib/services/push_notification_service.dart`

### 4.2 Responsabilidades

- Inicializar Firebase Cloud Messaging
- Solicitar permissões de notificação
- Configurar canal de notificações
- Gerenciar token de dispositivo

### 4.3 Integrações

```
PushNotificationService
  └── FirebaseMessaging
```

### 4.4 Métodos

| Método | Descrição |
|--------|-----------|
| `initialize()` | Inicializar serviço |
| `requestPermission()` | Solicitar permissão |
| `getToken()` | Obter token do dispositivo |
| `subscribeToTopic()` | Inscrever em tópico |
| `unsubscribeFromTopic()` | Cancelar inscrição |

### 4.5 Configuração Android

```dart
// Canal de notificação
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'checkos_channel',
  'CheckOS Notifications',
  description: 'Notificações do CheckOS',
  importance: Importance.high,
);
```

---

## 5. IMPORTEXPORTSERVICE

### 5.1 Arquivo

`lib/services/import_export_service.dart`

### 5.2 Responsabilidades

- Importar dados de arquivos externos
- Exportar dados para formatos diversos
- Processar arquivos CSV

### 5.3 Integrações

```
ImportExportService
  ├── FilePicker
  ├── PathProvider
  └── Repositories (OS, Diario, Employee)
```

### 5.4 Métodos

| Método | Descrição |
|--------|-----------|
| `importFromCSV()` | Importar de CSV |
| `exportToCSV()` | Exportar para CSV |
| `exportToPDF()` | Exportar para PDF |
| `pickFile()` | Selecionar arquivo |
File()` | Sal| `savevar arquivo |

---

 LOGOSERVICE

## 6.### 6.1 Arquivo

`lib/services/logo_service.dart`

### 6.2 Gerenciar upload Responsabilidades

- de logos de empresas
- Arm Firebase Storage
-azenar no Fornecer URL do logo

### 6.3 Integrações

```
LogoService
  ├── FirebaseStorage
  ├── ImagePicker
  └── FilePicker
```

### 6.4 Métodos

| Método | Descrição |
|--------|-----------|
| `uploadLogo()` | Fazer upload do logo |
| `deletecluir logo |
Logo()` | Ex| `getLogoter URL do logoUrl()` | Ob |

---

## 7. SERVICE EX DEEMPLOS

### 7.1 Arquivos de Exemplo

| Arquivo | Descrição |
|---------|-----------|
| `employee_exemplos.dart` | Exemplos de funcionários |
| `funcionarios_em_os_exemplos.dart` | Exemplos de funcionários em OS |
| `import_export_exemplos.dart` | Exemplos de importação/exportação |

**Nota**: Estes arquivos parecem ser para desenvolvimento/testes.

---

## 8. FLUXOS DE SERVIÇOS

### 8.1 Fluxo de Autenticação

```
LoginPage
    │
    ▼
AuthService.signInWithEmailAndPassword()
    │
    ├── FirebaseAuth
    │       └── Valida credentials
    │
    ├── UserRepository.getUserById()
    │       └── Busca dados do usuário
    │
    └── EmployeeContext.setEmployee()
            └── Armazena em memória
```

### 8.2 Fluxo de Registro

```
RegisterPage
    │
    ▼
AuthService.createAccountWithCompany()
    │
    ├── FirebaseAuth.createUserWithEmailAndPassword()
    │       └── Cria usuário no Firebase
    │
    ├── CompanyRepository.createCompany()
    │       └── Cria empresa no Firestore
    │
    └── UserRepository.createUser()
            └── Cria usuário com role "owner"
```

### 8.3 Fluxo de Notificações

```
main.dart
    │
    ▼
PushNotificationService.initialize()
    │
    ├── FirebaseMessaging.instance
    │       └── Inicializa FCM
    │
    ├── requestPermission()
    │       └── Solicita permissão
    │
    └── getToken()
            └── Obtém token do dispositivo
```

---

## 9. DEPENDÊNCIAS EXTERNAS

### 9.1 Pacotes Firebase

| Serviço | Pacote |
|---------|--------|
| Auth | `firebase_auth` |
| Firestore | `cloud_firestore` |
| Storage | `firebase_storage` |
| Messaging | `firebase_messaging` |
| App Check | `firebase_app_check` |

### 9.2 Pacotes Flutter

| Serviço | Pacote |
|---------|--------|
| Arquivos | `file_picker`, `path_provider` |
| Imagens | `image_picker` |
| PDF | `pdf`, `printing` |
| Utils | `uuid`, `intl` |

---

## 10. INSTANCIAÇÃO

### 10.1 Problema Atual

Os serviços são instanciados diretamente nas classes:

```dart
// Problema: Acoplamento alto
class AuthWrapper extends StatelessWidget {
  final AuthService _authService = AuthService();  // Instancia direta
  final EmployeeRepository _employeeRepository = EmployeeRepository();
}
```

### 10.2 Recomendação

Usar injeção de dependência com get_it:

```dart
// get_it
final getIt = GetIt.instance;

getIt.registerLazySingleton<AuthService>(() => AuthService());
getIt.registerLazySingleton<AuthService>(() => AuthService());
getIt.registerLazySingleton<CompanyRepository>(() => CompanyRepository());
```

---

## 11. RESUMO DE SERVIÇOS

| Serviço | Arquivo | Responsabilidade |
|---------|---------|------------------|
| AuthService | firebase/auth_service.dart | Autenticação Firebase |
| PermissionService | permission_service.dart | Controle de acesso |
| PushNotificationService | push_notification_service.dart | Notificações push |
| ImportExportService | import_export_service.dart | Importação/exportação |
| LogoService | logo_service.dart | Gerenciamento de logos |
| Exemplos | *_exemplos.dart | Dados de exemplo |

---

## 12. MELHORIAS RECOMENDADAS

### 12.1 Injeção de Dependência

Implementar get_it para todos os serviços.

### 12.2 Interfaces

Criar interfaces para serviços:

```dart
abstract class AuthServiceInterface {
  Future<UserCredential> signIn(...);
  Future<void> signOut();
  // ...
}
```

### 12.3 Testabilidade

Com interfaces, facilitar mocking para testes unitários.

