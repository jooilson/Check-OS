/// Nomes das rotas da aplicação.
/// Utilize estas constantes para navegação.
/// Evita erros de digitação e facilita refatoração.
class AppRouteNames {
  AppRouteNames._();

  // ============================================
  // ROTAS PRINCIPAIS
  // ============================================
  static const String authWrapper = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';

  // ============================================
  // ROTAS DE OS
  // ============================================
  static const String novaOs = '/nova-os';
  static const String lista = '/lista';
  static const String detalhesOs = '/detalhes-os';
  static const String editOs = '/edit-os';

  // ============================================
  // ROTAS DE DIÁRIOS
  // ============================================
  static const String novoDiario = '/novo-diario';
  static const String editarDiario = '/editar-diario';

  // ============================================
  // ROTAS DE FUNCIONÁRIOS
  // ============================================
  static const String employeeManagement = '/employee-management';
  static const String addEmployee = '/add-employee';
  static const String editEmployee = '/edit-employee';

  // ============================================
  // ROTAS DE CONFIGURAÇÕES
  // ============================================
  static const String configuracoes = '/configuracoes';
  static const String logs = '/logs';
  static const String importExport = '/import-export';
}

