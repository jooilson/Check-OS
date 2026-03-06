# user_entity.dart
(c:/Projetos/checkos/lib/domain/entities/user/user_entity.dart)

# Descrição Geral
Entidade base do usuário que define a estrutura de dados e regras de negócio relacionadas a usuários.

# Responsabilidade no Sistema
Define a estrutura de dados do usuário e as permissões baseadas em roles (owner, admin, user).

# Dependências
- equatable

# Classes
- **UserRole** (enum)
  - owner: Dono da empresa (criador)
  - admin: Administrador
  - user: Usuário comum

- **UserRoleExtension** (extension on UserRole)
  - value: Retorna string ('owner', 'admin', 'user')
  - displayName: Retorna nome para exibição
  - fromString: Converte string para enum

- **UserEntity** (extends Equatable)
  - Entidade base do usuário

# Propriedades de UserEntity
- id: String - ID único do usuário
- email: String - Email do usuário
- name: String? - Nome completo
- companyId: String? - ID da empresa (vinculo)
- role: UserRole - Cargo/função
- isOwner: bool - Se é dono da empresa
- isActive: bool - Se está ativo
- createdAt: DateTime - Data de criação
- updatedAt: DateTime - Data de atualização

# Métodos / Funções
- **isAdmin** (getter bool)
  - Finalidade: Verificar se é admin ou owner

- **canManageUsers** (getter bool)
  - Finalidade: Verificar se pode gerenciar usuários

- **canManageCompany** (getter bool)
  - Finalidade: Verificar se pode gerenciar empresa

- **canEditUsers** (getter bool)
  - Finalidade: Verificar se pode editar usuários

- **canDeleteUsers** (getter bool)
  - Finalidade: Verificar se pode excluir usuários

- **canDeleteData** (getter bool)
  - Finalidade: Verificar se pode excluir dados (diários, OS)

- **canCreateUsers** (getter bool)
  - Finalidade: Verificar se pode criar usuários

# Fluxo de Execução
1. Usuário é criado com role específico
2. Validações usam getters para verificar permissões
3. UI adapta baseada nas permissões

# Integração com o Sistema
- UserModel: Estende esta entidade
- AuthContext: Usa permissões para controle de acesso
- PermissionService: Usa roles para validação

# Estrutura de Dados
- Equatable: Para comparação de objetos

# Regras de Negócio
- Owner e Admin têm permissões completas
- Usuário comum tem acesso limitado
- isActive controla acesso (soft delete)

# Pontos Críticos
- isAdmin inclui owner e admin
- companyId pode ser null (usuário sem empresa)

# Melhorias Possíveis
- Adicionar mais roles customizáveis
- Adicionar permissões granulares

# Observações Técnicas
- Usa Equatable para comparação
- props define equality check

