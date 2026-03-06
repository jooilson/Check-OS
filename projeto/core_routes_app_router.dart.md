# app_router.dart
(c:/Projetos/checkos/lib/core/routes/app_router.dart)

# Descrição Geral
Gerenciador centralizado de rotas da aplicação Flutter. Utiliza navegação por nome com MaterialPageRoute.

# Responsabilidade no Sistema
Este arquivo define todas as rotas da aplicação e fornece métodos helpers para navegação programática.

# Dependências
- flutter/material.dart
- checkos/data/models/os_model.dart
- checkos/data/models/employee/employee_model.dart
- checkos/presentation/pages/auth/auth_wrapper.dart
- checkos/presentation/pages/auth/auth_page.dart
- checkos/presentation/pages/register/register_page.dart
- checkos/presentation/pages/cadastro_empresa/cadastro_empresa_page.dart
- checkos/presentation/pages/detalhes_os_page.dart
- checkos/presentation/pages/employee_management/employee_management_page.dart
- checkos/presentation/pages/employee_management/employee_add_page.dart
- checkos/presentation/pages/home/home_page.dart
- checkos/presentation/pages/lista_page.dart
- checkos/presentation/pages/logs_page.dart
- checkos/presentation/pages/novaos_page.dart
- checkos/core/constants/app_route_names.dart

# Classes
- **AppRouter** (classe com construtor privado)
  - Gerenciador de rotas estático

# Métodos / Funções
- **generateRoute(RouteSettings settings)** (static Route<dynamic>)
  - Finalidade: Gerar rota baseada no nome da rota
  - Parâmetros: settings - configurações da rota
  - Retorno: MaterialPageRoute com a página correspondente
  - Comportamento: Switch nas rotas definidas em AppRouteNames

- **navigateTo(BuildContext, String, {Object? arguments})** (static void)
  - Finalidade: Navegação simples por nome
  - Parâmetros: context, routeName, arguments (opcional)

- **navigateAndReplace(BuildContext, String, {Object? arguments})** (static void)
  - Finalidade: Substituir rota atual (remove do stack)
  - Parâmetros: context, routeName, arguments (opcional)

- **navigateToHome(BuildContext)** (static void)
  - Finalidade: Ir para home limpando todo o stack de navegação
  - Parâmetros: context

- **goBack(BuildContext)** (static void)
  - Finalidade: Voltar para página anterior
  - Parâmetros: context

- **_buildPage(Widget, RouteSettings)** (static MaterialPageRoute)
  - Finalidade: Helper interno para construir páginas

# Fluxo de Execução
1. Navigator.pushNamed é chamado com routeName
2. generateRoute recebe RouteSettings
3. Switch identifica qual página instanciar
4. MaterialPageRoute é retornado com a página

# Integração com o Sistema
- AppRouteNames: Defines route name constants
- Pages: Instancia páginas específicas com argumentos
- OsModel/EmployeeModel: Usados como argumentos para rotas

# Estrutura de Dados
- RouteSettings: Wrapper Flutter para configurações de rota

# Regras de Negócio
- Rota não definida mostra Scaffold com mensagem de erro
- Argumentos são tipados para cada rota específica

# Pontos Críticos
- Argumentos devem ser passados corretamente (ex: OsModel, EmployeeModel)
- rotas precisam ter correspondência com AppRouteNames

# Melhorias Possíveis
- Implementar rota de erro 404
- Adicionar guards de autenticação
- Implementar.deep linking
- Adicionar animação de transição

# Observações Técnicas
- Usa MaterialPageRoute padrão
- Todas as rotas são singletons ( StatelessWidget sem estado)

