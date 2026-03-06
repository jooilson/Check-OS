# Fluxo de Autenticação - CheckOS

## Visão Geral

O sistema de autenticação do CheckOS utiliza Firebase Auth para gerenciamento de identidade de usuários, integrado com Firestore para dados de perfil e vínculo com empresas.

---

## 1. FLUXO DE LOGIN

### 1.1 Fluxo Lógico

```
┌─────────────────────────────────────────────────────────────┐
│ USUÁRIO ABRE O APP                                          │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ main.dart                                                   │
│   - Inicializa Firebase                                     │
│   - Inicializa Push Notifications                           │
│   - Inicializa App Check                                    │
│   - Executa runApp(const MyApp())                           │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ MyApp (app.dart)                                            │
│   - Configura MultiProvider                                 │
│   - Define ThemeProvider                                    │
│   - Define EmployeeContext                                  │
│   - Configura MaterialApp com rotas                         │
│   - Define initialRoute: AppRouteNames.authWrapper          │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ AuthWrapper (auth_wrapper.dart)                             │
│   - Escuta authStateChanges (FirebaseAuth stream)          │
│   - Verifica se usuário está autenticado                    │
└─────────────────────────────────────────────────────────────┘
                            │
              ┌─────────────┴─────────────┐
              ▼                           ▼
    ┌─────────────────┐         ┌─────────────────┐
    │ USUÁRIO LOGADO  │         │ NÃO LOGADO      │
    └─────────────────┘         └─────────────────┘
              │                           │
              ▼                           ▼
    ┌─────────────────┐         ┌─────────────────┐
    │ Busca Employee  │         │ AuthPage        │
    │ pelo UID        │         │ (Login/Register) │
    └─────────────────┘         └─────────────────┘
              │                           │
              ▼                           │
    ┌─────────────────┐                   │
    │ tem companyId?  │                   │
    └─────────────────┘                   │
              │                           │
        ┌─────┴─────┐                     │
        ▼           ▼                     │
    ┌───────┐   ┌───────┐                 │
    │  SIM  │   │  NÃO  │                 │
    └───┬───┘   └───┬───┘                 │
        │           │                     │
        ▼           ▼                     ▼
    ┌───────┐ ┌────────────┐      ┌─────────────┐
    │HOME   │ │CADASTRO    │      │ AuthPage    │
    │PAGE   │ │EMPRESA     │      │ (aguarda)   │
    └───────┘ └────────────┘      └─────────────┘
```

---

## 2. CRIAÇÃO DE USUÁRIOS

### 2.1 Registro de Novo Usuário (Primeiro Acesso)

O registro cria automaticamente:
1. Usuário no Firebase Auth
2. Empresa no Firestore
3. Usuário como Owner no Firestore

```
RegisterPage
    │
    ▼
AuthService.createAccountWithCompany()
    │
    ├── 1. FirebaseAuth.createUserWithEmailAndPassword()
    │       └── Cria usuário em Firebase Auth
    │
    ├── 2. CompanyRepository.createCompany()
    │       └── Cria documento em collection "companies"
    │       └── Gera companyId único
    │
    ├── 3. UserModel ( Owner )
    │       └── companyId = companyId gerado
    │       └── role = UserRole.owner
    │       └── isOwner = true
    │
    └── 4. UserRepository.createUser()
            └── Cria documento em collection "users"
```

### 2.2 Cadastro de Funcionário (Admin)

```
EmployeeAddPage (apenas Admin/Owner)
    │
    ▼
AuthService.registerEmployee()
    │
    ├── 1. Verifica se currentUser tem permissão
    │       └── UserEntity.canCreateUsers
    │
    ├── 2. FirebaseAuth.createUserWithEmailAndPassword()
    │       └── Cria usuário em Firebase Auth
    │
    ├── 3. UserModel (funcionário)
    │       └── companyId = companyId da empresa
    │       └── role = user ou admin
    │       └── isOwner = false
    │
    └── 4. UserRepository.createUser()
```

---

## 3. VERIFICAÇÃO DE AUTENTICAÇÃO

### 3.1 Stream de Estado

O CheckOS utiliza streams do Firebase para verificar estado de autenticação:

```dart
// Em AuthService
Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

// Em AuthWrapper
StreamBuilder<User?>(
  stream: authService.authStateChanges,
  builder: (context, snapshot) { ... }
)
```

### 3.2 Persistência de Sessão

O Firebase Auth mantém sessão automaticamente:
- **Web**: Sessão persiste no localStorage
- **Android/iOS**: Sessão persiste no Secure Storage
- **Token**: Renovado automaticamente pelo SDK

---

## 4. LOGOUT

### 4.1 Fluxo de Logout

```
Usuário clica "Sair"
    │
    ▼
AuthService.signOut()
    │
    ├── FirebaseAuth.signOut()
    │       └── Limpa tokens locais
    │
    └── Navigator.pushReplacementNamed(login)
```

---

## 5. RECUPERAÇÃO DE SENHA

### 5.1 Fluxo de Redefinição

```
LoginPage → "Esqueci minha senha"
    │
    ▼
AuthService.sendPasswordResetEmail(email)
    │
    └── FirebaseAuth.sendPasswordResetEmail()
            └── Envia email com link de redefinição
```

---

## 6. INTEGRAÇÃO COM FIREBASE

### 6.1 Firebase Auth

| Função | Método Firebase |
|--------|-----------------|
| Login | `signInWithEmailAndPassword` |
| Registro | `createUserWithEmailAndPassword` |
| Logout | `signOut` |
| Estado | `authStateChanges` (stream) |
| Recuperação | `sendPasswordResetEmail` |
| Atualização | `updatePassword`, `updateProfile` |

### 6.2 Firestore

| Ação | Collection | Document |
|------|------------|----------|
| Criar empresa | companies | companyId |
| Criar usuário | users | uid (do Firebase Auth) |
| Buscar usuário | users | uid |

---

## 7. DADOS DO USUÁRIO

### 7.1 Estrutura do Usuário

```dart
class UserEntity {
  String id;           // Firebase Auth UID
  String email;        // Email do usuário
  String? name;        // Nome exibido
  String? companyId;   // FK para empresa
  UserRole role;       // owner, admin, user
  bool isOwner;        // É criador da empresa?
  bool isActive;       // Usuário ativo?
  DateTime createdAt;  // Data de criação
  DateTime updatedAt;  // Última atualização
}
```

### 7.2 Roles e Permissões

| Role | canManageUsers | canManageCompany | canCreateUsers |
|------|----------------|-------------------|----------------|
| owner | ✓ | ✓ | ✓ |
| admin | ✓ | ✓ | ✓ |
| user | ✗ | ✗ | ✗ |

---

## 8. DADOS DA EMPRESA

### 8.1 Estrutura da Empresa

```dart
class CompanyEntity {
  String id;           // ID único
  String name;         // Nome fantasia
  String? cnpj;        // CNPJ
  String? phone;       // Telefone
  String? address;     // Endereço
  String? email;       // Email de contato
  String? logoUrl;     // URL do logo (Firebase Storage)
  String plan;         // free, basic, premium
  String? ownerId;     // UID do dono
  DateTime createdAt;
  DateTime updatedAt;
}
```

---

## 9. EMPLOYEE vs USER

### 9.1 Duplicação de Dados

O sistema mantém duas coleções relacionadas:

```
users (UserModel)
├── id: uid
├── email
├── name
├── companyId
├── role
└── isOwner

employees (EmployeeModel)
├── id: uid
├── email
├── name
├── role
├── phone
├── cpf
├── companyId
└── isActive
```

### 9.2 Por que existem ambos?

- **users**: Dados de autenticação e permissões
- **employees**: Dados funcionais (CPF, telefone, etc)

### 9.3 Sincronização

A sincronização é manual:
- Ao criar usuário → cria employee
- Ao atualizar usuário → atualiza employee

---

## 10. EMPLOYEE CONTEXT

### 10.1 Para que serve?

O `EmployeeContext` mantém o funcionário atual em memória:
- Usado para auditoria (quem fez ação)
- Acesso rápido ao funcionário logado
- Não persiste entre sessões (reniciado ao fechar app)

### 10.2 Uso

```dart
// Provider
ChangeNotifierProvider(create: (_) => EmployeeContext())

// Acesso
context.read<EmployeeContext>().currentEmployee
```

---

## 11. PONTOS CRÍTICOS

### 11.1 companyId Null

**Problema**: Usuários podem ter `companyId = null`

**Verificação distribuída**:
```dart
// Em AuthWrapper
if (user.companyId == null) {
  return CadastroEmpresaPage();
}

// Em Various Pages
if (employee.companyId == null) {
  // mostra erro
}
```

**Risco**: NullPointerException se não verificar

### 10.2 Falha ao Buscar Employee

**Cenário**: Usuário existe no Firebase Auth mas não tem documento no Firestore

**Tratamento**: AuthWrapper cria employee vazio

### 10.3 Sessão Expirada

**Cenário**: Token Firebase expirou

**Comportamento**: Stream `authStateChanges` emite `null`

---

## 11. MELHORIAS SUGERIDAS

1. **Unificar users e employees**
   - Uma única coleção
   - Dados de auth + dados funcionais juntos

2. **Centralizar verificação de companyId**
   - Criar serviço `CompanyService`
   - Método `ensureCompanyRegistered()`

3. **Usar ID token**
   - Verificar token no backend (Firebase Admin SDK)
   - Mais seguro que verificar no cliente

4. **Melhor tratamento de erros**
   - Toast/Snackbar para cada tipo de erro
   - Mensagens amigáveis

5. **Session timeout**
   - Implementar logout automático após inatividade
   - Usar `FirebaseAuth.instance.idTokenChanges()`

