/// Logger condicional para uso em produção.
/// 
/// Por padrão, apenas logs de WARNING e ERROR são exibidos.
/// Logs de DEBUG e INFO podem ser ativados definindo _debugMode = true.
/// 
/// Uso:
/// - AppLogger.debug('mensagem de debug');   // apenas em modo debug
/// - AppLogger.info('mensagem de info');     // apenas em modo debug  
/// - AppLogger.warning('aviso');              // sempre exibido
/// - AppLogger.error('erro', exception);      // sempre exibido
class AppLogger {
  // Definir como true apenas para desenvolvimento/debug
  static bool _debugMode = false;
  
  /// Ativa/desativa o modo debug em tempo de execução
  static void setDebugMode(bool enabled) {
    _debugMode = enabled;
  }
  
  /// Retorna se o modo debug está ativo
  static bool get isDebugMode => _debugMode;

  /// Log de debug - apenas exibido em modo debug
  static void debug(String message) {
    if (_debugMode) {
      print('[DEBUG] $message');
    }
  }

  /// Log informativo - apenas exibido em modo debug
  static void info(String message) {
    if (_debugMode) {
      print('[INFO] $message');
    }
  }

  /// Log de aviso - sempre exibido (útil para debugging em produção)
  static void warning(String message) {
    print('[WARNING] $message');
  }

  /// Log de erro - sempre exibido (útil para debugging em produção)
  static void error(String message, [Object? exception]) {
    final errorMsg = exception != null ? '$message: $exception' : message;
    print('[ERROR] $errorMsg');
  }
}

