# diario_repository.dart
(c:/Projetos/checkos/lib/data/repositories/diario_repository.dart)

# Descrição Geral
Repositório de Diários de Bordo que gerencia operações CRUD no Firestore.

# Responsabilidade no Sistema
Centraliza operações de persistência de diários. Inclui numeração automática baseada na OS.

# Dependências
- cloud_firestore
- checkos/data/models/diario_model.dart

# Classes
- **DiarioRepository**
  - Repositório de diários

# Métodos / Funções
- **addDiario(DiarioModel diario)** (Future<String>)
  - Finalidade: Criar novo diário
  - Numeração automática: OS-001 → diários 1.1, 1.2, etc.
  - Retorno: ID do diário criado

- **updateDiario(DiarioModel diario)** (Future<void>)
  - Finalidade: Atualizar diário

- **deleteDiario(String diarioId)** (Future<void>)
  - Finalidade: Deletar diário

- **getDiario(String diarioId)** (Future<DiarioModel?>)
  - Finalidade: Buscar diário por ID

- **getDiariosStream(String osId)** (Stream<List<DiarioModel>>)
  - Finalidade: Stream de diários de uma OS

- **getDiarios(String osId)** (Future<List<DiarioModel>>)
  - Finalidade: Lista de diários de uma OS

- **getDiariosPaginated(String osId, {int limit, DocumentSnapshot? lastDocument})** (Future<(List<DiarioModel>, DocumentSnapshot?)>)
  - Finalidade: Diários com paginação

- **getAllDiarios()** (Future<List<DiarioModel>>)
  - Finalidade: Todos os diários

- **getAllDiariosPaginated({int limit, DocumentSnapshot? lastDocument})** (Future<(List<DiarioModel>, DocumentSnapshot?)>)
  - Finalidade: Todos os diários paginados

- **deleteAllDiarios()** (Future<void>)
  - Finalidade: Deletar todos os diários

# Fluxo de Execução
1. Diário criado → calcula número (OS número . sequência)
2. Salva no Firestore
3. OS pai tem KM total recalculado

# Integração com o Sistema
- Firestore: Coleção 'diarios'
- DiarioModel: Modelo de dados

# Estrutura de Dados
- Coleção: 'diarios'
- osId: Referência à OS pai

# Regras de Negócio
- Número do diário: numeroOS.sequencial
- Ex: OS-001 → 1.1, 1.2, 1.3

# Pontos Críticos
- Numeração automática baseada em agregação COUNT
- companyId deve ser obtido da OS referenciada

# Melhorias Possíveis
- Adicionar companyId no diário
- Implementar soft delete
