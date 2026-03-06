# user_model.dart
(c:/Projetos/checkos/lib/data/models/user/user_model.dart)

# Descrição Geral
Modelo de dados do usuário que estende UserEntity e implementa conversão Firestore.

# Responsabilidade no Sistema
Representa dados do usuário para persistência no Firestore. Herda regras de negócio de UserEntity.

# Dependências
- checkos/domain/entities/user/user_entity.dart
- cloud_firestore

# Classes
- **UserModel** (estende UserEntity)
  - Implementa serialização para/de Firestore

# Métodos / Funções
- **UserModel()** (construtor)
  - Parâmetros: id, email, name, companyId, role, isOwner, isActive, createdAt, updatedAt

- **fromFirestore(DocumentSnapshot doc)** (factory)
  - Finalidade: Criar UserModel a partir de DocumentSnapshot
  - Parâmetros: doc - Documento do Firestore
  - Retorno: UserModel populado

- **toFirestore()** (Map<String, dynamic>)
  - Finalidade: Converter para formato Firestore
  - Retorno: Map com campos para persistência

- **toMap()** (Map<String, dynamic>)
  - Finalidade: Converter para Map genérico
  - Retorno: Map com campos e datas em ISO8601

- **fromMap(String id, Map<String, dynamic> map)** (factory)
  - Finalidade: Criar UserModel a partir de Map
  - Parâmetros: id e map
  - Retorno: UserModel populado

- **empty(String id, String email)** (factory)
  - Finalidade: Criar usuário vazio para novo registro
  - Retorno: UserModel com valores padrão

- **copyWith({...})** (UserModel)
  - Finalidade: Criar cópia com campos atualizados
  - Retorno: Nova instância UserModel

# Fluxo de Execução
1. Dados chegam do Firestore como DocumentSnapshot
2. fromFirestore converte para UserModel
3. Dados são usados na UI
4. toFirestore converte de volta para persistência

# Integração com o Sistema
- UserEntity: Herda propriedades e validações
- Firestore: Persistência de dados

# Estrutura de Dados
- Timestamps: Convertidos de/para DateTime
- UserRole: Enum convertido para string

# Regras de Negócio
- Herda todas as regras de UserEntity
- isActive permite soft delete

# Pontos Críticos
- Conversão de Timestamp para DateTime
- Validação de campos opcionais

# Melhorias Possíveis
- Adicionar validação de email
- Adicionar mais campos de perfil

# Observações Técnicas
- Implementa Equatable via herança
- toString() para debug

