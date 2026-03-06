# debouncer.dart
(c:/Projetos/checkos/lib/utils/debouncer.dart)

# Descricao Geral
Utilitario para debounce de funcoes.

# Responsabilidade no Sistema
Atrasa execucao de funcoes para evitar multiplas chamadas.

# Uso
```dart
final debouncer = Debouncer(milliseconds: 500);
debouncer.run(() => buscarDados());
```

# Parametros
- milliseconds: Tempo de atraso (padrao: 500ms)

