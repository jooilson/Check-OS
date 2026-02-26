import 'package:checkos/data/models/log_model.dart';
import 'package:checkos/data/repositories/log_repository.dart';
import 'package:flutter/material.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  final LogRepository _logRepository = LogRepository();

  String _filterType = 'all';
  String? _osId;
  String? _userId;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs de Auditoria'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filterType = value;
                _osId = null;
                _userId = null;
                _startDate = null;
                _endDate = null;
              });
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'all', child: Text('Todos')),
              PopupMenuItem(value: 'os', child: Text('Por OS')),
              PopupMenuItem(value: 'user', child: Text('Por Usuário')),
              PopupMenuItem(value: 'period', child: Text('Por Período')),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          if (_filterType == 'os') _buildInput(
            context,
            label: 'ID da OS',
            onChanged: (v) => setState(() => _osId = v),
          ),

          if (_filterType == 'user') _buildInput(
            context,
            label: 'ID do Usuário',
            onChanged: (v) => setState(() => _userId = v),
          ),

          if (_filterType == 'period')
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInput(
                      context,
                      label: 'Data Início (YYYY-MM-DD)',
                      onChanged: (v) =>
                          setState(() => _startDate = DateTime.tryParse(v)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInput(
                      context,
                      label: 'Data Fim (YYYY-MM-DD)',
                      onChanged: (v) =>
                          setState(() => _endDate = DateTime.tryParse(v)),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: StreamBuilder<List<LogModel>>(
              stream: _getFilteredStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                final logs = snapshot.data ?? [];

                if (logs.isEmpty) {
                  return const Center(child: Text('Nenhum log encontrado.'));
                }

                return ListView.builder(
                  itemCount: logs.length,
                  // Otimização: CacheExtent para manter itens na memória durante scroll
                  cacheExtent: 200,
                  itemBuilder: (context, index) {
                    final log = logs[index];

                    final date =
                        log.timestamp.toLocal().toString().split(' ')[0];

                    return Card(
                      color: colors.surface,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // Otimização: Reduzir elevation para melhorar performance de GPU
                      elevation: 2,
                      child: ListTile(
                        title: Text(
                          '${log.action} — OS ${log.osNumero}',
                          style: textTheme.titleMedium,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Usuário: ${log.userEmail}',
                                style: textTheme.bodyMedium,
                              ),
                              Text(
                                'Data: $date',
                                style: textTheme.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                log.description,
                                style: textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
    BuildContext context, {
    required String label,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      decoration: InputDecoration(labelText: label),
      onChanged: onChanged,
    );
  }

  Stream<List<LogModel>> _getFilteredStream() {
    switch (_filterType) {
      case 'os':
        return _osId != null
            ? _logRepository.getLogsByOs(_osId!)
            : _logRepository.getLogs();

      case 'user':
        return _userId != null
            ? _logRepository.getLogsByUser(_userId!)
            : _logRepository.getLogs();

      case 'period':
        return (_startDate != null && _endDate != null)
            ? _logRepository.getLogsByPeriod(_startDate!, _endDate!)
            : _logRepository.getLogs();

      default:
        return _logRepository.getLogs();
    }
  }
}