import 'dart:io';

import 'package:checkos/data/models/diario_model.dart';
import 'package:checkos/data/models/log_model.dart';
import 'package:checkos/data/models/os_model.dart';
import 'package:checkos/services/import_export_service.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cross_file/cross_file.dart';

class ImportExportPage extends StatefulWidget {
  final List<OsModel> ordemServicos;
  final List<DiarioModel> diarios;
  final List<LogModel> logs;
  final VoidCallback onDadosImportados;

  const ImportExportPage({
    super.key,
    required this.ordemServicos,
    required this.diarios,
    required this.logs,
    required this.onDadosImportados,
  });

  @override
  State<ImportExportPage> createState() => _ImportExportPageState();
}

class _ImportExportPageState extends State<ImportExportPage> {
  bool _exportandoJSON = false;
  bool _exportandoCSV = false;
  bool _carregandoBackups = false;
  List<FileSystemEntity> _backups = [];

  @override
  void initState() {
    super.initState();
    _carregarBackups();
  }

  Future<void> _carregarBackups() async {
    setState(() => _carregandoBackups = true);
    try {
      final backups = await ImportExportService.listarBackups();
      setState(() => _backups = backups);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar backups: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _carregandoBackups = false);
      }
    }
  }

  Future<void> _exportarJSON() async {
    setState(() => _exportandoJSON = true);
    try {
      final caminho = await ImportExportService.exportarDados(
        ordemServicos: widget.ordemServicos,
        diarios: widget.diarios,
        logs: widget.logs,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dados exportados: $caminho')),
        );
        _carregarBackups();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _exportandoJSON = false);
      }
    }
  }

  Future<void> _exportarCSV() async {
    setState(() => _exportandoCSV = true);
    try {
      final caminho = await ImportExportService.exportarDadosCSV(
        ordemServicos: widget.ordemServicos,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CSV exportado: $caminho')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar CSV: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _exportandoCSV = false);
      }
    }
  }

  Future<void> _selecionarArquivoParaImportar() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Selecione o arquivo de backup (.json)',
      );

      if (result == null || result.files.isEmpty) {
        // Usuário cancelou
        return;
      }

      final path = result.files.first.path;
      if (path == null) return;

      await _importarDados(path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar arquivo: $e')),
        );
      }
    }
  }

  Future<void> _importarDados(String caminho) async {
    try {
      final dadosImportados =
          await ImportExportService.importarDados(caminho);

      if (!mounted) return;

      if (ImportExportService.validarDadosImportados(dadosImportados)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados importados com sucesso!')),
        );
        widget.onDadosImportados();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Arquivo contém dados inválidos')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao importar: $e')),
        );
      }
    }
  }

  Future<void> _compartilharBackup(String caminho) async {
    try {
      final nomeArquivo = caminho.split('/').last;
      await Share.shareXFiles(
        [XFile(caminho)],
        subject: 'Backup CheckOS - $nomeArquivo',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao compartilhar: $e')),
        );
      }
    }
  }

  Future<void> _deletarBackup(String caminho) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar deleção'),
        content: const Text('Deseja deletar este backup?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ImportExportService.deletarBackup(caminho);
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Backup deletado')),
                  );
                  _carregarBackups();
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao deletar: $e')),
                  );
                }
              }
            },
            child: const Text('Deletar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar/Exportar Dados'),
        elevation: 0,
      ),
      // Otimização: CustomScrollView permite listas longas sem shrinkWrap
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Seção de Exportação
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Exportar Dados',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _exportandoJSON ? null : _exportarJSON,
                          icon: _exportandoJSON
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.download),
                          label: const Text('Exportar JSON'),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _exportandoCSV ? null : _exportarCSV,
                          icon: _exportandoCSV
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.table_chart),
                          label: const Text('Exportar CSV'),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _selecionarArquivoParaImportar,
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Importar Arquivo'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Backups Disponíveis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
              ]),
            ),
          ),

          // Seção de Backups (Otimizada com SliverList)
          if (_carregandoBackups)
            const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_backups.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Nenhum backup disponível',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final backup = _backups[index];
                  final nomeArquivo = backup.path.split('/').last;
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                                    title: Text(nomeArquivo),
                                    subtitle: Text(backup.path),
                                    trailing: PopupMenuButton(
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          child: const Text('Importar'),
                                          onTap: () {
                                            Future.delayed(
                                              const Duration(
                                                  milliseconds: 500),
                                              () => _importarDados(
                                                  backup.path),
                                            );
                                          },
                                        ),
                                        PopupMenuItem(
                                          child: const Text('Compartilhar'),
                                          onTap: () {
                                            Future.delayed(
                                              const Duration(
                                                  milliseconds: 500),
                                              () => _compartilharBackup(
                                                  backup.path),
                                            );
                                          },
                                        ),
                                        PopupMenuItem(
                                          child: const Text(
                                            'Deletar',
                                            style: TextStyle(
                                                color: Colors.red),
                                          ),
                                          onTap: () {
                                            Future.delayed(
                                              const Duration(
                                                  milliseconds: 500),
                                              () => _deletarBackup(
                                                  backup.path),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                    ),
                  );
                },
                childCount: _backups.length,
              ),
            ),

          // Informações (Footer)
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ℹ️ Informações',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• JSON: Backup completo com todas as informações\n'
                        '• CSV: Tabela de Ordens de Serviço em formato spreadsheet\n'
                        '• Backups salvos em: Documentos do dispositivo',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
