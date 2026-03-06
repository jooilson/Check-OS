# log_repository.dart
(c:/Projetos/checkos/lib/data/repositories/log_repository.dart)

# Descricao Geral
Repositorio para logs de auditoria.

# Responsabilidade no Sistema
Gerencia operacoes CRUD de logs no Firestore.

# Metodos
- **addLog(LogModel log)** - Adiciona log
- **getLogs(String companyId)** - Lista logs da empresa
- **getLogsByUser(String userId)** - Logs por usuario
- **getLogsByDateRange(DateTime start, DateTime end)** - Logs por periodo
- **getLogsByAction(String action)** - Logs por acao

