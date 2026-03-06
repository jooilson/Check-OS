# company_model.dart
(c:/Projetos/checkos/lib/data/models/company/company_model.dart)

# Descrição Geral
Modelo de dados da empresa que estende CompanyEntity e implementa conversão Firestore.

# Responsabilidade no Sistema
Representa dados da empresa para persistência no Firestore. Herda de CompanyEntity.

# Dependências
- checkos/domain/entities/company/company_entity.dart
- cloud_firestore

# Classes
- **CompanyModel** (estende CompanyEntity)
  - Implementa serialização para/de Firestore

# Métodos / Funções
- **CompanyModel()** (construtor)
  - Parâmetros: id, name, cnpj, phone, address, email, logoUrl, plan, isActive, createdAt, updatedAt, subscriptionExpiresAt, ownerId

- **fromFirestore(DocumentSnapshot doc)** (factory)
  - Finalidade: Criar CompanyModel a partir de DocumentSnapshot

- **toFirestore()** (Map<String, dynamic>)
  - Finalidade: Converter para formato Firestore

- **toMap()** (Map<String, dynamic>)
  - Finalidade: Converter para Map genérico

- **fromMap(String id, Map<String, dynamic> map)** (factory)
  - Finalidade: Criar CompanyModel a partir de Map

- **copyWith({...})** (CompanyModel)
  - Finalidade: Criar cópia com campos atualizados

# Fluxo de Execução
1. Dados chegam do Firestore
2. fromFirestore converte para CompanyModel
3. Dados são usados na UI
4. toFirestore converte de volta para persistência

# Integração com o Sistema
- CompanyEntity: Herda propriedades
- Firestore: Persistência de dados
- AuthService: Cria empresa no registro

# Estrutura de Dados
- Timestamps: Convertidos de/para DateTime
- ownerId: ID do dono da empresa

# Regras de Negócio
- Planos: 'free', 'basic', 'premium'
- isActive permite soft delete
- subscriptionExpiresAt controla expiração

# Pontos Críticos
- ownerId vincula empresa ao criador
- subscriptionExpiresAt pode ser null (plano free)

# Melhorias Possíveis
- Adicionar campos de assinatura
- Adicionar limites por plano

# Observações Técnicas
- Implementa Equatable via herança
- ownerId é novo campo para referência

