import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:checkos/data/models/os_model.dart';
import 'package:checkos/data/models/diario_model.dart';
import 'package:checkos/services/logo_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:async' show Future;
import 'package:image/image.dart' as img;

/// Classe utilitária para centralizar toda a lógica de geração de PDFs.
/// Todos os métodos são estáticos para que possam ser chamados diretamente,
/// sem a necessidade de instanciar a classe. Ex: `GerarPdf.gerarPdfCompleto(...)`.
class GerarPdf {
  // --- FUNÇÕES DE GERAÇÃO PRINCIPAIS ---

  /// PONTO DE ENTRADA PRINCIPAL.
  /// Gera um PDF completo para uma Ordem de Serviço (OS) e sua lista de diários.
  /// 
  /// ESTRUTURA DO PDF:
  /// 1. Cabeçalho (em todas as páginas): Logo, título da OS e número da OS
  /// 2. Seção de Dados Gerais: Cliente, serviço, responsável, KM, horários, equipe
  /// 3. Seção de Relatos: Relato do cliente e relato técnico inicial
  /// 4. Seção de Status: Indicadores de osfinalizado, garantia, pendente
  /// 5. Assinatura do Cliente: Imagem da assinatura (se disponível)
  /// 6. Imagens da OS Principal: Galeria de fotos da OS
  /// 7. Histórico de Atendimentos: Cada diário com suas informações
  /// 8. Imagens dos Diários: Fotos de cada diário
  /// 9. Relatório de KM: Resumo e detalhamento de quilometragem
  /// 10. Rodapé (em todas as páginas): Data de geração e paginação
  ///
  /// @param os O objeto `OsModel` com os dados da Ordem de Serviço
  ///           Campos principais: numeroOs, nomeCliente, servico, responsavel, 
  ///           relatoCliente, relatoTecnico, kmInicial, kmFinal, imagens, assinatura
  /// @param diarios Uma lista de `DiarioModel` associados à OS (pode estar vazia)
  ///                Campos principais: numeroDiario, data, relatoTecnico, relatoCliente,
  ///                horaInicio, horaTermino, kmInicial, kmFinal, imagens, assinatura
  /// 
  /// FLUXO DE EXECUÇÃO:
  /// 1. Cria um novo documento PDF
  /// 2. Ordena os diários por número para garantir sequência correta
  /// 3. Converte a assinatura da OS de string para imagem
  /// 4. Coleta e prepara todas as imagens (da OS e dos diários)
  /// 5. Carrega o logo da empresa do serviço de armazenamento
  /// 6. Converte assinaturas dos diários para imagens
  /// 7. Constrói uma MultiPage com todo o conteúdo
  /// 8. Exibe o PDF na tela de pré-visualização/impressão
  static Future<void> gerarPdfCompleto(
      OsModel os, List<DiarioModel> diarios) async {
    // Validação de entrada
    if (os.numeroOs.isEmpty) {
      throw ArgumentError('O número da OS não pode ser vazio');
    }
    
    final pdf = pw.Document(compress: true,);
    // Formatters criados uma única vez para melhor performance
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final timeFormatter = DateFormat('HH:mm');
    final now = DateTime.now();


    // Ordena os diários numericamente para garantir a sequência correta (ex: Diário #2, #3, #4...)
    // Importante: sem essa ordenação, a numeração pode ficar desordenada se virem de uma lista aleatória
    // Esta ordenação é usada em todo o documento, então feita uma única vez aqui
    diarios.sort((a, b) => a.numeroDiario.compareTo(b.numeroDiario));

    // Processa a assinatura da OS:
    // - Se a assinatura não está vazia, converte a string serializada em uma imagem PNG
    // - A string de assinatura contém coordenadas dos pontos desenhados (ex: "10.0,20.5;11.2,22.0;null;...")
    // - Retorna null se não houver assinatura (a seção será omitida do PDF)
    final signatureImageBytes = os.assinatura != null && os.assinatura!.isNotEmpty
        ? await _generateSignatureImage(os.assinatura!)
        : null;
    final signatureImage =
        signatureImageBytes != null ? pw.MemoryImage(signatureImageBytes) : null;

    // Processa todas as imagens do relatório:
    // 1. _collectAllImages: Agrupa os caminhos das imagens por origem (OS ou Diário)
    // 2. _prepareImages: 
    //    - Lê os arquivo de imagem do disco
    //    - Converte para bytes e depois para pw.MemoryImage (formato do pacote pdf)
    //    - Extrai o nome do arquivo para exibir abaixo de cada imagem
    //    - Retorna um mapa: {"OS Principal": [...], "Diário #2": [...], ...}
    final allImagePaths = _collectAllImages(os, diarios);
    final allImageData = await _prepareImages(allImagePaths);
    
    // Carrega o logo da empresa para exibir no cabeçalho do PDF:
    // - LogoService.getLogoFile() busca o arquivo de logo armazenado
    // - Se não existir, o cabeçalho exibirá um placeholder cinza com "Logo"
    // - Se encontrado, converte para pw.MemoryImage para ser exibido no PDF
    // - O logo aparecerá em todas as páginas do PDF (via _buildHeader)
    pw.ImageProvider? logoImage;
    final logoFile = await LogoService.getLogoFile();
    if (logoFile != null) {
      final logoBytes = await logoFile.readAsBytes();
      logoImage = pw.MemoryImage(logoBytes);
    }
    
    // Processa as assinaturas de cada diário:
    // - Para cada diário com assinatura válida, converte a string em imagem
    // - Armazena em um mapa usando o ID do diário como chave
    // - Será usada posteriormente em _buildDiarioItem para exibir a assinatura
    // - Se um diário não tiver assinatura, não aparecerá nesta seção do PDF
    final Map<String, pw.ImageProvider> diarioSignatureImages = {};
    for (final diario in diarios) {
      if (diario.assinatura != null && diario.assinatura!.isNotEmpty) {
        final bytes = await _generateSignatureImage(diario.assinatura!);
        if (bytes != null) {
          diarioSignatureImages[diario.id] = pw.MemoryImage(bytes);
        }
      }
    }

    // --- CONSTRUÇÃO DO DOCUMENTO PDF ---
    // Adiciona uma única MultiPage (página com múltiplas subpáginas) que conterá todo o relatório.
    // Vantagens desta abordagem:
    // - O conteúdo flui naturalmente entre as páginas (sem quebras forçadas)
    // - O cabeçalho e rodapé são consistentes em TODAS as páginas
    // - A paginação é automática ("Página X de Y")
    // - Mais fácil de manter e editar do que múltiplas páginas separadas
    // 
    // ORDEM DO CONTEÚDO (modificável alterando a ordem dos widgets abaixo):
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        // O cabeçalho é consistente em todo o documento.
        header: (context) => _buildHeader(os, logoImage: logoImage),
        // O rodapé também é consistente.
        footer: (context) => _buildFooter(now, context.pageNumber, context.pagesCount),
        build: (context) => [
          // Seção de Informações da OS
          _buildOsInfoSection(os, dateFormatter),
          pw.SizedBox(height: 15),
          _buildReportsSection(os),
          pw.SizedBox(height: 15),
          _buildStatusSection(os),
          pw.SizedBox(height: 20),
          if (signatureImage != null) _buildSignatureSection(signatureImage),

          // Imagens da OS Principal
          if (allImageData.containsKey('OS Principal'))
            _buildInlineImages(allImageData['OS Principal']!, title: 'Imagens da OS Principal'),

          // Seção de Diários
          if (diarios.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            _buildSectionHeader('Histórico de Atendimentos'),
            pw.SizedBox(height: 5),
            ...diarios.map((diario) {
              final diarioKey = 'Diário #${diario.numeroDiario.toStringAsFixed(1)}';
              final diarioImages = allImageData[diarioKey];
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildDiarioItem(diario, dateFormatter, timeFormatter, diarioSignatureImages[diario.id]),
                  if (diarioImages != null && diarioImages.isNotEmpty)
                    _buildInlineImages(diarioImages, title: 'Imagens do $diarioKey'),
                ],
              );
            }),
          ],
          
          // Seção de Relatório de KM Percorrido (NO FINAL DO PDF)
          pw.SizedBox(height: 20),
          _buildKmReportSection(os, diarios),
        ],
      ),
    );

    // Usa o plugin `printing` para exibir a tela de pré-visualização e impressão do PDF.
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
  
  // --- Funções antigas mantidas por compatibilidade ---
  // Elas agora simplesmente chamam a nova função principal `gerarPdfCompleto`.

  /// Gera o PDF apenas com os dados da OS (sem diários).
  static Future<void> generateOsPdf(OsModel os) async {
    await gerarPdfCompleto(os, []);
  }

  /// Gera o PDF apenas com a lista de diários.
  static Future<void> generateDiariosPdf(List<DiarioModel> diarios, String numeroOs, String nomeCliente) async {
    // Cria um modelo de OS "falso" apenas para preencher o cabeçalho do PDF.
    final os = OsModel(id: '', numeroOs: numeroOs, nomeCliente: nomeCliente, servico: '', relatoCliente: '', responsavel: '');
     await gerarPdfCompleto(os, diarios);
  }

  // Nota: O método generateOsPdfComDiarios foi removido pois era duplicado de gerarPdfCompleto
  // Use diretamente: await gerarPdfCompleto(os, diarios);

  // --- WIDGETS DE CONSTRUÇÃO DO PDF (Métodos Privados) ---

  /// Constrói o CABEÇALHO do PDF (exibido em TODAS as páginas).
  /// 
  /// Estrutura: Logo + Titulo + Numero da OS em destaque
  /// 
  /// COMO CUSTOMIZAR:
  /// - Logo: Através do método LogoService.getLogoFile() ou alterar o placeholder
  /// - Título: Alterar o parâmetro 'title' na chamada desta função
  /// - Cores: Mudar PdfColors.* para as cores desejadas
  /// - Tamanho das fontes: Ajustar fontSize nas propriedades pw.TextStyle
  /// - Espaçamento: Modificar os valores em EdgeInsets ou SizedBox
  /// 
  /// @param os Objeto OsModel com os dados (usado para exibir o número da OS)
  /// @param title Texto principal do cabeçalho (padrão: 'Ordem de Serviço')
  /// @param logoImage Logo da empresa (se null, exibe placeholder cinza)
  static pw.Widget _buildHeader(OsModel os, {String title = 'Ordem de Serviço', pw.ImageProvider? logoImage}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blueGrey50,
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.blueGrey700, width: 2),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Logo da empresa ou placeholder
          pw.Container(
            width: 55,
            height: 55,
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.blueGrey200, width: 1),
              boxShadow: [
                pw.BoxShadow(
                  color: PdfColors.grey300,
                  blurRadius: 3,
                ),
              ],
            ),
            child: logoImage != null
                ? pw.ClipRRect(
                    horizontalRadius: 8,
                    verticalRadius: 8,
                    child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                  )
                : pw.Center(child: pw.Text('Logo', style: pw.TextStyle(color: PdfColors.blueGrey400, fontSize: 10, fontWeight: pw.FontWeight.bold))),
          ),
          pw.SizedBox(width: 15),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(title, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
                pw.SizedBox(height: 3),
                pw.Text('Relatório de Atendimento Técnico', style: pw.TextStyle(fontSize: 11, color: PdfColors.blueGrey600, fontStyle: pw.FontStyle.italic)),
              ],
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: pw.BoxDecoration(
              color: PdfColors.blueGrey800,
              borderRadius: pw.BorderRadius.circular(6),
              boxShadow: [
                pw.BoxShadow(
                  color: PdfColors.blueGrey300,
                  blurRadius: 4,
                ),
              ],
            ),
            child: pw.Column(
              children: [
                pw.Text('OS N°', style: pw.TextStyle(fontSize: 9, color: PdfColors.blueGrey200, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 2),
                pw.Text(os.numeroOs, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
              ],
            )
          ),
        ],
      ),
    );
  }

  /// Constrói o RODAPÉ do PDF (exibido em TODAS as páginas).
  /// 
  /// COMPOSIÇÃO DO RODAPÉ:
  /// [Gerado em: 12/02/2026 14:30]                      [Página 3 de 10]
  /// 
  /// COMO CUSTOMIZAR:
  /// - Adicionar informações adicionais (ex: nome da empresa, email)
  /// - Alterar o formato da data: Mudar 'dd/MM/yyyy HH:mm' em DateFormat
  /// - Mudar cores ou fonte: Editar PdfColors.* e TextStyle
  /// - Remover/adicionar elementos: Adicionar mais widgets na Row
  /// 
  /// @param date Data/hora de geração do PDF
  /// @param pageNumber Número da página atual (fornecido automaticamente pelo context)
  /// @param pageCount Total de páginas do documento (fornecido automaticamente pelo context)
  static pw.Widget _buildFooter(DateTime date, int pageNumber, int pageCount) {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(top: 15),
      padding: const pw.EdgeInsets.only(top: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.blueGrey300, width: 1.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: pw.BoxDecoration(
              color: PdfColors.blueGrey50,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text('Gerado em: ${DateFormat('dd/MM/yyyy HH:mm').format(date)}', style: pw.TextStyle(fontSize: 9, color: PdfColors.blueGrey700, fontWeight: pw.FontWeight.normal)),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: pw.BoxDecoration(
              color: PdfColors.blueGrey800,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text('Página $pageNumber de $pageCount', style: pw.TextStyle(fontSize: 9, color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
          ),
        ],
      ),
    );
  }
  
  /// Constrói um TÍTULO DE SEÇÃO padronizado.
  /// Usado em: "Dados Gerais", "Relatos", "Status", "Histórico de Atendimentos", etc.
  /// 
  /// COMO CUSTOMIZAR:
  /// - Border: Alterar border: pw.Border(...) para mudar a linha inferior
  /// - Cor da fonte: Mudar PdfColors.blueGrey700 para outra cor
  /// - Tamanho: Alterar fontSize: 12 para aumentar/diminuir
  /// - Peso da fonte: Mudar fontWeight: pw.FontWeight.bold para outras opções
  /// 
  /// @param title Texto do título da seção
  static pw.Widget _buildSectionHeader(String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 6, top: 12),
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: pw.BoxDecoration(
        color: PdfColors.blueGrey700,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(title, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
    );
  }

  /// Constrói um CONTAINER/CARD PADRÃO para seções de conteúdo.
  /// Usado para envolver praticamente todo o conteúdo principal do PDF.
  /// 
  /// COMO CUSTOMIZAR:
  /// - Cor de fundo: Alterar PdfColors.grey50 para outra cor
  /// - Cor da borda: Mudar PdfColors.grey300
  /// - Espessura da borda: Alterar width: 1
  /// - Espaçamento interno: Mudar EdgeInsets.all(8)
  /// - Cantos arredondados: Ajustar BorderRadius.circular(4)
  /// 
  /// @param child O widget a ser envolvido (pode ser um Column, Text, etc.)
  static pw.Widget _buildStandardCard(pw.Widget child) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.blueGrey200, width: 1),
        boxShadow: [
          pw.BoxShadow(
            color: PdfColors.blueGrey100,
            blurRadius: 4,
          ),
        ],
      ),
      child: child,
    );
  }

  /// Constrói uma LINHA DE INFORMAÇÃO no formato "Rótulo: Valor".
  /// Padrão usado em todo o document para exibir pares chave-valor.
  /// 
  /// EXEMPLOS:
  /// Cliente:        Empresa XYZ
  /// Serviço:        Manutenção Preventiva
  /// Responsável:    João Silva
  /// 
  /// CARACTERÍSTICAS:
  /// - Rótulo com largura fixa (100 pt) para alinhar valores
  /// - Valor ocupa o espaço restante (expandido)
  /// - Suporta destaque (mais escuro/negrito) para campos importantes
  /// - Espaçamento mínimo entre linhas
  /// 
  /// COMO CUSTOMIZAR:
  /// - Largura do rótulo: Alterar SizedBox(width: 100) para ajustar alinhamento
  /// - Cor do rótulo: Mudar PdfColors.blueGrey700
  /// - Cor do valor: Mudar PdfColors.grey800
  /// - Tamanho da fonte: Alterar fontSize: 9
  /// - Espaçamento: Mudar EdgeInsets.symmetric(vertical: 2)
  /// 
  /// @param label Texto do rótulo (ex: "Cliente", "Serviço")
  /// @param value Valor a exibir (ex: "Empresa XYZ")
  /// @param isHighlighted Se true, exibe em negrito e tom mais escuro
  static pw.Widget _buildInfoRow(String label, String value, {bool isHighlighted = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text('$label:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey700, fontSize: 9)),
          ),
          pw.Expanded(
            child: pw.Text(value, style: pw.TextStyle(
              fontSize: 9,
              color: isHighlighted ? PdfColors.blueGrey900 : PdfColors.grey800,
              fontWeight: isHighlighted ? pw.FontWeight.bold : pw.FontWeight.normal,
            )),
          ),
        ],
      ),
    );
  }

  /// Constrói a SEÇÃO DE DADOS GERAIS DA OS (primeira seção do PDF).
  /// Exibe todas as informações principais da Ordem de Serviço.
  /// 
  /// CAMPOS EXIBIDOS (se disponíveis):
  /// - Cliente (em destaque)
  /// - Serviço
  /// - Responsável
  /// - Quilometragem (KM Inicial / KM Final)
  /// - Horários (Início, Intervalo, Término)
  /// - Equipe (lista de funcionários)
  /// - N° Pedido (se aplicável)
  /// - Data de criação
  /// - Data de última atualização
  /// 
  /// COMO CUSTOMIZAR:
  /// - Adicionar novo campo: Adicione outra linha com _buildInfoRow('Label', os.campo)
  /// - Remover campo: Delete a linha correspondente
  /// - Alterar ordem: Reorganize as linhas
  /// - Alterar formatação: Use _buildInfoRow com isHighlighted=true para destaque
  /// 
  /// @param os Modelo com dados da Ordem de Serviço
  /// @param dateFormatter Formatador para exibir datas (formato: DD/MM/YYYY)
  static pw.Widget _buildOsInfoSection(OsModel os, DateFormat dateFormatter) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Dados Gerais'),
        pw.SizedBox(height: 4),
        _buildStandardCard(
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Cliente', os.nomeCliente, isHighlighted: true),
              _buildInfoRow('Serviço', os.servico),
              _buildInfoRow('Responsável', os.responsavel),
              if (os.kmInicial != null || os.kmFinal != null)
                _buildInfoRow('Quilometragem', '${os.kmInicial?.toString() ?? '-'}  /  ${os.kmFinal?.toString() ?? '-'}'),
              // Horários da OS
              if (os.horaInicio != null || os.intervaloInicio != null || os.horaTermino != null)
                _buildInfoRow('Horários', [
                  if (os.horaInicio != null) 'Início: ${os.horaInicio}',
                  if (os.intervaloInicio != null && os.intervaloFim != null) 'Intervalo: ${os.intervaloInicio} - ${os.intervaloFim}',
                  if (os.horaTermino != null) 'Término: ${os.horaTermino}',
                ].join(' | ')),
              if (os.funcionarios.isNotEmpty) _buildInfoRow('Equipe', os.funcionarios.join(', ')),
              if (os.temPedido && os.numeroPedido != null) _buildInfoRow('N° Pedido', os.numeroPedido!),
              if (os.createdAt != null) _buildInfoRow('Criado em', dateFormatter.format(os.createdAt!)),
              if (os.updatedAt != null) _buildInfoRow('Atualizado em', dateFormatter.format(os.updatedAt!)),
            ],
          ),
        ),
      ],
    );
  }

  /// Constrói a SEÇÃO DE RELATOS DA OS.
  /// Exibe duas caixas de texto: o que o cliente relatou e o que o técnico observou.
  /// 
  /// ESTRUTURA:
  /// ┌──────────────────────────────────────┐
  /// │ Relato do Cliente:                   │
  /// │ [Texto do relato do cliente]          │
  /// │                                      │
  /// │ ──────────────────────────────────  │
  /// │                                      │
  /// │ Relato Técnico Inicial:              │
  /// │ [Texto do relato técnico]            │
  /// └──────────────────────────────────────┘
  /// 
  /// COMO CUSTOMIZAR:
  /// - Adicionar mais seções de relato: Duplique o bloco if(os.relatoTecnico...) 
  /// - Alterar títulos: Mude os textos 'Relato do Cliente:' e 'Relato Técnico Inicial:'
  /// - Mudar divisor: Altere Divider(color: ...) para outra cor ou estilo
  /// - Tamanho da fonte: Alterar fontSize em TextStyle
  /// 
  /// @param os Modelo com dados (contem relatoCliente e relatoTecnico)
  static pw.Widget _buildReportsSection(OsModel os) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
         _buildSectionHeader('Relatos'),
         pw.SizedBox(height: 4),
         _buildStandardCard(
           pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Relato do Cliente:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.blueGrey700)),
              pw.SizedBox(height: 2),
              pw.Text(os.relatoCliente, style: const pw.TextStyle(fontSize: 9)),
              if (os.relatoTecnico != null && os.relatoTecnico!.isNotEmpty) ...[
                pw.SizedBox(height: 5),
                pw.Divider(color: PdfColors.grey300),
                pw.SizedBox(height: 5),
                pw.Text('Relato Técnico Inicial:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.blueGrey700)),
                pw.SizedBox(height: 2),
                pw.Text(os.relatoTecnico!, style: const pw.TextStyle(fontSize: 9)),
              ],
            ]
           ),
         ),
      ],
    );
  }
  
  /// Constrói a SEÇÃO DE STATUS DA OS.
  /// Exibe indicadores visuais (chips) para o status da ordem de serviço.
  /// 
  /// POSSÍVEIS STATUS:
  /// ● Finalizado   (verde)  - Se os.osfinalizado == true
  /// ● Garantia     (azul)   - Se os.garantia == true
  /// ● Pendente     (laranja)- Se os.pendente == true
  /// 
  /// SEÇÃO ADICIONAL (se há pendência):
  /// Se os.pendente == true e há descrição, exibe:
  /// ┌──────────────────────────────┐
  /// │ Detalhe da Pendência:        │
  /// │ [Descrição da pendência]     │
  /// └──────────────────────────────┘
  /// 
  /// COMO CUSTOMIZAR:
  /// - Adicionar novo status: Adicione if (os.novoStatus) _statusChip(...)
  /// - Mudar cores dos chips: Alterar o parâmetro PdfColors.* em _statusChip()
  /// - Alterar layout: Mudar Wrap() para Row() ou Column()
  /// - Alterar textos: Mude as strings dos rótulos
  /// 
  /// @param os Modelo com dados (contem osfinalizado, garantia, pendente, pendenteDescricao)
  static pw.Widget _buildStatusSection(OsModel os) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Status da Ordem de Serviço'),
          pw.SizedBox(height: 4),
          _buildStandardCard(
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    if (os.osfinalizado) _statusChip('Finalizado', true, PdfColors.green),
                    if (os.garantia) _statusChip('Garantia', true, PdfColors.blue),
                    if (os.pendente) _statusChip('Pendente', true, PdfColors.orange),
                  ],
                ),
                /*if (os.pendente && os.pendenteDescricao != null && os.pendenteDescricao!.isNotEmpty) ...[
                  pw.SizedBox(height: 5),
                  pw.Divider(color: PdfColors.grey300),
                  pw.SizedBox(height: 5),
                  pw.Text('Detalhe da Pendência:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.orange)),
                  pw.SizedBox(height: 2),
                  pw.Text(os.pendenteDescricao!, style: const pw.TextStyle(fontSize: 9, color: PdfColors.orange))
                ]*/
              ]
            )
          )
        ]
    );
  }

  

  /// Constrói uma TABELA DETALHADA com informações de KM para cada diário.
  /// 
  /// ESTRUTURA DA TABELA:
  /// ┌─────────────────┬─────────┬─────────┬───────────┐
  /// │ Diário          │ KM Ini. │ KM Fin. │ KM Perc.  │
  /// ├─────────────────┼─────────┼─────────┼───────────┤
  /// │ Diário #2       │  100.0  │  105.5  │   5.5 km  │
  /// │ Diário #3       │  105.5  │  110.2  │   4.7 km  │
  /// ├─────────────────┼─────────┼─────────┼───────────┤
  /// │ TOTAL           │         │         │  10.2 km  │
  /// └─────────────────┴─────────┴─────────┴───────────┘
  /// 
  /// COMO CUSTOMIZAR:
  /// - Adicionar colunas: Use columnWidths e children nos TableRow
  /// - Mudar cores: Alterar PdfColors.* em decoration
  /// - Mudar ordem das colunas: Reorganizar os Padding() dentro dos TableRow
  /// - Alterar largura das colunas: Editar FlexColumnWidth(valor)
  /// - Adicionar bordas mais grossas: Mudar TableBorder.all(width: 0.5)
  /// 
  /// @param diariosData Lista de mapas com dados: {diario, inicial, final, percorrido}
  /// @param total KM total percorrido em todos os diários
  static pw.Widget _buildDiariosKmTable(List<Map<String, String>> diariosData, double total) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Detalhamento por Diário', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey700)),
        pw.SizedBox(height: 4),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(1.2),
            2: const pw.FlexColumnWidth(1.2),
            3: const pw.FlexColumnWidth(1.2),
          },
          children: [
            // Cabeçalho
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.blueGrey100),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('Diário', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('KM Ini.', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('KM Fin.', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('KM Perc.', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
                ),
              ],
            ),
            // Dados
            ...diariosData.asMap().entries.map((entry) {
              final data = entry.value;
              return pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: entry.key % 2 == 0 ? PdfColors.grey50 : PdfColors.white,
                ),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(data['diario']!, style: const pw.TextStyle(fontSize: 8)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(data['inicial']!, style: const pw.TextStyle(fontSize: 8), textAlign: pw.TextAlign.right),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(data['final']!, style: const pw.TextStyle(fontSize: 8), textAlign: pw.TextAlign.right),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('${data['percorrido']}', style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: data['percorrido'] != '-' ? pw.FontWeight.bold : pw.FontWeight.normal,
                      color: data['percorrido'] != '-' ? PdfColors.green800 : PdfColors.grey600,
                    ), textAlign: pw.TextAlign.right),
                  ),
                ],
              );
            }).toList(),
            // Linha de Total
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.blueGrey200),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('TOTAL', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('', style: const pw.TextStyle(fontSize: 8)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('', style: const pw.TextStyle(fontSize: 8)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('${total.toStringAsFixed(1)} km', style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ), textAlign: pw.TextAlign.right),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// Constrói a SEÇÃO DE RELATÓRIO DE KM PERCORRIDO (última seção antes do rodapé).
  /// Exibe um resumo de quilometragem e um detalhamento completo.
  /// 
  /// COMPOSIÇÃO (em ordem):
  /// 1. Título: "Relatório de KM Percorrido"
  /// 2. Caixa de Resumo (com background azul):
  ///    - KM da OS (quilometragem na OS principal)
  ///    - KM dos Diários (soma de todos os diários)
  ///    - TOTAL (OS + Diários em destaque)
  /// 3. Detalhes da OS:
  ///    - KM Inicial
  ///    - KM Final
  ///    - KM Percorrido
  /// 4. Tabela de Detalhamento (se houver diários):
  ///    - Linha para cada diário
  ///    - Linha de TOTAL
  /// 
  /// CÁLCULOS AUTOMÁTICOS:
  /// - KM Percorrido OS = os.kmFinal - os.kmInicial (se > 0)
  /// - KM Percorrido Diário = diario.kmFinal - diario.kmInicial (se > 0)
  /// - Total Combinado = KM OS + KM Diários
  /// 
  /// COMO CUSTOMIZAR:
  /// - Alterar cores da caixa de resumo: Mudar PdfColors.blue* 
  /// - Adicionar mais campos: Use _buildInfoRow() para cada novo campo
  /// - Mudar o cálculo de KM: Editar a lógica dentro dos loops for
  /// - Alterar formatação dos números: Mudar toStringAsFixed(1) para outra precisão
  /// 
  /// @param os Modelo com kmInicial e kmFinal
  /// @param diarios Lista de diários com kmInicial e kmFinal de cada um
  static pw.Widget _buildKmReportSection(OsModel os, List<DiarioModel> diarios) {
    double osKm = 0;
    if (os.kmInicial != null && os.kmFinal != null) {
      final diff = (os.kmFinal! - os.kmInicial!);
      if (diff > 0) osKm = diff;
    }

    double diariosKmTotal = 0;
    final List<Map<String, String>> diariosData = [];
    // Os diários já foram ordenados no início de gerarPdfCompleto
    for (final d in diarios) {
      double kmPerc = 0;
      if (d.kmInicial != null && d.kmFinal != null) {
        final diff = (d.kmFinal! - d.kmInicial!);
        if (diff > 0) kmPerc = diff;
      }
      diariosKmTotal += kmPerc;
      diariosData.add({
        'diario': 'Diário #${d.numeroDiario.toStringAsFixed(1)}',
        'inicial': d.kmInicial?.toStringAsFixed(1) ?? '-',
        'final': d.kmFinal?.toStringAsFixed(1) ?? '-',
        'percorrido': kmPerc > 0 ? '${kmPerc.toStringAsFixed(1)}' : '-',
      });
    }

    final combined = osKm + diariosKmTotal;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Relatório de KM Percorrido'),
        pw.SizedBox(height: 6),
        // Resumo em destaque com estilo aprimorado
        pw.Container(
          decoration: pw.BoxDecoration(
            gradient: pw.LinearGradient(
              colors: [PdfColors.blue50, PdfColors.blueGrey50],
              begin: pw.Alignment.topLeft,
              end: pw.Alignment.bottomRight,
            ),
            border: pw.Border.all(color: PdfColors.blueGrey400, width: 2),
            borderRadius: pw.BorderRadius.circular(8),
            boxShadow: [
              pw.BoxShadow(
                color: PdfColors.blueGrey200,
                blurRadius: 6,
              ),
            ],
          ),
          padding: const pw.EdgeInsets.all(15),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blueGrey800,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text('RESUMO TOTAL DE KM', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
              ),
              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Row(children: [
                      pw.Container(width: 12, height: 12, decoration: pw.BoxDecoration(color: PdfColors.blue400, shape: pw.BoxShape.circle)),
                      pw.SizedBox(width: 6),
                      pw.Text('OS:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
                    ]),
                    pw.SizedBox(height: 4),
                    pw.Text('${osKm.toStringAsFixed(1)} km', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    pw.SizedBox(height: 10),
                    pw.Row(children: [
                      pw.Container(width: 12, height: 12, decoration: pw.BoxDecoration(color: PdfColors.orange400, shape: pw.BoxShape.circle)),
                      pw.SizedBox(width: 6),
                      pw.Text('Diários:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
                    ]),
                    pw.SizedBox(height: 4),
                    pw.Text('${diariosKmTotal.toStringAsFixed(1)} km', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.orange800)),
                  ]),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blueGrey800,
                      borderRadius: pw.BorderRadius.circular(8),
                      boxShadow: [
                        pw.BoxShadow(
                          color: PdfColors.blueGrey400,
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text('TOTAL GERAL', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey200)),
                        pw.SizedBox(height: 4),
                        pw.Text('${combined.toStringAsFixed(1)} km', 
                          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 8),
        // Detalhes da OS
        _buildStandardCard(
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Dados da Ordem de Serviço', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey700)),
              pw.SizedBox(height: 4),
              _buildInfoRow('KM Inicial', os.kmInicial?.toString() ?? '-'),
              _buildInfoRow('KM Final', os.kmFinal?.toString() ?? '-'),
              _buildInfoRow('KM Percorrido', osKm > 0 ? '${osKm.toStringAsFixed(1)} km' : '-'),
            ],
          ),
        ),
        if (diariosData.isNotEmpty) ...[
          pw.SizedBox(height: 8),
          _buildDiariosKmTable(diariosData, diariosKmTotal),
        ],
      ],
    );
  }
  
  /// Constrói um "CHIP" (indicador visual compacto) para cada status.
  /// Cada chip possui um ponto colorido e um rótulo de texto.
  /// 
  /// COMO CUSTOMIZAR:
  /// - Tamanho do ponto: Alterar width: 6, height: 6
  /// - Espaçamento: Mudar EdgeInsets.symmetric(horizontal: 8, vertical: 4)
  /// - Cor quando ativo: Mudar o parâmetro 'color' na chamada
  /// - Cor de fundo: Alterar PdfColors.grey100 quando isActive
  /// - Bordas: Mudar Border.all ou remover
  /// - Formato: Mudar BorderRadius.circular(20) para cantos diferentes
  /// 
  /// @param label Texto do status (ex: "Finalizado", "Garantia", "Pendente")
  /// @param isActive Se true, exibe com cor; se false, exibe em tons de cinza
  /// @param color Cor do ponto quando o status está ativo
  static pw.Widget _statusChip(String label, bool isActive, PdfColor color) {
    // Definir cores baseadas no status
    PdfColor bgColor;
    PdfColor borderColor;
    PdfColor textColor;
    
    if (label == 'Finalizado') {
      bgColor = PdfColors.green50;
      borderColor = PdfColors.green700;
      textColor = PdfColors.green900;
    } else if (label == 'Garantia') {
      bgColor = PdfColors.blue50;
      borderColor = PdfColors.blue700;
      textColor = PdfColors.blue900;
    } else if (label == 'Pendente') {
      bgColor = PdfColors.orange50;
      borderColor = PdfColors.orange700;
      textColor = PdfColors.orange900;
    } else {
      bgColor = isActive ? PdfColors.grey100 : PdfColors.grey200;
      borderColor = isActive ? PdfColors.grey400 : PdfColors.grey400;
      textColor = isActive ? PdfColors.grey800 : PdfColors.grey600;
    }
    
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(20),
        border: pw.Border.all(color: borderColor, width: 1.5)
      ),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Container(
            width: 8,
            height: 8,
            decoration: pw.BoxDecoration(
              color: isActive ? color : PdfColors.grey500,
              shape: pw.BoxShape.circle,
            )
          ),
          pw.SizedBox(width: 6),
          pw.Text(label, style: pw.TextStyle(fontSize: 10, color: textColor, fontWeight: pw.FontWeight.bold))
        ]
      )
    );
  }

  /// Constrói a SEÇÃO DE ASSINATURA DO CLIENTE.
  /// Exibe a imagem da assinatura em uma área delimitada.
  /// 
  /// NOTA: Esta seção só aparece se os.assinatura for válida (não null/vazia)
  /// 
  /// @param signatureImage Imagem PNG da assinatura (gerada por _generateSignatureImage)
  static pw.Widget _buildSignatureSection(pw.ImageProvider signatureImage) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Assinatura do Cliente'),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.blueGrey300, width: 1.5),
              boxShadow: [
                pw.BoxShadow(
                  color: PdfColors.blueGrey100,
                  blurRadius: 4,
                ),
              ],
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(
                  height: 90,
                  width: 220,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.blueGrey300, style: pw.BorderStyle.dashed, width: 1.5),
                    borderRadius: pw.BorderRadius.circular(4),
                    color: PdfColors.grey50,
                  ),
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Image(signatureImage, fit: pw.BoxFit.contain),
                  )
                ),
                pw.SizedBox(height: 10),
                pw.Container(
                  width: 220,
                  padding: const pw.EdgeInsets.only(top: 6),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(top: pw.BorderSide(color: PdfColors.blueGrey400, width: 1.5))
                  ),
                  child: pw.Center(child: pw.Text('Assinatura do Responsável', style: pw.TextStyle(fontSize: 9, color: PdfColors.blueGrey700, fontWeight: pw.FontWeight.bold)))
                )
              ]
            )
          )
        ]);
  }

  /// Constrói o CARD DE UM ÚNICO DIÁRIO.
  /// Cada diário é um card dentro do histórico de atendimentos.
  /// 
  /// ESTRUTURA DO CARD:
  /// ┌──────────────────────────────────────────┐
  /// │ Diário #2                    01/02/2026  │
  /// │ ─────────────────────────────────────── │
  /// │ Atividades Realizadas:                   │
  /// │ [Descrição do que foi feito]             │
  /// │                                          │
  /// │ Relato do Cliente:                       │
  /// │ [O que o cliente disse]                  │
  /// │                                          │
  /// │ Horários: Início: 08:00 | ... | Fim...  │
  /// │ Quilometragem: KM Inicial: 100 | ...    │
  /// │ Equipe Presente: João Silva, Maria...   │
  /// │                                          │
  /// │ [Imagem da Assinatura] (se existir)      │
  /// └──────────────────────────────────────────┘
  /// 
  /// CAMPOS EXIBIDOS (se disponíveis):
  /// - Número do Diário e Data
  /// - Atividades Realizadas (relato técnico)
  /// - Relato do Cliente
  /// - Horários (início, intervalo, término)
  /// - Quilometragem (KM inicial e final)
  /// - Equipe Presente (lista de funcionários)
  /// - Assinatura do Atendimento (se houver)
  /// 
  /// COMO CUSTOMIZAR:
  /// - Mudar altura da imagem de assinatura: Alterar height: 60
  /// - Adicionar/remover campos: Use _buildInfoRow() para novos campos
  /// - Mudar ordem dos campos: Reorganize os if/else
  /// - Alterar cores/fontes: Editar PdfColors.* e TextStyle
  /// - Mudar tamanho do card: Alterar padding em EdgeInsets
  /// 
  /// @param diario Modelo com dados do diário
  /// @param dateFormatter Formatador de datas (DD/MM/YYYY)
  /// @param timeFormatter Formatador de horas (HH:MM)
  /// @param signatureImage Imagem PNG da assinatura (pode ser null)
  static pw.Widget _buildDiarioItem(DiarioModel diario, DateFormat dateFormatter, DateFormat timeFormatter, pw.ImageProvider? signatureImage) {
    String horarios = [
      if (diario.horaInicio != null) 'Início: ${diario.horaInicio}',
      if (diario.intervaloInicio != null) 'Intervalo: ${diario.intervaloInicio} - ${diario.intervaloFim}',
      if (diario.horaTermino != null) 'Término: ${diario.horaTermino}',
    ].join(' | ');

    String kms = [
      if (diario.kmInicial != null) 'KM Inicial: ${diario.kmInicial}',
      if (diario.kmFinal != null) 'KM Final: ${diario.kmFinal}',
    ].join(' | ');

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: _buildStandardCard(
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Diário #${diario.numeroDiario.toStringAsFixed(1)}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey700)),
                pw.Text(dateFormatter.format(diario.data), style: pw.TextStyle(fontSize: 9, color: PdfColors.blueGrey600)),
              ]
            ),
            pw.Divider(height: 6, color: PdfColors.grey300),
            if (diario.relatoTecnico != null && diario.relatoTecnico!.isNotEmpty) ...[
                pw.Text('Atividades Realizadas:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey700)),
                pw.SizedBox(height: 2),
                pw.Text(diario.relatoTecnico!, style: const pw.TextStyle(fontSize: 9)),
                pw.SizedBox(height: 5),
            ],
            if (diario.relatoCliente != null && diario.relatoCliente!.isNotEmpty) ...[
              pw.Text('Relato do Cliente:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey700)),
              pw.SizedBox(height: 2),
              pw.Text(diario.relatoCliente!, style: const pw.TextStyle(fontSize: 9)),
              pw.SizedBox(height: 5),
            ],
            if (horarios.isNotEmpty) _buildInfoRow('Horários', horarios),
            if (kms.isNotEmpty) _buildInfoRow('Quilometragem', kms),
            if (diario.funcionarios.isNotEmpty) _buildInfoRow('Equipe Presente', diario.funcionarios.join(', ')),
            if (signatureImage != null) ...[
              pw.SizedBox(height: 8),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Container(
                      height: 60,
                      width: 180,
                      child: pw.Image(signatureImage, fit: pw.BoxFit.contain),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Container(
                      width: 180,
                      padding: const pw.EdgeInsets.only(top: 4),
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey600, width: 1)),
                      ),
                      child: pw.Center(child: pw.Text('Assinatura do Atendimento', style: pw.TextStyle(fontSize: 8, color: PdfColors.blueGrey700, fontWeight: pw.FontWeight.bold))),
                    ),
                  ],
                ),
              ),
            ]
          ],
        )
      )
    );
  }
  
  /// Coleta TODOS os caminhos de imagem da OS principal e de todos os diários.
  /// Agrupa as imagens por fonte para fácil identificação no PDF.
  /// 
  /// RETORNA UM MAPA COMO:
  /// {
  ///   'OS Principal': ['/caminho/img1.jpg', '/caminho/img2.jpg'],
  ///   'Diário #2': ['/caminho/img3.jpg', '/caminho/img4.jpg'],
  ///   'Diário #3': ['/caminho/img5.jpg'],
  /// }
  /// 
  /// LÓGICA:
  /// - Se os.imagens não está vazia, adiciona com chave 'OS Principal'
  /// - Para cada diário com imagens, cria uma chave 'Diário #X'
  /// - Diários sem imagens são ignorados
  /// 
  /// COMO USAR:
  /// - Esta função prepara os dados para _prepareImages()
  /// - Os caminhos são posteriormente usados para ler os arquivos do disco
  /// 
  /// @param os Modelo com imagens da OS
  /// @param diarios Lista de diários, cada um com suas imagens
  /// @return Mapa com imagens agrupadas por fonte
  static Map<String, List<String>> _collectAllImages(OsModel os, List<DiarioModel> diarios) {
    Map<String, List<String>> allImages = {};
    if (os.imagens.isNotEmpty) {
      allImages['OS Principal'] = os.imagens;
    }
    for (var diario in diarios) {
      if (diario.imagens.isNotEmpty) {
        allImages['Diário #${diario.numeroDiario.toStringAsFixed(1)}'] = diario.imagens;
      }
    }
    return allImages;
  }

  /// Processa as imagens com compactação otimizada para dispositivos com pouca memória.
  /// Usa processamento paralelo para melhorar a performance.
  static Future<Map<String, List<Map<String, dynamic>>>> _prepareImages(
    Map<String, List<String>> allImagePaths) async {
    // Otimização: Dimensão máxima reduzida para dispositivos com pouca memória
    // Em dispositivos Android低端, usar 800px é suficiente e economiza RAM
    const int maxDimension = 800; // Reduzido de 1024 para melhor performance
    const int jpegQuality = 60; // Reduzido de 70 para menor uso de memória
    
    final Map<String, List<Map<String, dynamic>>> allImages = {};
    
    // Processa cada fonte de imagem em paralelo usando Future.wait
    final futures = allImagePaths.keys.map((source) async {
      final List<Map<String, dynamic>> imageDatas = [];
      final paths = allImagePaths[source]!;
      
      // Processa todas as imagens desta fonte
      for (final path in paths) {
        final result = await _processSingleImage(path, maxDimension, jpegQuality);
        if (result != null) {
          imageDatas.add(result);
        }
      }
      
      return MapEntry(source, imageDatas);
    });
    
    // Espera todas as fontes terminarem e adiciona ao mapa final
    final results = await Future.wait(futures);
    for (final entry in results) {
      if (entry.value.isNotEmpty) {
        allImages[entry.key] = entry.value;
      }
    }
    
    return allImages;
  }
  
  /// Processa uma única imagem: baixa/le e comprime
  /// Retorna null se falhar
  static Future<Map<String, dynamic>?> _processSingleImage(
    String path, 
    int maxDimension, 
    int jpegQuality
  ) async {
    Uint8List? bytes;
    String imageName = '';

    if (path.startsWith('http')) {
      // É uma URL, tenta baixar a imagem
      try {
        final response = await http.get(Uri.parse(path));
        if (response.statusCode == 200) {
          bytes = response.bodyBytes;
          imageName = path.split('/').last.split('?').first;
        } else {
          print('Falha ao baixar imagem: ${response.statusCode} - $path');
        }
      } catch (e) {
        print('Erro ao baixar imagem da URL: $path - $e');
      }
    } else {
      // É um caminho local
      final file = File(path);
      if (await file.exists()) {
        bytes = await file.readAsBytes();
        imageName = path.replaceAll(r'\', '/').split('/').last;
      }
    }

    if (bytes == null) return null;

    // --- OTIMIZAÇÃO DE IMAGEM PARA DISPOSITIVOS COM POCA RAM ---
    try {
      final image = img.decodeImage(bytes!);
      if (image != null) {
        // Redimensiona apenas se necessário
        if (image.width > maxDimension || image.height > maxDimension) {
          final resized = img.copyResize(image, 
            width: image.width > image.height ? maxDimension : null, 
            height: image.width <= image.height ? maxDimension : null
          );
          bytes = Uint8List.fromList(img.encodeJpg(resized, quality: jpegQuality));
        } else {
          // Já é pequena, apenas comprime
          bytes = Uint8List.fromList(img.encodeJpg(image, quality: jpegQuality));
        }
      }
    } catch (e) {
      print('Erro ao comprimir imagem: $e');
    }
    // --------------------------------------------------------------

    return {
      'image': pw.MemoryImage(bytes!),
      'name': imageName,
    };
  }
  
  /// Constrói uma GALERIA/GRADE DE IMAGENS exibidas inline (dentro do fluxo do conteúdo).
  /// As imagens são dispostas em um "wrap" (quebra automática de linhas).
  /// 
  /// @param images Lista de mapas contendo {image: pw.MemoryImage, name: String}
  /// @param title Título da galeria (ex: "Imagens da OS Principal")
  static pw.Widget _buildInlineImages(List<Map<String, dynamic>> images, {required String title}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Título da galeria com estilo melhorado
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: pw.BoxDecoration(
              color: PdfColors.blueGrey100,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(title, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
          ),
          pw.SizedBox(height: 8),
          pw.Wrap(
            spacing: 12,
            runSpacing: 12,
            children: images.map((data) {
              return pw.Container(
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.blueGrey200, width: 1),
boxShadow: [
                pw.BoxShadow(
                  color: PdfColors.blueGrey100,
                  blurRadius: 4,
                ),
              ],
                ),
                child: pw.Column(
                  children: [
                    pw.Container(
                      height: 130,
                      width: 130,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                      ),
                      child: pw.ClipRRect(
                        horizontalRadius: 7,
                        verticalRadius: 7,
                        child: pw.Image(data['image'], fit: pw.BoxFit.cover),
                      ),
                    ),
                    pw.Container(
                      width: 130,
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(data['name'], style: pw.TextStyle(fontSize: 7, color: PdfColors.blueGrey600), textAlign: pw.TextAlign.center, maxLines: 2),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }



  // --- FUNÇÕES DE UTILIDADE (Assinatura) ---

  /// Converte a STRING DE ASSINATURA em uma LISTA DE PONTOS (coordenadas).
  /// A assinatura é armazenada como uma string serializada de coordenadas.
  /// 
  /// FORMATO DA STRING:
  /// "10.0,20.5;11.2,22.0;12.5,21.8;null;14.0,19.5;..."
  ///  ^        -------  ^       ----  ^
  ///  |        ponto 2  |       null  |
  ///  ponto 1           ponto 3       ponto 5
  /// 
  /// ESTRUTURA:
  /// - Pontos separados por ';'
  /// - Cada ponto: "x,y" (duas coordenadas separadas por ',')
  /// - null representa um "levantamento" da caneta (quebra na linha)
  /// 
  /// PROCESSO:
  /// 1. Divide a string por ';' para obter cada ponto
  /// 2. Para cada ponto:
  ///    - Se for 'null', retorna null (representa intervalo na assinatura)
  ///    - Senão, divide por ',' e tenta converter para números decimais
  ///    - Se conversão falhar, retorna null
  /// 3. Retorna lista de Offset? (pode conter null)
  /// 
  /// EXEMPLO DE RETORNO:
  /// [Offset(10.0, 20.5), Offset(11.2, 22.0), Offset(12.5, 21.8), null, Offset(14.0, 19.5), ...]
  /// 
  /// NOTA: Usa ui.Offset do módulo dart:ui para representar coordenadas 2D
  /// 
  /// @param signature String serializada da assinatura
  /// @return Lista contendo ui.Offset(x,y) dos pontos desenhados e null para interrupções
  static List<ui.Offset?> _deserializeSignature(String signature) {
    if (signature.isEmpty) return [];
    return signature.split(';').map((s) {
      if (s == 'null') return null;
      final parts = s.split(',');
      if (parts.length != 2) return null;
      final dx = double.tryParse(parts[0]);
      final dy = double.tryParse(parts[1]);
      if (dx == null || dy == null) return null;
      return ui.Offset(dx, dy);
    }).toList();
  }

  /// Desenha os pontos da assinatura em um Canvas e converte em imagem PNG.
  /// Operação ASSÍNCRONA que gera uma imagem a partir da string de assinatura.
  /// 
  /// PROCESSO:
  /// 1. Desserializa a string em uma lista de pontos (Offset)
  /// 2. Cria um PictureRecorder com resolução 300x150 pt
  /// 3. Desenha linhas pretas conectando os pontos:
  ///    - Apenas se ambos os pontos são válidos (não null)
  ///    - Linha com espessura 3.0, terminação arredondada
  /// 4. Converte o drawing para imagem PNG
  /// 5. Retorna os bytes da imagem (Uint8List)
  /// 
  /// EXEMPLO (para a string "10,20;15,25;20,20"):
  /// Canvas 300x150:
  /// ┌──────────────────────────┐
  /// │   10,20                  │
  /// │      ╱╱                  │
  /// │     ╱ ╱                  │
  /// │    ╱ ╱ 20,20             │
  /// │   ╱ ╱                    │
  /// │  15,25                   │
  /// └──────────────────────────┘
  /// 
  /// CARACTERÍSTICAS DO DESENHO:
  /// - Cor: Preto (#000000)
  /// - Espessura da linha: 3.0 pontos
  /// - Cap do stroke: Arredondado (StrokeCap.round)
  /// - Resolução: 300x150 pixels
  /// 
  /// TRATAMENTO DE ERROS:
  /// - Se assinatura estiver vazia: retorna null
  /// - Se houver algum erro na desserialização: aqueles pontos são ignorados
  /// - Se nenhum ponto válido existir: retorna null
  /// 
  /// RETORNO:
  /// - Uint8List com bytes PNG se sucesso
  /// - null se não houver pontos válidos
  /// 
  /// COMO CUSTOMIZAR:
  /// - Tamanho do canvas: Mudar 300, 150 nos Rect.fromLTWH e toImage
  /// - Largura da linha: Alterar strokeWidth: 3.0
  /// - Cor: Mudar color: const ui.Color(0xFF000000)
  /// - Estilo de cap: Alterar strokeCap (round, butt, square)
  /// 
  /// NOTA: Operação assíncrona (toImage) - use await na chamada
  /// 
  /// @param signature String serializada da assinatura (ex: "10,20;15,25;null;20,20")
  /// @return Uint8List com bytes da imagem PNG, ou null se vazia/inválida
  static Future<Uint8List?> _generateSignatureImage(String signature) async {
    final points = _deserializeSignature(signature);
    if (points.isEmpty) return null;

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 300, 150));
    
    final paint = ui.Paint()
      ..color = const ui.Color(0xFF000000)
      ..strokeCap = ui.StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(300, 150);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}