# diario_model.dart
(c:/Projetos/checkos/lib/data/models/diario_model.dart)

# Descrição Geral
Modelo de dados do Diário de Bordo. Representa registros diários de trabalho em uma OS.

# Responsabilidade no Sistema
Representa dados do diário para persistência no Firestore. Permite registro diário de atividades.

# Dependências
Nenhuma dependência externa direta.

# Classes
- **DiarioModel**
  - Modelo de dados do diário

# Propriedades
- id: String - ID único
- osId: String - ID da OS pai
- numeroOs: String - Número da OS
- numeroDiario: double - Número do diário
- nomeCliente: String - Nome do cliente
- servico: String? - Serviço realizado
- relatoCliente: String? - Relato do cliente
- responsavel: String? - Responsável
- funcionarios: List<String> - IDs dos funcionários
- data: DateTime - Data do registro
- kmInicial: double? - KM inicial
- kmFinal: double? - KM final
- horaInicio: String? - Hora de início
- intervaloInicio: String? - Início do intervalo
- intervaloFim: String? - Fim do intervalo
- horaTermino: String? - Hora de término
- osfinalizado: bool - Se está finalizado
- garantia: bool - Se tem garantia
- pendente: bool - Se está pendente
- pendenteDescricao: String? - Descrição da pendência
- relatoTecnico: String? - Relato técnico
- assinatura: String? - Assinatura (base64)
- imagens: List<String> - URLs das imagens
- temPedido: bool - Se tem pedido
- numeroPedido: String? - Número do pedido
- createdAt: DateTime - Data de criação
- updatedAt: DateTime - Data de atualização

# Métodos / Funções
- **DiarioModel()** (construtor)
- **toMap()** (Map<String, dynamic>) - Converter para Map
- **fromMap(String id, Map<String, dynamic> map)** (factory) - Criar de Map
- **copyWith({...})** (DiarioModel) - Criar cópia
- **toJson()** (Map<String, dynamic>) - Converter para JSON
- **fromJson(Map<String, dynamic> json)** (factory) - Criar de JSON

# Fluxo de Execução
Diários são criados diariamente para registrar atividades de cada OS.

# Integração com o Sistema
- DiarioRepository: Persistência
- OsRepository: Referência para cálculo de KM total
- Páginas: novo_diario_page, editar_diario_page

# Estrutura de Dados
- osId: Referência à OS pai
- companyId deve ser obtido da OS pai

# Regras de Negócio
- Cada OS pode ter múltiplos diários
- KM total calculado via OsRepository

# Pontos Críticos
- Assinatura como base64
- companyId vem da OS referenciada

