# theme_provider.dart
(c:/Projetos/checkos/lib/theme/theme_provider.dart)

# Descrição Geral
Provider para gerenciar o tema da aplicação (claro/escuro).

# Responsabilidade no Sistema
Permite alternância entre tema claro e escuro.

# Dependências
- flutter/material.dart
- provider

# Propriedades
- **themeMode** (ThemeMode) -Modo atual do tema

# Métodos
- **toggleTheme()** -Alterna entre claro e escuro
- **setThemeMode(ThemeMode mode)** -Define modo específico

# Uso
```dart
final themeProvider = context.read<ThemeProvider>();
themeProvider.toggleTheme();
```

