# user_repository_impl.dart
(c:/Projetos/checkos/lib/data/repositories/user/user_repository_impl.dart)

# Descrição Geral
Implementação do repositório de usuários que gerencia operações CRUD no Firestore.

# Responsabilidade no Sistema
Centraliza todas as operações de persistência de dados de usuários no Firestore.

# Dependências
- checkos/data/models/user/user_model.dart
- checkos/domain/entities/user/user_entity.dart
- checkos/domain/repositories/user/user_repository.dart
- cloud_firestore

# Classes
- **UserRepositoryImpl** (implementa UserRepository)
  - Implementação do repositório de usuários

# Métodos / Funções
- **getUserById(String id)** (Future<UserEntity?>)
  - Finalidade: Buscar usuário por ID
  - Retorno: UserEntity ou null

- **getUserByEmail(String email)** (Future<UserEntity?>)
  - Finalidade: Buscar usuário por email

- **getUsersByCompany(String companyId)** (Future<List<UserEntity>>)
  - Finalidade: Buscar todos os usuários de uma empresa

- **createUser(UserEntity user)** (Future<void>)
  - Finalidade: Criar novo usuário

- **updateUser(UserEntity user)** (Future<void>)
  - Finalidade: Atualizar usuário existente

- **updateUserCompany(String userId, String companyId)** (Future<void>)
  - Finalidade: Atualizar empresa do usuário

- **updateUserRole(String userId, UserRole role)** (Future<void>)
  - Finalidade: Atualizar role do usuário

- **setUserActive(String userId, bool isActive)** (Future<void>)
  - Finalidade: Ativar/desativar usuário (soft delete)

- **deleteUser(String userId)** (Future<void>)
  - Finalidade: Deletar usuário (soft delete)

- **hasOwner(String companyId)** (Future<bool>)
  - Finalidade: Verificar se empresa tem dono

- **getOwner(String companyId)** (Future<UserEntity?>)
  - Finalidade: Buscar dono da empresa

# Fluxo de Execução
1. Serviço chama método do repositório
2. Firestore executa operação
3. Dados são convertidos para entities

# Integração com o Sistema
- Firestore: Persistência
- UserModel: Serialização

# Estrutura de Dados
- Coleção: 'users'

# Regras de Negócio
- Soft delete via isActive
- companyId filtra usuários por empresa

# Pontos Críticos
- Timestamps usam FieldValue.serverTimestamp()
- Fallback para coleção users se não encontrar em employees

