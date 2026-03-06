# Arquitetura do Sistema CheckOS

## Visão Geral da Arquitetura

O CheckOS é um sistema de gestão de Ordens de Serviço (OS) e Diários de Bordo construído com Flutter e Firebase.

### Stack Tecnológico
- **Frontend**: Flutter 3.x
- **Backend**: Firebase (Firestore, Auth, Storage, Cloud Messaging)
- **Estado**: Provider + ChangeNotifier
- **Arquitetura**: Clean Architecture (Domain, Data, Presentation)

---

## Estrutura de Pastas

```
lib/
├── app.dart                          # Widget raiz
├── main.dart                         # Entry point
├── firebase_options.dart             # Configurações Firebase
├── core/                             # Configurações globais
│   ├── constants/                    # Cores, rotas, strings
│   ├── context/                      # Auth, Employee contexts
│   ├── routes/                       # Gerenciador de rotas
│   ├── theme/                        # Temas
│   └── utils/                        # Logger
├── data/                             # Camada de dados
│   ├── models/                       # Modelos
│   └── repositories/                 # Repositórios
├── domain/                           # Camada de domínio
│   ├── entities/                     # Entidades
│   └── repositories/                 # Interfaces
├── presentation/                     # Camada de apresentação
│   ├── pages/                        # Páginas
│   └── widgets/                      # Widgets
├── services/                         # Serviços
└── utils/                            # Utilitários
```

---

## Fluxo de Dados

### Autenticação
AuthWrapper → FirebaseAuth → AuthService → UserRepository → EmployeeContext

### Criação de OS
HomePage → NovaOsPage → OsModel → OsRepository → Firestore

### Criação de Diário
DetalhesOS → NovoDiarioPage → DiarioModel → DiarioRepository → Firestore

---

## Integração com Firebase

### Firebase Auth
- Autenticação por email/senha
- Criação de usuários (owner, admin, user)
- Gerenciamento de senha

### Cloud Firestore
**Coleções:**
- `users` - Usuários
- `employees` - Funcionários
- `companies` - Empresas
- `os` - Ordens de serviço
- `diarios` - Diários de bordo

---

## Estrutura de Models

### UserModel
- id, email, name, companyId, role, isOwner, isActive, createdAt, updatedAt

### CompanyModel  
- id, name, cnpj, phone, address, email, logoUrl, plan, isActive, ownerId, createdAt, updatedAt, subscriptionExpiresAt

### OsModel
- id, numeroOs, nomeCliente, servico, relatoCliente, responsavel, temPedido, numeroPedido, funcionarios, kmInicial, kmFinal, horaInicio, intervaloInicio, intervaloFim, horaTermino, osfinalizado, garantia, pendente, pendenteDescricao, relatoTecnico, assinatura, imagens, totalKm, companyId, createdAt, updatedAt

### DiarioModel
- id, osId, numeroOs, numeroDiario, nomeCliente, servico, data, (demais campos similares a OsModel)

### EmployeeModel
- id, name, email, role, phone, cpf, companyId, isActive, createdAt, updatedAt

---

## Estrutura de Services

### AuthService
- signInWithEmailAndPassword()
- createAccountWithCompany()
- registerEmployee()
- getFullUserData()
- getUserRole()
- signOut()
- sendPasswordResetEmail()

### PermissionService
- canAccess()
- canEditThisUser()
- canDeleteThisUser()
- canChangeRole()
- getUserPermissions()
- getAccessDeniedMessage()

---

## Estrutura de Repositories

### UserRepositoryImpl
- getUserById(), getUserByEmail()
- getUsersByCompany()
- createUser(), updateUser()
- updateUserCompany(), updateUserRole()
- setUserActive(), deleteUser()
- hasOwner(), getOwner()

### CompanyRepository
- getCompanyById(), getCompanyByCNPJ()
- createCompany()
- updateCompany()
- setCompanyActive()
- updateCompanyPlan()
- cnpjExists()

### EmployeeRepository
- getEmployeesStream(), getEmployeesList()
- getActiveEmployeesList()
- getEmployeeById()
- getCompanyIdByUid()
- addEmployee(), updateEmployee()
- deleteEmployee()

### OsRepository
- addOs(), updateOs(), deleteOs()
- getOsById(), getOsList()
- getOs() (stream)
- getOsPaginated()
- updateOsStatus()
- calcularAtualizarTotalKm()

### DiarioRepository
- addDiario(), updateDiario(), deleteDiario()
- getDiario(), getDiarios()
- getDiariosStream()
- getDiariosPaginated()
- getAllDiarios()

---

## Fluxo de Autenticação

### 1. App Inicia
main.dart → MyApp → AuthWrapper

### 2. AuthWrapper Verifica Estado
StreamBuilder(FirebaseAuth.authStateChanges)
- Se autenticado: busca EmployeeModel → verifica companyId
- Se companyId null → CadastroEmpresaPage
- Se não autenticado → AuthPage

### 3. Login
LoginPage → AuthService.signInWithEmailAndPassword() → EmployeeRepository → HomePage

### 4. Registro
RegisterPage → AuthService.createAccountWithCompany() → HomePage

---

## Pontos de Escalabilidade

1. **Paginação**: OS e Diários com 20 em 20 documentos
2. **Índices Firestore**: companyId + updatedAt, osId + data
3. **Cache Local**: SharedPreferences para email
4. **Limites Firebase**: 1 write/segundo por documento

---

## Riscos Arquiteturais

1. **Duplicação employees/users** - Sincronização manual
2. **companyId Null** - Verificação分散ada
3. **Validação Server-Side** - Regras básicas

---

## Sugestões de Melhoria

1. **Unificar Coleções**: Consolidar employees e users
2. **Use Cases**: Implementar domain/usecases/
3. **Injeção de Dependência**: Usar get_it
4. **Testes**: Unit e widget tests
5. **Cache**: shared_preferences para dados
6. **Clean Architecture**: Separação completa
7. **Observabilidade**: Analytics e Crashlytics

