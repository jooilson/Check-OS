import 'package:checkos/data/models/diario_model.dart';
import 'package:checkos/data/models/os_model.dart';
import 'package:checkos/data/repositories/diario_repository.dart';
import 'package:checkos/data/repositories/os_repository.dart';
import 'package:checkos/presentation/pages/editar_diario_page.dart';
import 'package:checkos/utils/gerarpdf.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DiarioListWidget extends StatefulWidget {
  final String osId;
  final bool isPendente;
  final String numeroOs;
  final String nomeCliente;
  final OsModel osModel;

  const DiarioListWidget({
    super.key,
    required this.osId,
    required this.isPendente,
    required this.numeroOs,
    required this.nomeCliente,
    required this.osModel,
  });

  @override
  State<DiarioListWidget> createState() => _DiarioListWidgetState();
}

class _DiarioListWidgetState extends State<DiarioListWidget> with AutomaticKeepAliveClientMixin {
  final DiarioRepository _diarioRepository = DiarioRepository();
  // Cache do formatador de data para evitar recriação no build
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<List<DiarioModel>>(
      stream: _diarioRepository.getDiariosStream(widget.osId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Erro ao carregar diários: ${snapshot.error}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        final diarios = snapshot.data ?? [];

        if (diarios.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.note_outlined, size: 48, color: colorScheme.outline),
                const SizedBox(height: 16),
                Text(
                  'Nenhum diário registrado',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _gerarPdfMultiplos(context, diarios),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Gerar PDF Relatório Completo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                  ),
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: diarios.length,
              // Otimização: CacheExtent ajuda a manter itens na memória durante scroll rápido
              cacheExtent: 200,
              itemBuilder: (context, index) {
                return _buildDiarioCard(context, diarios[index]);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDiarioCard(BuildContext context, DiarioModel diario) {
    final colorScheme = Theme.of(context).colorScheme;
    // Usa o formatador cacheado em vez de criar um novo a cada rebuild
    final data = _dateFormatter.format(diario.data);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        iconColor: colorScheme.primary,
        title: Row(
          children: [
            Icon(Icons.today, color: colorScheme.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Diário ${diario.numeroDiario.toStringAsFixed(1)} - $data',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (diario.horaInicio != null)
                    Text(
                      'Horário: ${diario.horaInicio} - ${diario.horaTermino}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            _buildStatusBadge(context, diario),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow(context, 'KM Inicial', diario.kmInicial?.toString()),
                _buildDetailRow(context, 'KM Final', diario.kmFinal?.toString()),
                _buildDetailRow(context, 'Hora Início', diario.horaInicio),
                _buildDetailRow(context, 'Hora Término', diario.horaTermino),
                if (widget.isPendente)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _editarDiario(context, diario, isReadOnly: false),
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _deletarDiario(context, diario),
                        icon: const Icon(Icons.delete),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Theme.of(context).colorScheme.onError,
                        ),
                        label: const Text('Deletar'),
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _editarDiario(context, diario, isReadOnly: true),
                        icon: const Icon(Icons.visibility),
                        label: const Text('Visualizar'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, DiarioModel diario) {
    final colorScheme = Theme.of(context).colorScheme;

    late Color bg;
    late String text;

    if (diario.osfinalizado) {
      bg = colorScheme.primary;
      text = 'Finalizado';
    } else if (diario.pendente) {
      bg = colorScheme.secondary;
      text = 'Pendente';
    } else if (diario.garantia) {
      bg = colorScheme.tertiary;
      text = 'Garantia';
    } else {
      bg = colorScheme.outline;
      text = 'Em andamento';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: colorScheme.onPrimary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _editarDiario(BuildContext context, DiarioModel diario, {bool isReadOnly = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditarDiarioPage(diario: diario, isReadOnly: isReadOnly)),
    );
  }

  void _deletarDiario(BuildContext context, DiarioModel diario) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar deleção'),
        content: const Text('Deseja realmente deletar este diário?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Deletar')),
        ],
      ),
    );

    if (confirm == true) {
      await _diarioRepository.deleteDiario(diario.id);
      await OsRepository().calcularAtualizarTotalKm(widget.osId);
    }
  }

  void _gerarPdfMultiplos(BuildContext context, List<DiarioModel> diarios) async {
    await GerarPdf.gerarPdfCompleto(widget.osModel, diarios);
  }
}