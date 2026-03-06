# company_entity.dart
(c:/Projetos/checkos/lib/domain/entities/company/company_entity.dart)

# Descrição Geral
Entidade base da empresa que define a estrutura de dados e regras de negócio relacionadas a empresas.

# Responsabilidade no Sistema
Define a estrutura de dados da empresa no sistema multi-tenant.

# Dependências
- equatable

# Classes
- **CompanyEntity** (extends Equatable)
  - Entidade base da empresa

# Propriedades de CompanyEntity
- id: String - ID único da empresa
- name: String - Nome da empresa
- cnpj: String? - CNPJ (opcional)
- phone: String? - Telefone
- address: String? - Endereço
- email: String? - Email da empresa
- logoUrl: String? - URL do logo
- plan: String - Plano ('free', 'basic', 'premium')
- isActive: bool - Se está ativa
- createdAt: DateTime - Data de criação
- updatedAt: DateTime - Data de atualização
- subscriptionExpiresAt: DateTime? - Data de expiração
- ownerId: String? - ID do dono

# Métodos / Funções
- **isSubscriptionActive** (getter bool)
  - Finalidade: Verificar se assinatura está ativa
  - Lógica: Planos 'free' são sempre ativos

- **hasOwner** (getter bool)
  - Finalidade: Verificar se tem dono associado

# Fluxo de Execução
1. Empresa é criada com dados básicos
2. Owner é vinculado após registro
3. Assinatura gerencia acesso a recursos

# Integração com o Sistema
- CompanyModel: Estende esta entidade
- AuthService: Cria empresa no registro
- UserEntity: Reference companyId

# Estrutura de Dados
- Equatable para comparação
- Props define equality

# Regras de Negócio
- Plano 'free' não expira
- isActive permite soft delete

# Pontos Críticos
- ownerId pode ser null durante criação

# Melhorias Possíveis
- Adicionar mais campos de negócio

