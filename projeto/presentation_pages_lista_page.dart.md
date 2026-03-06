# lista_page.dart
(c:/Projetos/checkos/lib/presentation/pages/lista_page.dart)

# Descricao Geral
Pagina de listagem de Ordens de Servico.

# Responsabilidade no Sistema
Exibe lista de OS com filtros e ordenacao.

# Dependencias
- flutter/material.dart
- checkos/data/repositories/os_repository.dart
- checkos/data/models/os_model.dart

# Funcionalidades
- Lista todas as OS da empresa
- Filtro por status (pendente/em andamento/finalizado)
- Filtro por data
- Busca por cliente
- Ordenacao por data
- Paginação (20 em 20)
- Acoes: visualizar, editar, excluir

# Integracao
- OsRepository: getOsList(), getOsPaginated()
- OsModel: dados das OS

