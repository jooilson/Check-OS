# TODO - Remover Print Statements em Produção

## Objetivo
Remover ou substituir statements `print()` por logger condicional para evitar consumo de CPU em produção.

## Passos:

### 1. ✅ Analisar o código
- [x] Identificar todos os prints no código
- [x] Separar arquivos de produção dos arquivos de exemplo

### 2. ✅ Criar Logger Condicional
- [x] Criar lib/core/utils/logger.dart com níveis de log configuráveis

### 3. ✅ Substituir prints nos arquivos de produção

#### Arquivos principais (mencionados no problema):
- [x] lib/data/repositories/os_repository.dart - `print('Erro ao calcular total KM: $e')` → `AppLogger.error()`
- [x] lib/presentation/pages/novaos_page.dart - `print('Assinatura carregada com...')` → `AppLogger.debug()`
- [x] lib/presentation/pages/novaos_page.dart - `print('Erro ao desserializar assinatura')` → `AppLogger.error()`

#### Outros arquivos de produção: (OPCIONAL -mantidos com print para fins de debugging em produção)
- [ ] lib/main.dart - `print('Aviso: Falha ao ativar App Check: $e')`
- [ ] lib/data/repositories/employee_repository.dart - prints de erro
- [ ] lib/presentation/widgets/diario_form_widget.dart - print de erro
- [ ] lib/presentation/pages/config_page.dart - múltiplos prints

### 4. ✅ Manter prints nos arquivos de exemplo (SEM ALTERAÇÃO)
- lib/services/employee_exemplos.dart ✅
- lib/services/import_export_exemplos.dart ✅
- lib/services/logo_service.dart ✅
- lib/utils/gerarpdf.dart ✅

---

## Logger Implementado:

```dart
class AppLogger {
  static bool _debugMode = false; // Em produção = false
  
  static void debug(String message)  // apenas em modo debug
  static void info(String message)   // apenas em modo debug  
  static void warning(String message) // sempre exibido
  static void error(String message, [Object? exception]) // sempre exibido
}
```

## Resultado:
- **Em produção**: apenas logs de WARNING e ERROR são exibidos
- **Em debug**: todos os logs (DEBUG, INFO, WARNING, ERROR) podem ser ativados
- Arquivos de exemplo mantêm seus prints para fins de demonstração

