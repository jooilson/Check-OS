# os_model.dart
(c:/Projetos/checkos/lib/data/models/os_model.dart)

# Descrição Geral
Modelo de dados da OS (Ordem de Serviço). Representa todas as informações de uma OS no sistema.

# Responsabilidade no Sistema
Representa dados da OS para persistência no Firestore. Modelo central do sistema.

# Dependências
Nenhuma dependência externa direta.

# Classes
- **OsModel**
  - Modelo de dados da OS

# Propriedades
- id: String - ID único
- numeroOs: String - Número da OS
- nomeCliente: String - Nome do cliente
- servico: String - Serviço a ser realizado
- relatoCliente: String - Relato do cliente
- responsavel: String - Responsável pela OS
- temPedido: bool - Se tem pedido relacionado
- numeroPedido: String? - Número do pedido
- funcionarios: List<String> - IDs dos funcionários
- kmInicial: double? - KM inicial
- kmFinal: double? - KM final
- horaInicio: String? - Hora de início
- intervaloInicio: String? - Início do intervalo
- intervaloFim: String? - Fim do intervalo
- horaTermino: String? - Hora de término
- osfinalizado: bool - Se está finalizada
- garantia: bool - Se tem garantia
- pendente: bool - Se está pendente
- pendenteDescricao: String? - Descrição da pendência
- relatoTecnico: String? - Relato técnico
- assinatura: String? - Assinatura (base64)
- imagens: List<String> - URLs das imagens
- totalKm: double? - Total de KM
- companyId: String? - ID da empresa
- createdAt: DateTime? - Data de criação
- updatedAt: DateTime? - Data de atualização

# Métodos / Funções
- **OsModel()** (construtor)
- **toMap()** (Map<String, dynamic>) - Converter para Map
- **fromMap(String id, Map<String, dynamic> map)** (factory) - Criar de Map
- **toJson()** (Map<String, dynamic>) - Converter para JSON
- **fromJson(Map<String, dynamic> json)** (factory) - Criar de JSON
- **copyWith({...})** (OsModel) - Criar cópia com alterações

# Fluxo de Execução
OS é criada, editada e visualizada através das páginas do sistema.

# Integração com o Sistema
- OsRepository: Persistência
- Páginas: novaos_page, detalhes_os_page, lista_page

# Estrutura de Dados
- companyId: Filtro multi-tenant
- imagens: Lista de URLs (Firebase Storage)

# Regras de Negócio
- companyId é obrigatório para filtragem
- Status: osfinalizado, pendente, garantia

# Pontos Críticos
- Assinatura armazenada como base64
- Imagens referências a Firebase Storage

# Melhorias Possíveis
- Adicionar validações
- Separar em entity e model

