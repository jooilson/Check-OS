import 'dart:async';

/// Classe utilitária para debounce de operações.
/// Usado para evitar chamadas excessivas em listeners de texto,
/// otimizando performance em dispositivos com CPU limitada.
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  /// Executa a ação após o delay configurado.
  /// Se chamado novamente antes do delay, o timer é resetado.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancela qualquer execução pendente.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Libera os recursos. Deve ser chamado no dispose do widget.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// Versão simplificada de debouncer para operações síncronas.
class SimpleDebouncer {
  final int milliseconds;
  DateTime? _lastCall;

  SimpleDebouncer({this.milliseconds = 300});

  /// Retorna true se pode executar (não está em debounce).
  bool canExecute() {
    final now = DateTime.now();
    if (_lastCall == null || 
        now.difference(_lastCall!).inMilliseconds >= milliseconds) {
      _lastCall = now;
      return true;
    }
    return false;
  }
}

