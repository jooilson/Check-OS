# log_model.dart
(c:/Projetos/checkos/lib/data/models/log_model.dart)

# Descricao Geral
Modelo para logs de auditoria do sistema.

# Estrutura
- **id**: String - ID do log
- **userId**: String - ID do usuario
- **action**: String - Acao realizada
- **entityType**: String - Tipo de entidade
- **entityId**: String - ID da entidade
- **details**: Map - Detalhes adicionais
- **timestamp**: DateTime - Data/hora
- **companyId**: String - ID da empresa

# Acoes Registradas
- CREATE, UPDATE, DELETE
- LOGIN, LOGOUT
- CREATE_OS, UPDATE_OS, DELETE_OS
- CREATE_DIARIO, UPDATE_DIARIO, DELETE_DIARIO

