# Mapa de Rotas - CheckOS

## Visão Geral

Este documento detalha todas as rotas utilizadas no projeto CheckOS, incluindo o sistema de navegação, rotas protegidas e redirecionamentos.

---

## 1. SISTEMA DE ROTAS

### 1.1 Tipo de Navegação

O projeto utiliza **MaterialApp com Navigator 1.0** (Navegação imperativa).

```dart
// Em app.dart
MaterialApp(
  initialRoute: AppRouteNames.authWrapper,
  onGenerateRoute: AppRouter.generateRoute,
)
```

### 1.2 Arquivos Relacionados

| Arquivo | Responsabilidade |
|---------|-----------------|
| `lib/core/constants/app_route_names.dart` | Definição de nomes das rotas |
| `lib/core/routes/app_router.dart` | Gerador de rotas |
| `lib/app.dart` | Configuração do MaterialApp |

---

## 2. DEFINIÇÃO DE ROTAS

### 2.1 AppRouteNames

```dart
// lib/core/constants/app_route_names.dart

class AppRouteNames {
  AppRouteNames._();

  // ROTAS PRINCIPAIS
  static const String authWrapper = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';

  // ROTAS DE OS
  static const String novaOs = '/nova-os';
  static const String lista = '/lista';
  static const String detalhesOs = '/detalhes-os';
  static const String editOs = '/edit-os';

  // ROTAS DE DIÁRIOS
  static const String novoDiario = '/novo-diario';
  static const String editarDiario = '/editar-diario';

  // ROTAS DE FUNCIONÁRIOS
  static const String employeeManagement = '/employee-management';
  static const String addEmployee = '/add-employee';
  static const String editEmployee = '/edit-employee';

  // ROTAS DE CONFIGURAÇÕES
  static const String configuracoes = '/configuracoes';
  static const String logs = '/logs';
  static const String importExport = '/import-export';

  // ROTAS DE CADASTRO EMPRESA
  static const String cadastroEmpresa = '/cadastro-empresa';
}
```

---

## 3. LISTA COMPLETA DE ROTAS

### 3.1 Tabela de Rotas

| Rota | Caminho | Arquivo | Tipo | Proteção |
|------|---------|---------|------|----------|
| authWrapper | `/` | auth_wrapper.dart | Público | ✗ |
| login | `/login` | auth_page.dart | Público | ✗ |
| register | `/register` | register_page.dart | Público | ✗ |
| home | `/home` | home_page.dart | Protegido | ✓ |
| lista | `/lista` | lista_page.dart | Protegido | ✓ |
| novaOs | `/nova-os` | novaos_page.dart | Protegido | ✓ |
| detalhesOs | `/detalhes-os` | detalhes_os_page.dart | Protegido | ✓ |
| editOs | `/edit-os` | novaos_page.dart | Protegido | ✓ |
| novoDiario | `/novo-diario` | novo_diario_page.dart | Protegido | ✓ |
| editarDiario | `/editar-diario` | editar_diario_page.dart | Protegido | ✓ |
| employeeManagement | `/employee-management` | employee_management_page.dart | Protegido | ✓ |
| addEmployee | `/add-employee` | employee_add_page.dart | Protegido | ✓ |
| editEmployee | `/edit-employee` | employee_add_page.dart | Protegido | ✓ |
| configuracoes | `/configuracoes` | config_page.dart | Protegido | ✓ |
| logs | `/logs` | logs_page.dart | Protegido | ✓ |
| importExport | `/import-export` | import_export_page.dart | Protegido | ✓ |
| cadastroEmpresa | `/cadastro-empresa` | cadastro_empresa_page.dart | Protegido | ✓ |

---

## 4. GERADOR DE ROTAS

### 4.1 AppRouter.generateRoute

```dart
// lib/core/routes/app_router.dart

static Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRouteNames.authWrapper:
      return _buildPage(const AuthWrapper(), settings);

    case AppRouteNames.login:
      return _buildPage(const AuthPage(), settings);

    case AppRouteNames.register:
      return _buildPage(RegisterPage(showLoginPage: () {}), settings);

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
      
    // ... outras rotas
  }
}
```

---

## 5. NAVEGAÇÃO

### 5.1 Métodos de Navegação

```dart
// Navegação por nome
Navigator.pushNamed(context, routeName);

// Navegação por nome com argumentos
Navigator.pushNamed(context, routeName, arguments: data);

// Navegação com substituição
Navigator.pushReplacementNamed(context, routeName);

// Navegação e remoção de stack
Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);

// Voltar
Navigator.pop(context);
```

### 5.2 Métodos de Convenience no AppRouter

```dart
// Navegação por nome
static void navigateTo(BuildContext context, String routeName, {Object? arguments})

// Navegação com substituição
static void navigateAndReplace(BuildContext context, String routeName, {Object? arguments})

// Navegação para home (clear stack)
static void navigateToHome(BuildContext context)

// Voltar
static void goBack(BuildContext context)
```

---

## 6. ARGUMENTOS DAS ROTAS

### 6.1 Rotas com Argumentos

| Rota | Tipo de Argumento | Descrição |
|------|-------------------|------------|
| novaOs | `OsModel?` | OS para editar (null = nova OS) |
| detalhesOs | `OsModel` | OS a ser visualizada |
| addEmployee | `EmployeeModel?` | Funcionário para editar |
| editEmployee | `EmployeeModel` | Funcionário a editar |

### 6.2 Passando Argumentos

```dart
// Enviando
Navigator.pushNamed(
  context,
  AppRouteNames.detalhesOs,
  arguments: osModel,
);

// Recebendo
final os = settings.arguments as OsModel;
```

---

## 7. FLUXO DE NAVEGAÇÃO

### 7.1 Fluxo Inicial

```
App inicia
    │
    ▼
MaterialApp (initialRoute: /)
    │
    ▼
AuthWrapper (/)
    │
    ├── Não autenticado → AuthPage (/login)
    │                           │
    │                           └── RegisterPage (/register)
    │
    └── Autenticado
            │
            ├── Sem empresa → CadastroEmpresaPage (/cadastro-empresa)
            │
            └── Com empresa → HomePage (/home)
```

### 7.2 Fluxo de OS

```
HomePage
    │
    ├── ListaPage (/lista)
    │       │
    │       ├── DetalhesOsPage (/detalhes-os)
    │       │       │
    │       │       ├── NovoDiarioPage (/novo-diario)
    │       │       │
    │       │       └── EditarDiarioPage (/editar-diario)
    │       │
    │       └── NovaOsPage (/nova-os)
    │               │
    │               └── DetalhesOsPage (/detalhes-os)
```

### 7.3 Fluxo de Funcionários

```
HomePage
    │
    └── EmployeeManagementPage (/employee-management)
            │
            └── EmployeeAddPage (/add-employee)
```

### 7.4 Fluxo de Configurações

```
HomePage
    │
    └── ConfigPage (/configuracoes)
            │
            ├── LogsPage (/logs)
            │
            └── ImportExportPage (/import-export)
```

---

## 8. PROTEÇÃO DE ROTAS

### 8.1 Proteção Atual

**PROBLEMA**: Não há proteção formal de rotas no código.

As rotas são "protegidas" indiretamente:
- AuthWrapper redireciona para login se não autenticado
- AuthWrapper redireciona para cadastro se não tem empresa

### 8.2 Rota Protegida Ideal

Deveria existir um sistema assim:

```dart
// Exemplo de proteção
case AppRouteNames.home:
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return _buildPage(const AuthPage(), settings);
  }
  return _buildPage(const HomePage(), settings);
```

### 8.3 Acesso Direto por URL

**PROBLEMA**: Qualquer rota pode ser acessada diretamente via URL.

Exemplo: `/home` pode ser acessado sem login.

---

## 9. REDIRECIONAMENTOS

### 9.1 Redirecionamentos Automáticos

| De | Para | Condição |
|----|------|----------|
| AuthWrapper | AuthPage | Não autenticado |
| AuthWrapper | CadastroEmpresaPage | Autenticado + sem empresa |
| AuthWrapper | HomePage | Autenticado + com empresa |

### 9.2 Após Ações

| Ação | Redirecionamento |
|------|------------------|
| Login sucesso | HomePage |
| Registro sucesso | HomePage |
| Logout | AuthPage |
| Criar empresa | HomePage |

---

## 10. BACK BUTTON

### 10.1 Comportamento Padrão

```dart
// Botão voltar nativo do Android
// Chama Navigator.pop(context)
```

### 10.2 Customização

O AppRouter tem método `goBack`:

```dart
static void goBack(BuildContext context) {
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  }
}
```

---

## 11. ANIMAÇÕES

### 11.1 Tipo de Transição

O projeto usa **MaterialPageRoute** com transição padrão do Material:

```dart
static MaterialPageRoute<dynamic> _buildPage(
  Widget page,
  RouteSettings settings,
) {
  return MaterialPageRoute(
    builder: (_) => page,
    settings: settings,
  );
}
```

### 11.2 Animações Disponíveis

- Slide (padrão Material)
- Fade (customizável)
- Slide vertical (customizável)

---

## 12. PROBLEMAS IDENTIFICADOS

### 12.1 Rotas Duplicadas

- `/login` e `/` (AuthWrapper) podem causar confusão
- AuthPage e LoginPage fazem a mesma coisa

### 12.2 Falta de Guarda de Rotas

- Não há verificação antes de acessar rotas protegidas
- Usuário pode digitar URL diretamente

### 12.3 Args Null Safety

- `settings.arguments as OsModel?` pode falhar
- Não há verificação de tipo

---

## 13. MELHORIAS RECOMENDADAS

### 13.1 Implementar Route Guard

```dart
class AuthGuard extends StatelessWidget {
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return AuthPage();
        }
        return child;
      },
    );
  }
}
```

### 13.2 Usar Arguments de Forma Segura

```dart
case AppRouteNames.detalhesOs:
  final args = settings.arguments;
  if (args == null || args is! OsModel) {
    return _buildPage(const ListaPage(), settings);
  }
  return _buildPage(DetalhesOsPage(os: args), settings);
```

### 13.3 Considerar GoRouter

Para projetos maiores, considerar usar **go_router**:
- Suporte a rotas protegidas
- Redirecionamento Declarativo
- Deep linking
- Parsing de argumentos automático

---

## 14. RESUMO DE ROTAS

| # | Rota | Caminho | Protegida |
|---|------|---------|-----------|
| 1 | authWrapper | `/` | ✗ |
| 2 | login | `/login` | ✗ |
| 3 | register | `/register` | ✗ |
| 4 | home | `/home` | ✓ |
| 5 | lista | `/lista` | ✓ |
| 6 | novaOs | `/nova-os` | ✓ |
| 7 | detalhesOs | `/detalhes-os` | ✓ |
| 8 | novoDiario | `/novo-diario` | ✓ |
| 9 | editarDiario | `/editar-diario` | ✓ |
| 10 | employeeManagement | `/employee-management` | ✓ |
| 11 | addEmployee | `/add-employee` | ✓ |
| 12 | configuracoes | `/configuracoes` | ✓ |
| 13 | logs | `/logs` | ✓ |
| 14 | importExport | `/import-export` | ✓ |
| 15 | cadastroEmpresa | `/cadastro-empresa` | ✓ |

