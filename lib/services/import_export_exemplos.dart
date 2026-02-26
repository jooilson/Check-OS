import 'package:checkos/services/import_export_service.dart';
import 'package:checkos/data/models/os_model.dart';
import 'package:checkos/data/models/diario_model.dart';
import 'package:checkos/data/models/log_model.dart';

/// Exemplos de uso do serviço de Import/Export
class ImportExportExemplos {
  /// Exemplo 1: Exportar todos os dados em JSON
  static Future<void> exemplo1_exportarJSON({
    required List<OsModel> ordemServicos,
    required List<DiarioModel> diarios,
    required List<LogModel> logs,
  }) async {
    try {
      final caminho = await ImportExportService.exportarDados(
        ordemServicos: ordemServicos,
        diarios: diarios,
        logs: logs,
      );
      print('Arquivo exportado em: $caminho');
    } catch (e) {
      print('Erro na exportação: $e');
    }
  }

  /// Exemplo 2: Exportar em CSV
  static Future<void> exemplo2_exportarCSV({
    required List<OsModel> ordemServicos,
  }) async {
    try {
      final caminho = await ImportExportService.exportarDadosCSV(
        ordemServicos: ordemServicos,
      );
      print('CSV exportado em: $caminho');
    } catch (e) {
      print('Erro na exportação CSV: $e');
    }
  }

  /// Exemplo 3: Importar dados
  static Future<Map<String, dynamic>> exemplo3_importarDados(
      String caminhoArquivo) async {
    try {
      final dados = await ImportExportService.importarDados(caminhoArquivo);

      if (ImportExportService.validarDadosImportados(dados)) {
        print('Dados validados com sucesso!');
        print('OS importadas: ${dados['ordemServicos'].length}');
        print('Diários importados: ${dados['diarios'].length}');
        print('Logs importados: ${dados['logs'].length}');
        return dados;
      } else {
        throw Exception('Dados inválidos');
      }
    } catch (e) {
      print('Erro na importação: $e');
      rethrow;
    }
  }

  /// Exemplo 4: Listar todos os backups
  static Future<void> exemplo4_listarBackups() async {
    try {
      final backups = await ImportExportService.listarBackups();
      print('Backups disponíveis: ${backups.length}');
      for (var backup in backups) {
        print('- ${backup.path}');
      }
    } catch (e) {
      print('Erro ao listar backups: $e');
    }
  }

  /// Exemplo 5: Deletar um backup
  static Future<void> exemplo5_deletarBackup(String caminhoArquivo) async {
    try {
      await ImportExportService.deletarBackup(caminhoArquivo);
      print('Backup deletado com sucesso');
    } catch (e) {
      print('Erro ao deletar backup: $e');
    }
  }

  /// Exemplo 6: Exportar dados de um período específico
  static Future<void> exemplo6_exportarPorPeriodo({
    required List<OsModel> ordemServicos,
    required DateTime dataInicio,
    required DateTime dataFim,
  }) async {
    try {
      final caminho = await ImportExportService.exportarPorPeriodo(
        ordemServicos: ordemServicos,
        dataInicio: dataInicio,
        dataFim: dataFim,
      );
      print('Dados do período exportados em: $caminho');
    } catch (e) {
      print('Erro ao exportar por período: $e');
    }
  }

  /// Exemplo 7: Obter caminho de documentos
  static Future<void> exemplo7_obterCaminhoDocumentos() async {
    try {
      final caminho = await ImportExportService.obterCaminhoDocumentos();
      print('Caminho de documentos: $caminho');
    } catch (e) {
      print('Erro ao obter caminho: $e');
    }
  }

  /// Exemplo 8: Limpar dados locais (após sincronizar)
  static Future<void> exemplo8_limparDadosLocais() async {
    try {
      await ImportExportService.limparDadosLocais();
      print('Dados locais limpos');
    } catch (e) {
      print('Erro ao limpar dados: $e');
    }
  }

  /// Exemplo 9: Usar em um BLoC/Provider para sincronizar
  static Future<void> exemplo9_sincronizarComServidorExample({
    required List<OsModel> ordemServicos,
    required List<DiarioModel> diarios,
    required List<LogModel> logs,
    required Function(List<OsModel>) salvarOsNoServidor,
    required Function(List<DiarioModel>) salvarDiariosNoServidor,
    required Function(List<LogModel>) salvarLogsNoServidor,
  }) async {
    try {
      // Sincroniza com servidor
      await ImportExportService.sincronizarComServidor(
        ordemServicos: ordemServicos,
        diarios: diarios,
        logs: logs,
        salvarOsNoServidor: salvarOsNoServidor,
        salvarDiariosNoServidor: salvarDiariosNoServidor,
        salvarLogsNoServidor: salvarLogsNoServidor,
      );

      // Após sincronizar com sucesso, pode limpar dados locais
      await ImportExportService.limparDadosLocais();
      print('Sincronização concluída com sucesso!');
    } catch (e) {
      print('Erro na sincronização: $e');
    }
  }

  /// Exemplo 10: Fluxo completo de backup automático
  static Future<void> exemplo10_backupAutomatico({
    required List<OsModel> ordemServicos,
    required List<DiarioModel> diarios,
    required List<LogModel> logs,
  }) async {
    try {
      // Cria novo backup
      final novoBackup = await ImportExportService.exportarDados(
        ordemServicos: ordemServicos,
        diarios: diarios,
        logs: logs,
      );
      print('Novo backup criado: $novoBackup');

      // Lista todos os backups
      final backups = await ImportExportService.listarBackups();
      print('Total de backups: ${backups.length}');

      // Mantém apenas os últimos 5 backups
      if (backups.length > 5) {
        final backupsAntigos = backups.take(backups.length - 5);
        for (var backup in backupsAntigos) {
          await ImportExportService.deletarBackup(backup.path);
          print('Backup antigo removido: ${backup.path}');
        }
      }
    } catch (e) {
      print('Erro no backup automático: $e');
    }
  }
}

/// Extensão para adicionar métodos úteis ao OsModel
extension OsModelExtension on OsModel {
  /// Converter para CSV
  String toCsv() {
    return '"$numeroOs","$nomeCliente","$servico","$responsavel","$kmInicial","$kmFinal","$horaInicio","$horaTermino","$osfinalizado","$garantia","$pendente","$createdAt"';
  }

  /// Verificar se a OS está completa
  bool isCompleta() {
    return numeroOs.isNotEmpty &&
        nomeCliente.isNotEmpty &&
        servico.isNotEmpty &&
        responsavel.isNotEmpty &&
        relatoTecnico != null &&
        relatoTecnico!.isNotEmpty &&
        assinatura != null &&
        assinatura!.isNotEmpty;
  }

  /// Obter resumo da OS
  String getResumo() {
    return '''
    OS: $numeroOs
    Cliente: $nomeCliente
    Serviço: $servico
    Responsável: $responsavel
    Status: ${osfinalizado ? 'Finalizada' : 'Em andamento'}
    Garantia: ${garantia ? 'Sim' : 'Não'}
    ''';
  }
}
