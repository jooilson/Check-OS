# permission_service.dart
(c:/Projetos/checkos/lib/services/permission_service.dart)

# Descrição Geral
Serviço centralizado de controle de permissões do sistema. Gerencia todas as regras de acesso baseadas em roles.

# Responsabilidade no Sistema
Definir o que cada tipo de usuário pode ou não fazer no sistema.

# Dependências
- checkos/domain/entities/user/user_entity.dart

# Classes
- **PermissionService** (classe estática)
  - Serviço de permissões

- **Permission** (classe de constantes)
  - Constantes de permissões

# Métodos / Funções
- **canAccess(UserEntity user, String permission)** (static bool)
  - Finalidade: Verificar se usuário pode acessar funcionalidade
  - Verifica isActive primeiro
  - Retorno: true se permitido

- **canEditThisUser(UserEntity currentUser, UserEntity targetUser)** (static bool)
  - Finalidade: Verificar se pode editar usuário específico

- **canDeleteThisUser(UserEntity currentUser, UserEntity targetUser)** (static bool)
  - Finalidade: Verificar se pode excluir usuário específico

- **canChangeRole(UserEntity currentUser, UserEntity targetUser, UserRole newRole)** (static bool)
  - Finalidade: Verificar se pode alterar role

- **getUserPermissions(UserEntity user)** (static List<String>)
  - Finalidade: Lista de permissões do usuário

- **getAccessDeniedMessage(String permission)** (static String)
  - Finalidade: Mensagem de erro para permissão negada

# Constantes de Permissão
- editCompany, viewCompany
- createUser, editUser, deleteUser, manageUserRoles
- viewAllData, editOwnData
- deleteDiario, deleteOS
- accessSettings, viewLogs, exportData

# Fluxo de Execução
1. Ação do usuário
2. Verificar permission via canAccess
3. Se permitido, executar ação

# Integração com o Sistema
- AuthContext: Usa para verificações
- UI: Pode usar para desabilitar botões

# Estrutura de Dados
- UserRole: Enum para roles

# Regras de Negócio
- Owner tem todas as permissões
- Admin tem permissões administrativas
- Usuário comum tem acesso mínimo

# Pontos Críticos
- isActive deve ser verificado primeiro
- Owner não pode editar/excluir outro owner

# Melhorias Possíveis
- Adicionar mais permissões granulares
- Cache de permissões para performance

