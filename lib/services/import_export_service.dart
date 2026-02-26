import 'dart:convert';
import 'dart:io';

import 'package:checkos/data/models/diario_model.dart';
import 'package:checkos/data/models/log_model.dart';
import 'package:checkos/data/models/os_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class ImportExportService {
  /// Solicita permissão de armazenamento.
  static Future<bool> _requestPermission() async {
    // Web não precisa de permissão de armazenamento
    if (kIsWeb) {
      return true;
    }
    
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        final result = await Permission.storage.request();
        if (result.isGranted) {
          return true;
        }
      } else {
        return true;
      }
    }
    // Para outras plataformas, asumimos que a permissão não é necessária
    // ou é tratada de outra forma (ex: seletor de arquivos do sistema no desktop)
    return true;
  }

  /// Exporta todos os dados para um arquivo JSON
  /// Retorna o caminho do arquivo criado
  static Future<String> exportarDados({
    required List<OsModel> ordemServicos,
    required List<DiarioModel> diarios,
    required List<LogModel> logs,
  }) async {
    try {
      if (!await _requestPermission()) {
        throw Exception('Permissão de armazenamento negada.');
      }
      // Prepara os dados em formato JSON
      final dadosExportacao = {
        'dataExportacao': DateTime.now().toIso8601String(),
        'versao': '1.0',
        'ordemServicos': ordemServicos.map((os) => os.toJson()).toList(),
        'diarios': diarios.map((d) => d.toJson()).toList(),
        'logs': logs.map((l) => l.toJson()).toList(),
      };

      // Converte para JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(dadosExportacao);

      // Pede ao usuário para escolher um diretório
      final String? directoryPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Selecione onde salvar o backup',
      );

      if (directoryPath == null) {
        // Usuário cancelou
        throw Exception('Exportação cancelada pelo usuário.');
      }

      // Cria o arquivo
      final nomeArquivo =
          'checkos_backup_${DateFormat('yyyy_MM_dd_HHmmss').format(DateTime.now())}.json';
      final arquivo = File('$directoryPath/$nomeArquivo');

      await arquivo.writeAsString(jsonString);

      return arquivo.path;
    } catch (e) {
      throw Exception('Erro ao exportar dados: $e');
    }
  }

  /// Exporta dados em formato CSV
  /// Retorna o caminho do arquivo criado
  static Future<String> exportarDadosCSV({
    required List<OsModel> ordemServicos,
  }) async {
    try {
       if (!await _requestPermission()) {
        throw Exception('Permissão de armazenamento negada.');
      }
      // Pede ao usuário para escolher um diretório
      final String? directoryPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Selecione onde salvar o arquivo CSV',
      );

      if (directoryPath == null) {
        // Usuário cancelou
        throw Exception('Exportação cancelada pelo usuário.');
      }

      final nomeArquivo =
          'checkos_os_${DateFormat('yyyy_MM_dd_HHmmss').format(DateTime.now())}.csv';
      final arquivo = File('$directoryPath/$nomeArquivo');

      // Cabeçalhos CSV
      final cabecalho =
          'Número OS,Nome Cliente,Serviço,Responsável,KM Inicial,KM Final,Hora Início,Hora Término,Finalizado,Garantia,Pendente,Data Criação\n';

      // Dados CSV
      final linhas = ordemServicos.map((os) {
        return '"${os.numeroOs}","${os.nomeCliente}","${os.servico}","${os.responsavel}","${os.kmInicial ?? ''}","${os.kmFinal ?? ''}","${os.horaInicio ?? ''}","${os.horaTermino ?? ''}","${os.osfinalizado}","${os.garantia}","${os.pendente}","${os.createdAt ?? ''}"';
      }).join('\n');

      await arquivo.writeAsString(cabecalho + linhas);

      return arquivo.path;
    } catch (e) {
      throw Exception('Erro ao exportar CSV: $e');
    }
  }

  /// Importa dados de um arquivo JSON
  /// Retorna um mapa com listas de dados importados
  static Future<Map<String, dynamic>> importarDados(String caminhoArquivo) async {
    try {
      final arquivo = File(caminhoArquivo);

      if (!await arquivo.exists()) {
        throw Exception('Arquivo não encontrado');
      }

      final conteudo = await arquivo.readAsString();
      final json = jsonDecode(conteudo);

      // Valida versão
      final versao = json['versao'] ?? '1.0';
      if (versao != '1.0') {
        throw Exception('Versão do arquivo não suportada: $versao');
      }

      // Converte dados importados
      final ordemServicos = (json['ordemServicos'] as List?)
              ?.map((item) => OsModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];

      final diarios = (json['diarios'] as List?)
              ?.map((item) => DiarioModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];

      final logs = (json['logs'] as List?)
              ?.map((item) => LogModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];

      return {
        'ordemServicos': ordemServicos,
        'diarios': diarios,
        'logs': logs,
        'dataImportacao': DateTime.now(),
      };
    } catch (e) {
      throw Exception('Erro ao importar dados: $e');
    }
  }

  /// Exporta um backup completo em ZIP (requer package: archive)
  /// Para usar, adicionar no pubspec.yaml: archive: ^3.5.0
  static Future<String> exportarBackupCompleto({
    required List<OsModel> ordemServicos,
    required List<DiarioModel> diarios,
    required List<LogModel> logs,
    required List<String> imagensLocalPaths,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      // Prepara dados JSON
      final dadosExportacao = {
        'dataExportacao': DateTime.now().toIso8601String(),
        'versao': '1.0',
        'ordemServicos': ordemServicos.map((os) => os.toJson()).toList(),
        'diarios': diarios.map((d) => d.toJson()).toList(),
        'logs': logs.map((l) => l.toJson()).toList(),
      };

      final jsonString = jsonEncode(dadosExportacao);

      // Cria arquivo JSON
      final nomeArquivo =
          'checkos_backup_${DateFormat('yyyy_MM_dd_HHmmss').format(DateTime.now())}';
      final arquivoJson =
          File('${directory.path}/${nomeArquivo}_dados.json');
      await arquivoJson.writeAsString(jsonString);

      return arquivoJson.path; // Retorna caminho para posterior compactação
    } catch (e) {
      throw Exception('Erro ao exportar backup completo: $e');
    }
  }

  /// Limpa dados locais (útil após sincronizar com servidor)
  static Future<void> limparDadosLocais() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      if (await directory.exists()) {
        // Remove apenas arquivos de backup, não toda a pasta
        final arquivos = directory.listSync();
        for (var arquivo in arquivos) {
          if (arquivo.path.contains('checkos_backup')) {
            await arquivo.delete();
          }
        }
      }
    } catch (e) {
      throw Exception('Erro ao limpar dados locais: $e');
    }
  }

  /// Obtém o caminho do diretório de documentos
  static Future<String> obterCaminhoDocumentos() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// Lista todos os backups disponíveis
  static Future<List<FileSystemEntity>> listarBackups() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final arquivos = directory.listSync();
      return arquivos
          .where((f) =>
              f.path.contains('checkos_backup') && f.path.endsWith('.json'))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar backups: $e');
    }
  }

  /// Deleta um backup específico
  static Future<void> deletarBackup(String caminhoArquivo) async {
    try {
      final arquivo = File(caminhoArquivo);
      if (await arquivo.exists()) {
        await arquivo.delete();
      }
    } catch (e) {
      throw Exception('Erro ao deletar backup: $e');
    }
  }

  /// Sincroniza dados com servidor Firebase
  /// (Este é um exemplo de estrutura, ajuste conforme sua implementação Firebase)
  static Future<void> sincronizarComServidor({
    required Function(List<OsModel>) salvarOsNoServidor,
    required Function(List<DiarioModel>) salvarDiariosNoServidor,
    required Function(List<LogModel>) salvarLogsNoServidor,
    required List<OsModel> ordemServicos,
    required List<DiarioModel> diarios,
    required List<LogModel> logs,
  }) async {
    try {
      await salvarOsNoServidor(ordemServicos);
      await salvarDiariosNoServidor(diarios);
      await salvarLogsNoServidor(logs);
    } catch (e) {
      throw Exception('Erro ao sincronizar com servidor: $e');
    }
  }

  /// Valida integridade dos dados importados
  static bool validarDadosImportados(Map<String, dynamic> dados) {
    try {
      if (dados.isEmpty) return false;

      // Verifica se tem as chaves esperadas
      final temOsValidas = dados['ordemServicos'] is List;
      final temDiariosValidos = dados['diarios'] is List;
      final temLogsValidos = dados['logs'] is List;

      return temOsValidas || temDiariosValidos || temLogsValidos;
    } catch (e) {
      return false;
    }
  }

  /// Exporta apenas dados de um período específico
  static Future<String> exportarPorPeriodo({
    required List<OsModel> ordemServicos,
    required DateTime dataInicio,
    required DateTime dataFim,
  }) async {
    try {
      final osFiltradas = ordemServicos.where((os) {
        final data = os.createdAt;
        if (data == null) return false;
        return data.isAfter(dataInicio) && data.isBefore(dataFim);
      }).toList();

      final dados = {
        'dataExportacao': DateTime.now().toIso8601String(),
        'periodo': {
          'inicio': dataInicio.toIso8601String(),
          'fim': dataFim.toIso8601String(),
        },
        'total': osFiltradas.length,
        'ordemServicos': osFiltradas.map((os) => os.toJson()).toList(),
      };

      final jsonString = jsonEncode(dados);
      
      final String? directoryPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Selecione onde salvar o backup por período',
      );

      if (directoryPath == null) {
        throw Exception('Exportação cancelada pelo usuário.');
      }

      final nomeArquivo =
          'checkos_periodo_${DateFormat('yyyy_MM_dd_HHmmss').format(DateTime.now())}.json';
      final arquivo = File('$directoryPath/$nomeArquivo');

      await arquivo.writeAsString(jsonString);
      return arquivo.path;
    } catch (e) {
      throw Exception('Erro ao exportar por período: $e');
    }
  }
}
