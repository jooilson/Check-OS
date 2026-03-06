# os_repository.dart
(c:/Projetos/checkos/lib/data/repositories/os_repository.dart)

# Descrição Geral
Repositório de OS (Ordens de Serviço) que gerencia operações CRUD no Firestore.

# Responsabilidade no Sistema
Centraliza operações de persistência de OS. Inclui paginação e cálculo de KM.

# Dependências
- cloud_firestore
- checkos/data/models/os_model.dart
- checkos/core/utils/logger.dart

# Classes
- **OsRepository**
  - Repositório de OS

# Métodos / Funções
- **addOs(OsModel os)** (Future<String>)
  - Finalidade: Criar nova OS
  - Retorno: ID da OS criada

- **updateOs(OsModel os)** (Future<void>)
  - Finalidade: Atualizar OS

- **updateOsStatus(String osId, {required bool osfinalizado, required bool pendente})** (Future<void>)
  - Finalidade: Atualizar status da OS

- **getOsById(String id)** (Future<OsModel?>)
  - Finalidade: Buscar OS por ID

- **deleteOs(String id)** (Future<void>)
  - Finalidade: Deletar OS

- **getOs({String? companyId})** (Stream<List<OsModel>>)
  - Finalidade: Stream de OS em tempo real

- **getOsPaginated({int limit, DocumentSnapshot? lastDocument, String? companyId})** (Future<(List<OsModel>, DocumentSnapshot?)>)
  - Finalidade: Buscar OS com paginação
  - Limit padrão: 20

- **getOsList({String? companyId})** (Future<List<OsModel>>)
  - Finalidade: Lista de OS

- **deleteAllOs({String? companyId})** (Future<void>)
  - Finalidade: Deletar todas as OS

- **calcularAtualizarTotalKm(String osId)** (Future<void>)
  - Finalidade: Calcula KM total (OS + Diários)
  - Atualiza campo totalKm na OS

# Fluxo de Execução
1. OS é criada/editada via repository
2. companyId filtra por empresa
3. Cálculo de KM soma OS + diários

# Integração com o Sistema
- Firestore: Coleção 'os'
- OsModel: Modelo de dados

# Estrutura de Dados
- Coleção: 'os'
- companyId: Filtro multi-tenant
- Paginação com DocumentSnapshot cursor

# Regras de Negócio
- companyId é obrigatório para filtragem
- Soft delete não implementado (hard delete)

# Pontos Críticos
- companyId filtragem é essencial
- Cálculo de KM considera diários

# Melhorias Possíveis
- Implementar soft delete
- Adicionar cache local

