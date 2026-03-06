# auth_context.dart
(c:/Projetos/checkos/lib/core/context/auth_context.dart)

# Descrição Geral
Contexto de autenticação global que gerencia estado do usuário logado, empresa atual e permissões.

# Responsabilidade no Sistema
Fornece estado global acessível em toda a aplicação via Provider. Gerencia login, logout e permissões.

# Dependências
- flutter/foundation.dart
- checkos/data/models/user/user_model.dart
- checkos/data/models/company/company_model.dart
- checkos/domain/entities/user/user_entity.dart
- checkos/services/permission_service.dart

# Classes
- **AuthContext** (extends ChangeNotifier)
  - Gerencia estado de autenticação global

# Propriedades
- _currentUser: UserModel? - Usuário atual
- _currentCompany: CompanyModel? - Empresa atual
- _isLoading: bool - Estado de loading
- _errorMessage: String? - Mensagem de erro
- _isInitialized: bool - Se foi inicializado

# Getters
- currentUser, currentCompany, isLoading, errorMessage, isInitialized
- isLoggedIn, hasCompany, isOwner, isAdmin, isUser, isActive
- userId, companyId, userRole
- canEditCompany, canCreateUsers, canEditUsers, canDeleteUsers, canDeleteData

# Métodos / Funções
- **initialize()** - Inicializa o contexto

- **setCurrentUser(UserModel?)** - Define usuário atual

- **setCurrentCompany(CompanyModel?)** - Define empresa atual

- **setUserAndCompany(UserModel, CompanyModel?)** - Define ambos (login)

- **setLoading(bool)** - Define estado de loading

- **setError(String)** - Define mensagem de erro

- **clearError()** - Limpa erro

- **clearAll()** - Limpa tudo (logout)

- **updateCompany(CompanyModel)** - Atualiza empresa

- **updateUserRole(UserRole)** - Atualiza role em memória

- **updateUserCompanyId(String)** - Atualiza companyId em memória

- **hasPermission(String)** - Verifica permissão genérica

- **canEditThisCompany()** - Verifica se pode editar empresa

- **canCreateThisUser()** - Verifica se pode criar usuário

- **canEditThisUser(UserModel)** - Verifica se pode editar usuário

- **canDeleteThisUser(UserModel)** - Verifica se pode excluir usuário

- **canDeleteThisDiario()** - Verifica se pode excluir diário

- **canDeleteThisOS()** - Verifica se pode excluir OS

- **getAccessDeniedMessage(String)** - Mensagem de acesso negado

# Fluxo de Execução
1. App inicia → AuthContext.initialize()
2. Login → setUserAndCompany()
3. UI observa mudanças via Provider
4. Logout → clearAll()

# Integração com o Sistema
- Provider: Gerência de estado
- UserModel/CompanyModel: Dados
- PermissionService: Validações

# Estrutura de Dados
- ChangeNotifier para reactive updates

# Regras de Negócio
- Owner e Admin têm permissões completas
- companyId vem do usuário ou empresa

# Pontos Críticos
- Estado em memória (não persiste)
- companyId pode vir de user ou company

# Melhorias Possíveis
- Persistir estado com SharedPreferences
- Adicionar cache de permissões

# Observações Técnicas
- debugPrint para logs de desenvolvimento
- Notifica listeners em todas mudanças

