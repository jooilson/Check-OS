/// Strings específicas para autenticação (login/register).
class AuthStrings {
  AuthStrings._();

  // ============================================
  // TÍTULOS
  // ============================================
  static const String loginTitle = 'Login';
  static const String registerTitle = 'Criar Conta';
  static const String welcomeTitle = 'Bem-vindo!';
  static const String welcomeSubtitle = 'Faça login para continuar';

  // ============================================
  // CAMPOS
  // ============================================
  static const String emailLabel = 'E-mail';
  static const String emailHint = 'email@exemplo.com';
  static const String passwordLabel = 'Senha';
  static const String confirmPasswordLabel = 'Confirmar Senha';

  // ============================================
  // BOTÕES
  // ============================================
  static const String loginButton = 'Entrar';
  static const String registerButton = 'Criar Conta';
  static const String forgotPasswordButton = 'Esqueci minha senha';
  static const String rememberMe = 'Lembrar-me';
  static const String switchToRegister = 'Não tem uma conta? Crie uma agora!';
  static const String switchToLogin = 'Já tem uma conta? Faça login!';
  static const String createNow = 'Crie agora';
  static const String loginNow = 'Faça login';

  // ============================================
  // VALIDADORES
  // ============================================
  static const String emailRequired = 'Por favor, insira seu e-mail.';
  static const String emailInvalid = 'Por favor, insira um e-mail válido.';
  static const String passwordRequired = 'Por favor, insira sua senha.';
  static const String passwordTooShort = 'A senha deve ter pelo menos 6 caracteres.';
  static const String confirmPasswordRequired = 'Por favor, confirme sua senha.';
  static const String passwordMismatch = 'As senhas não coincidem.';

  // ============================================
  // MENSAGENS DE FEEDBACK
  // ============================================
  static const String loginSuccess = 'Login realizado com sucesso!';
  static const String registerSuccess = 'Conta criada com sucesso!';
  static const String resetEmailSent = 'E-mail de redefinição de senha enviado!';
  static const String loginErrorDefault = 'Erro de login. Verifique suas credenciais.';
  static const String registerErrorDefault = 'Erro ao criar conta. Tente novamente.';
  static const String forgotPasswordEmailSent = 'Link para redefinição de senha enviado para seu email.';

  // ============================================
  // ERROS DO FIREBASE AUTH
  // ============================================
  static const String userNotFound = 'Nenhum usuário encontrado para este e-mail.';
  static const String wrongPassword = 'Senha incorreta.';
  static const String invalidEmail = 'O formato do e-mail é inválido.';
  static const String userDisabled = 'Este usuário foi desativado.';
  static const String operationNotAllowed = 'Login com e-mail/senha não está habilitado.';
  static const String weakPassword = 'A senha fornecida é muito fraca.';
  static const String emailAlreadyInUse = 'Uma conta já existe para este e-mail.';
  static const String invalidCredential = 'Credenciais inválidas.';
  static const String networkError = 'Erro de rede. Verifique sua conexão.';
  static const String tooManyAttempts = 'Muitas tentativas. Tente novamente mais tarde.';

  // ============================================
  // ESQUECI MINHA SENHA
  // ============================================
  static const String forgotPasswordTitle = 'Recuperar Senha';
  static const String forgotPasswordMessage = 'Digite seu email para receber o link de redefinição.';
  static const String forgotPasswordEmailEmpty = 'Digite seu email para redefinir a senha.';
  static const String forgotPasswordEmailNotFound = 'Nenhum usuário encontrado com este email.';

  // ============================================
  // LOGOUT
  // ============================================
  static const String logoutTitle = 'Sair';
  static const String logoutMessage = 'Tem certeza que deseja sair da sua conta?';
  static const String logoutConfirm = 'Sair';
  static const String logoutSuccess = 'Logout realizado com sucesso!';
}

