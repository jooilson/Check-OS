# auth_service.dart
(c:/Projetos/checkos/lib/services/firebase/auth_service.dart)

# Descrição Geral
Serviço de autenticação que gerencia login, registro de usuários e funcionários via Firebase Auth.

# Responsabilidade no Sistema
Centraliza todas as operações de autenticação:
- Login com email/senha
- Criação de conta com empresa (para primeiro acesso)
- Registro de funcionários
- Busca de dados do usuário (com empresa)
- Gerenciamento de perfil

# Dependências
- checkos/data/models/user/user_model.dart
- checkos/data/models/company/company_model.dart
- checkos/data/repositories/company_repository.dart
- checkos/data/repositories/user/user_repository_impl.dart
- checkos/domain/entities/user/user_entity.dart
- firebase_auth

# Classes
- **AuthService**
  - Serviço principal de autenticação
  - Usa FirebaseAuth e repositórios

- **UserWithCompany** (classe de dados)
  - user: UserModel - dados do usuário
  - company: CompanyModel? - dados da empresa (pode ser null)

# Métodos / Funções
- **authStateChanges** (Stream<User?>)
  - Finalidade: Stream de mudanças de estado de autenticação
  - Retorno: Stream do usuário atual ou null

- **currentUser** (User?)
  - Finalidade: Obter usuário atual logado
  - Retorno: User do Firebase ou null

- **signInWithEmailAndPassword({required String email, required String password})** (Future<UserCredential>)
  - Finalidade: Realizar login
  - Parâmetros: email e senha
  - Retorno: UserCredential com dados do usuário

- **createAccountWithCompany({required String email, required String password, required String name, required String companyName, String? cnpj, String? phone, String? address})** (Future<UserCredential>)
  - Finalidade: Criar nova conta e empresa (para primeiro acesso)
  - Parâmetros: dados do usuário e empresa
  - Retorno: UserCredential do novo usuário
  - Comportamento: Cria usuário no Auth → Cria empresa no Firestore → Cria documento do usuário

- **registerEmployee({required String email, required String password, required String name, required String companyId, String role})** (Future<String>)
  - Finalidade: Cadastrar novo funcionário na empresa
  - Parâmetros: dados do funcionário
  - Retorno: UID do novo funcionário
  - Comportamento: Verifica permissões → Cria usuário no Auth → Cria documento

- **getFullUserData(String uid)** (Future<UserWithCompany>)
  - Finalidade: Buscar dados completos do usuário (usuário + empresa)
  - Parâmetros: uid do usuário
  - Retorno: UserWithCompany com ambos os dados

- **needsCompanyRegistration(String uid)** (Future<bool>)
  - Finalidade: Verificar se usuário precisa completar cadastro de empresa
  - Retorno: true se companyId for null/vazio

- **linkUserToCompany(String userId, String companyId, UserRole role)** (Future<void>)
  - Finalidade: Vincular usuário a empresa
  - Parâmetros: IDs e role

- **getUserRole(String uid)** (Future<String>)
  - Finalidade: Buscar role do usuário
  - Retorno: String com role ('owner', 'admin', 'user')

- **signOut()** (Future<void>)
  - Finalidade: Realizar logout

- **sendPasswordResetEmail(String email)** (Future<void>)
  - Finalidade: Enviar email de redefinição de senha

- **updatePassword(String newPassword)** (Future<void>)
  - Finalidade: Atualizar senha do usuário atual

- **updateProfile({String? name})** (Future<void>)
  - Finalidade: Atualizar perfil (displayName)

# Fluxo de Execução
1. Usuário chama método de autenticação
2. FirebaseAuth executa operação
3. Repositórios sincronizam dados no Firestore
4. Retorno com UserCredential ou exceção

# Integração com o Sistema
- FirebaseAuth: Autenticação backend
- CompanyRepository: Persistência de empresa
- UserRepositoryImpl: Persistência de usuário

# Estrutura de Dados
- UserCredential: Credencial do Firebase Auth
- UserRole: Enum (owner, admin, user)

# Regras de Negócio
- Apenas admin/owner pode criar funcionários
- Owner não pode ser criado - apenas primeiro acesso
- companyId vincula usuário à empresa

# Pontos Críticos
- registerEmployee verifica permissões antes de criar
- createAccountWithCompany faz 3 operações atômicas

# Melhorias Possíveis
- Adicionar verificação de email
- Implementar autenticação por telefone
- Adicionar 2FA (two-factor authentication)

# Observações Técnicas
- Usa FirebaseAuth diretamente
- Repositórios sincronizam com Firestore
- companyId é chave para multi-tenant

