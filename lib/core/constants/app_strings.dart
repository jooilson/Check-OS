/// Strings comuns utilizadas em toda a aplicação.
/// Strings genéricas que não pertencem a um módulo específico.
class AppStrings {
  AppStrings._();

  // ============================================
  // TÍTULOS GERAIS
  // ============================================
  static const String appName = 'CheckOS';
  static const String appTitle = 'CheckOS - Gestão de OS';
  static const String welcome = 'Bem-vindo!';
  static const String welcomeBack = 'Olá!';
  static const String goodbye = 'Até mais!';

  // ============================================
  // SUBTÍTULOS
  // ============================================
  static const String loginSubtitle = 'Faça login para continuar';
  static const String registerSubtitle = 'Crie sua conta para começar';
  static const String welcomeSubtitle = 'Bem-vindo de volta!';

  // ============================================
  // BOTÕES
  // ============================================
  static const String save = 'Salvar';
  static const String cancel = 'Cancelar';
  static const String delete = 'Excluir';
  static const String confirm = 'Confirmar';
  static const String edit = 'Editar';
  static const String view = 'Visualizar';
  static const String add = 'Adicionar';
  static const String remove = 'Remover';
  static const String close = 'Fechar';
  static const String back = 'Voltar';
  static const String next = 'Próximo';
  static const String previous = 'Anterior';
  static const String search = 'Buscar';
  static const String filter = 'Filtrar';
  static const String sort = 'Ordenar';
  static const String refresh = 'Atualizar';
  static const String retry = 'Tentar novamente';
  static const String yes = 'Sim';
  static const String no = 'Não';
  static const String ok = 'OK';

  // ============================================
  // AÇÕES
  // ============================================
  static const String saveChanges = 'Salvar alterações';
  static const String discardChanges = 'Descartar alterações';
  static const String exitPage = 'Sair da página';
  static const String confirmDelete = 'Confirmar exclusão';
  static const String confirmAction = 'Confirmar ação';
  static const String generatePdf = 'Gerar PDF';
  static const String exportData = 'Exportar dados';
  static const String importData = 'Importar dados';

  // ============================================
  // LABELS
  // ============================================
  static const String email = 'E-mail';
  static const String password = 'Senha';
  static const String confirmPassword = 'Confirmar Senha';
  static const String name = 'Nome';
  static const String phone = 'Telefone';
  static const String address = 'Endereço';
  static const String description = 'Descrição';
  static const String notes = 'Observações';
  static const String date = 'Data';
  static const String time = 'Hora';
  static const String status = 'Status';
  static const String actions = 'Ações';
  static const String details = 'Detalhes';
  static const String settings = 'Configurações';

  // ============================================
  // MENSAGENS GERAIS
  // ============================================
  static const String loading = 'Carregando...';
  static const String noDataFound = 'Nenhum dado encontrado';
  static const String noResults = 'Nenhum resultado encontrado';
  static const String errorOccurred = 'Ocorreu um erro';
  static const String tryAgainLater = 'Tente novamente mais tarde';
  static const String success = 'Operação realizada com sucesso';
  static const String operationSuccess = 'Operação realizada com sucesso!';
  static const String operationFailed = 'Falha na operação';
  static const String waitMoment = 'Aguarde um momento...';
  static const String processing = 'Processando...';

  // ============================================
  // PERGUNTAS DE CONFIRMAÇÃO
  // ============================================
  static const String confirmExit = 'Sair da página?';
  static const String confirmExitMessage =
      'As alterações não salvas serão perdidas. Deseja continuar?';
  static const String confirmDeleteTitle = 'Confirmar Exclusão';
  static const String confirmDeleteMessage =
      'Tem certeza que deseja excluir este item? Esta ação não pode ser desfeita.';
  static const String confirmDeleteMultipleMessage =
      'Tem certeza que deseja excluir {count} item(ns) selecionado(s)? Esta ação não pode ser desfeita.';

  // ============================================
  // VALIDAÇÕES
  // ============================================
  static const String fieldRequired = 'Este campo é obrigatório';
  static const String invalidEmail = 'E-mail inválido';
  static const String invalidPhone = 'Telefone inválido';
  static const String passwordTooShort = 'A senha deve ter pelo menos 6 caracteres';
  static const String passwordMismatch = 'As senhas não coincidem';
  static const String minLength = 'Mínimo de {min} caracteres';
  static const String maxLength = 'Máximo de {max} caracteres';

  // ============================================
  // TÍTULOS DE SEÇÕES
  // ============================================
  static const String basicInfo = 'Informações Básicas';
  static const String additionalInfo = 'Informações Adicionais';
  static const String personalInfo = 'Informações Pessoais';
  static const String workInfo = 'Informações Profissionais';

  // ============================================
  // STATUS
  // ============================================
  static const String osfinalizado = 'Finalizado';
  static const String pending = 'Pendente';
  static const String inProgress = 'Em andamento';
  static const String cancelled = 'Cancelado';
  static const String awaiting = 'Aguardando';
  static const String approved = 'Aprovado';
  static const String rejected = 'Rejeitado';

  // ============================================
  // NAVEGAÇÃO
  // ============================================
  static const String home = 'Início';
  static const String list = 'Lista';
  static const String newRecord = 'Novo';
  static const String configuration = 'Configurações';

  // ============================================
  // FEEDBACKS
  // ============================================
  static const String savedSuccessfully = 'Salvo com sucesso!';
  static const String updatedSuccessfully = 'Atualizado com sucesso!';
  static const String deletedSuccessfully = 'Excluído com sucesso!';
  static const String createdSuccessfully = 'Criado com sucesso!';
  static const String sentSuccessfully = 'Enviado com sucesso!';
  static const String copiedSuccessfully = 'Copiado para a área de transferência!';

  // ============================================
  // ERROS
  // ============================================
  static const String errorSaving = 'Erro ao salvar';
  static const String errorUpdating = 'Erro ao atualizar';
  static const String errorDeleting = 'Erro ao excluir';
  static const String errorLoading = 'Erro ao carregar dados';
  static const String errorSending = 'Erro ao enviar';
  static const String errorConnection = 'Erro de conexão. Verifique sua internet.';
  static const String errorUnknown = 'Erro desconhecido';

  // ============================================
  // LISTAS
  // ============================================
  static const String selectAll = 'Selecionar Todos';
  static const String deselectAll = 'Desselecionar Todos';
  static const String selected = 'selecionado(s)';
  static const String items = 'item(ns)';
  static const String totalItems = 'Total: {count} item(ns)';
  static const String noItemsSelected = 'Nenhum item selecionado';
}

