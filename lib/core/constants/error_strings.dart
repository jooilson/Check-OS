/// Strings de erros e validações do aplicativo.
class ErrorStrings {
  ErrorStrings._();

  // ============================================
  // ERROS GERAIS
  // ============================================
  static const String errorOccurred = 'Ocorreu um erro';
  static const String errorUnknown = 'Erro desconhecido';
  static const String errorUnexpected = 'Algo inesperado aconteceu';
  static const String tryAgainLater = 'Tente novamente mais tarde';
  static const String contactSupport = 'Entre em contato com o suporte';

  // ============================================
  // ERROS DE CONEXÃO
  // ============================================
  static const String errorConnection = 'Erro de conexão. Verifique sua internet.';
  static const String errorNetwork = 'Erro de rede';
  static const String errorTimeout = 'Tempo limite excedido';
  static const String noInternetConnection = 'Sem conexão com a internet';

  // ============================================
  // ERROS DE VALIDAÇÃO
  // ============================================
  static const String fieldRequired = 'Este campo é obrigatório';
  static const String fieldCannotBeEmpty = 'Este campo não pode estar vazio';
  static const String invalidEmail = 'E-mail inválido';
  static const String invalidPhone = 'Telefone inválido';
  static const String invalidNumber = 'Número inválido';
  static const String invalidDate = 'Data inválida';
  static const String passwordTooShort = 'A senha deve ter pelo menos 6 caracteres';
  static const String passwordMismatch = 'As senhas não coincidem';
  static const String minLength = 'Mínimo de {min} caracteres';
  static const String maxLength = 'Máximo de {max} caracteres';
  static const String valueTooSmall = 'Valor mínimo: {min}';
  static const String valueTooLarge = 'Valor máximo: {max}';

  // ============================================
  // ERROS DO FIREBASE AUTH
  // ============================================
  static const String userNotFound = 'Nenhum usuário encontrado para este e-mail.';
  static const String wrongPassword = 'Senha incorreta.';
  static const String invalidEmailFormat = 'O formato do e-mail é inválido.';
  static const String userDisabled = 'Este usuário foi desativado.';
  static const String operationNotAllowed = 'Login com e-mail/senha não está habilitado.';
  static const String weakPassword = 'A senha fornecida é muito fraca.';
  static const String emailAlreadyInUse = 'Uma conta já existe para este e-mail.';
  static const String invalidCredential = 'Credenciais inválidas.';
  static const String networkError = 'Erro de rede. Verifique sua conexão.';
  static const String tooManyAttempts = 'Muitas tentativas. Tente novamente mais tarde.';
  static const String popupClosed = 'Popup fechado antes de completar a operação.';
  static const String accountExists = 'Já existe uma conta com este e-mail.';

  // ============================================
  // ERROS DE BANCO DE DADOS
  // ============================================
  static const String errorLoadingData = 'Erro ao carregar dados';
  static const String errorSavingData = 'Erro ao salvar dados';
  static const String errorUpdatingData = 'Erro ao atualizar dados';
  static const String errorDeletingData = 'Erro ao excluir dados';
  static const String dataNotFound = 'Dados não encontrados';
  static const String duplicateEntry = 'Entrada duplicada';

  // ============================================
  // ERROS DE UPLOAD/ARQUIVOS
  // ============================================
  static const String errorUploading = 'Erro ao enviar arquivo';
  static const String errorDownloading = 'Erro ao baixar arquivo';
  static const String errorReadingFile = 'Erro ao ler arquivo';
  static const String fileNotFound = 'Arquivo não encontrado';
  static const String fileTooLarge = 'Arquivo muito grande';
  static const String invalidFileType = 'Tipo de arquivo inválido';
  static const String uploadFailed = 'Falha no upload';

  // ============================================
  // ERROS DE PERMISSÃO
  // ============================================
  static const String permissionDenied = 'Permissão negada';
  static const String permissionDeniedCamera = 'Permissão de câmera negada';
  static const String permissionDeniedStorage = 'Permissão de armazenamento negada';
  static const String permissionDeniedLocation = 'Permissão de localização negada';

  // ============================================
  // ERROS DE SERVIÇOS EXTERNOS
  // ============================================
  static const String firebaseError = 'Erro no Firebase';
  static const String firebaseInitError = 'Erro ao inicializar Firebase';
  static const String storageError = 'Erro no armazenamento';
  static const String authError = 'Erro de autenticação';
}

