# logger.dart
(c:/Projetos/checkos/lib/core/utils/logger.dart)

# Descrição Geral
Serviço de logging centralizado.

# Responsabilidade no Sistema
Fornece métodos para logs de debug, info, warning e error.

# Métodos
- **debug(String message)** - Logs de debug
- **info(String message)** - Logs informativos
- **warning(String message)** - Logs de aviso
- **error(String message, [Object? error, StackTrace? stackTrace])** - Logs de erro

# Uso
```dart
AppLogger.info('Usuário logado');
AppLogger.error('Erro ao salvar', e, stackTrace);
```

