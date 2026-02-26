import 'package:flutter/material.dart';
import 'package:checkos/data/models/os_model.dart';
import 'package:checkos/presentation/pages/auth/auth_wrapper.dart';
import 'package:checkos/presentation/pages/detalhes_os_page.dart';
import 'package:checkos/presentation/pages/employee_management/employee_management_page.dart';
import 'package:checkos/presentation/pages/employee_management/employee_add_page.dart';
import 'package:checkos/presentation/pages/home/home_page.dart';
import 'package:checkos/presentation/pages/lista_page.dart';
import 'package:checkos/presentation/pages/logs_page.dart';
import 'package:checkos/presentation/pages/novaos_page.dart';
import '../constants/app_route_names.dart';

/// Gerenciador de rotas centralizado da aplicação.
/// Utilize AppRouteNames para os nomes das rotas.
class AppRouter {
  AppRouter._();

  /// Gera as rotas da aplicação com base no nome da rota.
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRouteNames.authWrapper:
        return _buildPage(const AuthWrapper(), settings);

      case AppRouteNames.home:
        return _buildPage(const HomePage(), settings);

      case AppRouteNames.novaOs:
        final osParaEditar = settings.arguments as OsModel?;
        return _buildPage(NovaOsPage(osParaEditar: osParaEditar), settings);

      case AppRouteNames.lista:
        return _buildPage(const ListaPage(), settings);

      case AppRouteNames.detalhesOs:
        final os = settings.arguments as OsModel;
        return _buildPage(DetalhesOsPage(os: os), settings);

      case AppRouteNames.logs:
        return _buildPage(const LogsPage(), settings);

      case AppRouteNames.employeeManagement:
        return _buildPage(const EmployeeManagementPage(), settings);

      case AppRouteNames.addEmployee:
        return _buildPage(const EmployeeAddPage(), settings);

      default:
        return _buildPage(
          Scaffold(
            body: Center(
              child: Text('Rota não definida: ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }

  /// Helper para construir páginas com MaterialPageRoute.
  static MaterialPageRoute<dynamic> _buildPage(
    Widget page,
    RouteSettings settings,
  ) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }

  /// Navegação por nome (conveniência).
  static void navigateTo(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  /// Navegação por nome com substituição (removestack).
  static void navigateAndReplace(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  /// Navegação para a página inicial (clear stack).
  static void navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouteNames.home,
      (route) => false,
    );
  }

  /// Voltar para a página anterior.
  static void goBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}

