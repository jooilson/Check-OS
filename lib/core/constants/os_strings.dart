/// Strings específicas para Ordens de Serviço (OS).
class OsStrings {
  OsStrings._();

  // ============================================
  // TÍTULOS
  // ============================================
  static const String novaOs = 'Nova OS';
  static const String editarOs = 'Editar OS';
  static const String detalhesOs = 'Detalhes da OS';
  static const String listaOs = 'Lista de OS';
  static const String semOs = 'Nenhuma OS encontrada';
  static const String osTitle = 'OS';

  // ============================================
  // CAMPOS
  // ============================================
  static const String numeroOs = 'Nú da OS';
  static const String nomeCliente = 'Nome do Cliente';
  static const String servico = 'Serviço';
  static const String relatoCliente = 'Relato do Cliente';
  static const String responsavel = 'Responsável';
  static const String numeroPedido = 'Número do Pedido';
  static const String temPedido = 'OS com Pedido';

  // ============================================
  // CAMPOS DE KM
  // ============================================
  static const String kmInicial = 'KM Inicial';
  static const String kmFinal = 'KM Final';
  static const String kmPercorrido = 'KM Percorrido';

  // ============================================
  // CAMPOS DE HORÁRIO
  // ============================================
  static const String horaInicio = 'Hora de Início';
  static const String horaTermino = 'Hora de Término';
  static const String intervaloInicio = 'Início do Intervalo';
  static const String intervaloFim = 'Fim do Intervalo';

  // ============================================
  // STATUS
  // ============================================
  static const String osfinalizado = 'Finalizado';
  static const String garantia = 'Garantia';
  static const String pendente = 'Pendente';
  static const String emAndamento = 'Em andamento';

  // ============================================
  // STATUS (para display)
  // ============================================
  static const String statusFinalizado = 'Finalizado';
  static const String statusPendente = 'Pendente';
  static const String statusEmAndamento = 'Em andamento';

  // ============================================
  // RELATÓRIOS
  // ============================================
  static const String relatoTecnico = 'Relato Técnico / Atividades Realizadas';
  static const String pendenteDescricao = 'Descrição da Pendência';
  static const String assinatura = 'Assinatura';
  static const String limparAssinatura = 'Limpar Assinatura';
  static const String imagens = 'Imagens Anexadas';
  static const String anexarImagens = 'Anexar Imagens';

  // ============================================
  // FUNCIONÁRIOS
  // ============================================
  static const String funcionarios = 'Funcionários';
  static const String adicionarFuncionario = 'Adicionar Funcionário';
  static const String removerFuncionario = 'Remover Funcionário';
  static const String nomeFuncionario = 'Nome do Funcionário';

  // ============================================
  // SEÇÕES DO FORMULÁRIO
  // ============================================
  static const String informacoesBasicas = 'Informações Básicas';
  static const String informacoesHorarioKm = 'Horários e KM';
  static const String statusServico = 'Status do Serviço';
  static const String dadosOs = 'Dados da Ordem de Serviço';

  // ============================================
  // AÇÕES
  // ============================================
  static const String salvarOs = 'Salvar OS';
  static const String atualizarOs = 'Atualizar OS';
  static const String excluirOs = 'Excluir OS';
  static const String gerarPdf = 'Gerar PDF';
  static const String editarOsBtn = 'Editar OS';
  static const String visualizarDiarios = 'Visualizar Diários';

  // ============================================
  // VALIDAÇÕES
  // ============================================
  static const String numeroOsObrigatorio = 'O número da OS é obrigatório';
  static const String numeroOsDuplicado = 'Já existe uma OS com este número.';
  static const String clienteObrigatorio = 'O nome do cliente é obrigatório';
  static const String servicoObrigatorio = 'O serviço é obrigatório';

  // ============================================
  // MENSAGENS
  // ============================================
  static const String osSalvaSucesso = 'OS salva com sucesso!';
  static const String osAtualizadaSucesso = 'OS atualizada com sucesso!';
  static const String osExcluidaSucesso = 'OS excluída com sucesso!';
  static const String osExcluidaMultiplosSucesso = '{count} OS(s) excluída(s) com sucesso.';
  static const String erroSalvarOs = 'Erro ao salvar OS';
  static const String erroCarregarOs = 'Erro ao carregar OS';

  // ============================================
  // DIÁLOGOS
  // ============================================
  static const String confirmarExclusaoOs = 'Confirmar Exclusão';
  static const String confirmarExclusaoOsMensagem = 'Tem certeza que deseja excluir esta OS?';
  static const String confirmarExclusaoMultiplosMensagem = 
      'Tem certeza que deseja excluir {count} OS(s) selecionada(s)? Esta ação não pode ser desfeita e excluirá todos os diários associados.';

  // ============================================
  // ORDENAÇÃO
  // ============================================
  static const String ordenarPorNumero = 'Ordenar por Número da OS';
  static const String ordenarPorDataCriacao = 'Ordenar por Data de Criação';
  static const String ordenarPorAtualizacao = 'Ordenar por Última Modificação';

  // ============================================
  // INFORMAÇÕES ADICIONAIS
  // ============================================
  static const String modificado = 'Modificado';
  static const String criado = 'Criado em';
  static const String pedido = 'Pedido';
}

