# login_page.dart
(c:/Projetos/checkos/lib/presentation/pages/login/login_page.dart)

# Descrição Geral
Página de login do aplicativo CheckOS. Gerencia autenticação de usuários existentes.

# Responsabilidade no Sistema
Permite que usuários existentes façam login no sistema com email e senha.

# Dependências
- checkos/core/constants/app_route_names.dart
- checkos/core/constants/app_strings.dart
- checkos/core/constants/login_strings.dart
- checkos/core/context/employee_context.dart
- checkos/data/models/employee/employee_model.dart
- checkos/data/repositories/employee_repository.dart
- checkos/services/firebase/auth_service.dart
- cloud_firestore
- firebase_auth
- flutter/material.dart
- provider
- shared_preferences

# Classes
- **LoginPage** (extends StatefulWidget)
  - Página de login

- **_LoginPageState** (State<LoginPage>)
  - Estado da página

# Propriedades
- _formKey: GlobalKey<FormState>
- _emailController: TextEditingController
- _passwordController: TextEditingController
- _authService: AuthService
- _isLoading: bool
- _errorMessage: String?
- _rememberMe: bool
- _isPasswordVisible: bool

# Métodos / Funções
- **initState()** - Carrega email salvo

- **_loadUserEmail()** (Future<void>)
  - Finalidade: Carregar email do SharedPreferences

- **_signIn()** (Future<void>)
  - Finalidade: Realizar login
  - Valida formulário
  - Chama AuthService.signInWithEmailAndPassword()
  - Busca EmployeeModel
  - Redireciona baseado no role

- **_forgotPassword()** (Future<void>)
  - Finalidade: Enviar email de redefinição de senha

- **build(BuildContext)** (Widget)
  - Campos: Email, Senha, Remember Me
  - Botões: Login, Esqueci a senha, Criar conta

# Fluxo de Execução
1. Usuário preenche email e senha
2. _signIn() valida e autentica
3. Busca EmployeeModel (employees → users fallback)
4. Verifica companyId
5. Se null → redireciona para CadastroEmpresa
6. Se válido → redireciona para Home

# Integração com o Sistema
- AuthService: Autenticação
- EmployeeRepository: Busca funcionário
- EmployeeContext: Armazena contexto
- SharedPreferences: Salva email

# Estrutura de Dados
- TextEditingControllers para campos
- SharedPreferences para "lembrar email"

# Regras de Negócio
- Remember Me salva email no dispositivo
- companyId null = onboarding obrigatório
- Fallback busca em users se não encontrar em employees

# Pontos Críticos
- Verifica companyId para redirecionamento
- Fallback entre coleções employees/users

# Melhorias Possíveis
- Adicionar login social (Google)
- Adicionar 2FA

