# company_repository.dart
(c:/Projetos/checkos/lib/data/repositories/company_repository.dart)

# Descrição Geral
Repositório de empresas que gerencia operações CRUD no Firestore.

# Responsabilidade no Sistema
Centraliza operações de persistência de dados de empresas.

# Dependências
- checkos/data/models/company/company_model.dart
- cloud_firestore
- uuid

# Classes
- **CompanyRepository**
  - Repositório de empresas

# Métodos / Funções
- **getCompanyById(String id)** (Future<CompanyModel?>)
  - Finalidade: Buscar empresa por ID
  - Retorno: CompanyModel ou null

- **getCompanyByOwnerId(String ownerId)** (Future<CompanyModel?>)
  - Finalidade: Buscar empresa pelo ID do dono

- **getCompanyByCnpj(String cnpj)** (Future<CompanyModel?>)
  - Finalidade: Buscar empresa pelo CNPJ

- **getCompaniesByUser(String userId)** (Future<List<CompanyModel>>)
  - Finalidade: Buscar empresas de um usuário

- **createCompany({required String name, required String ownerId, String? cnpj, String? phone, String? address, String? email})** (Future<String>)
  - Finalidade: Criar nova empresa
  - Retorno: ID da empresa criada

- **updateCompany(CompanyModel company)** (Future<void>)
  - Finalidade: Atualizar empresa

- **deleteCompany(String id)** (Future<void>)
  - Finalidade: Deletar empresa (soft delete)

- **setCompanyActive(String id, bool isActive)** (Future<void>)
  - Finalidade: Ativar/desativar empresa

- **updateCompanyLogo(String companyId, String logoUrl)** (Future<void>)
  - Finalidade: Atualizar logo da empresa

# Fluxo de Execução
1.UUID gera ID para empresa
2.CompanyModel é persistido no Firestore
3.ID é retornado para vinculação

# Integração com o Sistema
- Firestore: Coleção 'companies'
- AuthService: Cria empresa no registro
- UserModel: companyId referencia empresa

# Estrutura de Dados
- Coleção: 'companies'

# Regras de Negócio
- Soft delete via isActive
- CNPJ é único (opcional)
- ownerId vincula ao criador

# Pontos Críticos
- UUID gera ID antes de criar
- ownerId é importante para permissões

