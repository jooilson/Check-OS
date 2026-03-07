import 'package:checkos/core/context/employee_context.dart';
import 'package:checkos/data/models/log_model.dart';
import 'package:checkos/data/models/os_model.dart';
import 'package:checkos/data/repositories/log_repository.dart';
import 'package:checkos/data/repositories/os_repository.dart';
import 'package:checkos/presentation/pages/novaos_page.dart';
import 'package:checkos/presentation/pages/novo_diario_page.dart';
import 'package:checkos/presentation/widgets/diario_list_widget.dart';
import 'package:checkos/utils/gerarpdf.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetalhesOsPage extends StatefulWidget {
  final OsModel os;

  const DetalhesOsPage({super.key, required this.os});

  @override
  State<DetalhesOsPage> createState() => _DetalhesOsPageState();
}

class _DetalhesOsPageState extends State<DetalhesOsPage> {
  final OsRepository _osRepository = OsRepository();
  final LogRepository _logRepository = LogRepository();
  late OsModel _os;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _os = widget.os;
    _carregarDadosAtualizados();
  }

  Future<void> _carregarDadosAtualizados() async {
    try {
      final osAtualizada = await _osRepository.getOsById(widget.os.id);
      if (osAtualizada != null && mounted) {
        setState(() {
          _os = osAtualizada;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('OS ${_os.numeroOs} - ${_os.nomeCliente}'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'editar':
                  // Busca os dados mais recentes do Firestore antes de editar
                  // Isso garante que as imagens e outros dados esténham atualizados
                  final osAtualizada = await _osRepository.getOsById(widget.os.id);
                  if (osAtualizada != null && mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NovaOsPage(osParaEditar: osAtualizada),
                      ),
                    );
                  }
                  break;

                case 'excluir':
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirmar Exclusão'),
                      content: const Text(
                        'Tem certeza que deseja excluir esta OS?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Excluir'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await _osRepository.deleteOs(_os.id);
                    
                    // Obtém o funcionário atual para auditoria
                    final employeeContext = context.read<EmployeeContext>();
                    
                    await _logRepository.addLog(
                      LogModel(
                        id: '',
                        userId:
                            FirebaseAuth.instance.currentUser?.uid ?? 'unknown',
                        userEmail:
                            FirebaseAuth.instance.currentUser?.email ??
                                'unknown',
                        employeeId: employeeContext.currentEmployeeId,
                        employeeName: employeeContext.currentEmployeeName,
                        timestamp: DateTime.now(),
                        action: 'DELETE_OS',
                        osId: _os.id,
                        osNumero: _os.numeroOs,
                        description: 'OS excluída',
                      ),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('OS excluída com sucesso!'),
                      ),
                    );

                    Navigator.pop(context);
                  }
                  break;

                case 'gerar_pdf':
                  GerarPdf.generateOsPdf(_os);
                  break;
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'editar', child: Text('Editar')),
              PopupMenuItem(value: 'excluir', child: Text('Excluir')),
              PopupMenuItem(value: 'gerar_pdf', child: Text('Gerar PDF')),
            ],
          ),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_os.pendente) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NovoDiarioPage(os: _os),
                        ),
                      );
                    },
                    icon: const Icon(Icons.note_add),
                    label: const Text('Adicionar Diário'),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              Text(
                'Informações Básicas',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              _buildInfoRow(context, 'Cliente', _os.nomeCliente, Icons.person),
              _buildInfoRow(context, 'Serviço', _os.servico, Icons.build),
              _buildInfoRow(
                context,
                'Relato do Cliente',
                _os.relatoCliente,
                Icons.description,
              ),
              _buildInfoRow(
                context,
                'Responsável',
                _os.responsavel,
                Icons.supervisor_account,
              ),

              const SizedBox(height: 32),
              const Divider(),

              const SizedBox(height: 24),

              Text(
                'Diários Registrados',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              DiarioListWidget(
                osId: _os.id,
                companyId: _os.companyId ?? '', // companyId da OS
                isPendente: _os.pendente,
                numeroOs: _os.numeroOs,
                nomeCliente: _os.nomeCliente,
                osModel: _os,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
