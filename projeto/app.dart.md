# app.dart
(c:/Projetos/checkos/lib/app.dart)

# Descrição Geral
Widget raiz do aplicativo CheckOS que configura os providers globais, tema e rotas.

# Responsabilidade no Sistema
Este arquivo configura a estrutura fundamental do app:
- MultiProvider para gerenciamento de estado global (tema e funcionário atual)
- Configuração de tema claro/escuro
- Definição das rotas iniciais

# Dependências
- checkos/core/constants/app_route_names.dart
- checkos/core/context/employee_context.dart
- checkos/core/routes/app_router.dart
- checkos/core/theme/app_theme.dart
- flutter/material.dart
- provider

# Classes
- **MyApp** (StatelessWidget)
  - Widget principal do aplicativo
  - Configura MultiProvider com ThemeProvider e EmployeeContext
  - Define MaterialApp com tema e rotas

# Métodos / Funções
- **build()** (Widget)
  - Finalidade: Construir a árvore de widgets do app
  - Retorno: MaterialApp configurado com providers e rotas

# Fluxo de Execução
1. MyApp é executado pelo main()
2. MultiProvider cria ThemeProvider e EmployeeContext
3. Consumer<ThemeProvider> observa mudanças no tema
4. MaterialApp define rotas via AppRouter.generateRoute

# Integração com o Sistema
- EmployeeContext: Gerencia funcionário logado globalmente
- ThemeProvider: Gerencia tema (claro/escuro)
- AppRouter: Gerencia navegação

# Estrutura de Dados
Nenhuma estrutura de dados específica.

# Regras de Negócio
- AuthWrapper é a rota inicial (/)
- Tema suporta modo claro e escuro
- Providers são globais para acesso em qualquer parte do app

# Pontos Críticos
- EmployeeContext é usado para auditoria e rastreamento de ações
- Tema é definido centralmente em AppTheme

# Melhorias Possíveis
- Adicionar splash screen inicial
- Implementar internacionalização (i18n)
- Adicionar analytics

# Observações Técnicas
- Usa Material Design 3 (useMaterial3: true)
- Title do app: "CheckOS"
- debugShowCheckedModeBanner: false para esconder banner de debug

