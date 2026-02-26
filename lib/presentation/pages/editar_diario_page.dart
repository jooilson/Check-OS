import 'package:checkos/data/models/diario_model.dart';
import 'package:checkos/data/repositories/diario_repository.dart';
import 'package:checkos/data/repositories/os_repository.dart';
import 'package:checkos/presentation/widgets/diario_form_widget.dart';
import 'package:flutter/material.dart';

class EditarDiarioPage extends StatefulWidget {
  final DiarioModel diario;
  final bool isReadOnly;

  const EditarDiarioPage({
    super.key,
    required this.diario,
    this.isReadOnly = false,
  });

  @override
  State<EditarDiarioPage> createState() => _EditarDiarioPageState();
}

class _EditarDiarioPageState extends State<EditarDiarioPage> {
  final _diarioRepository = DiarioRepository();
  final _osRepository = OsRepository();
  bool _isLoading = false;

  Future<void> _atualizarDiario(DiarioModel diarioAtualizado) async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Esta implementação assume que o `DiarioModel` possui um campo `bool? osfinalizado`.
      // A lógica para finalizar a OS e diários anteriores é acionada aqui.
      final bool eraFinalizado = widget.diario.osfinalizado ?? false;
      final bool agoraEFinalizado = diarioAtualizado.osfinalizado ?? false;
      final bool estaSendoFinalizado = agoraEFinalizado && !eraFinalizado;

      if (estaSendoFinalizado) {
        // O diário está sendo marcado como osfinalizado. Vamos verificar se é o último.
        final todosOsDiarios =
            await _diarioRepository.getDiarios(diarioAtualizado.osId);
        // Ordena para garantir que o último seja realmente o último em sequência.
        todosOsDiarios.sort((a, b) => a.numeroDiario.compareTo(b.numeroDiario));

        if (todosOsDiarios.isNotEmpty &&
            todosOsDiarios.last.id == diarioAtualizado.id) {
          // É o último diário! Finalizar a OS e todos os diários associados.
          // 1. Finaliza a OS principal (assumindo a existência deste método no repositório)
          await _osRepository.updateOsStatus(diarioAtualizado.osId,
              osfinalizado: true, pendente: false);

          // 2. Finaliza todos os diários anteriores (o ideal seria um batch write no repositório)
          for (final diario in todosOsDiarios) {
            if (diario.id != diarioAtualizado.id && !(diario.osfinalizado ?? false)) {
              await _diarioRepository
                  .updateDiario(diario.copyWith(osfinalizado: true));
            }
          }
        }
      }

      await _diarioRepository.updateDiario(diarioAtualizado);
      await _osRepository.calcularAtualizarTotalKm(diarioAtualizado.osId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diário atualizado com sucesso!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar diário: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isReadOnly ? 'Visualizar Diário' : 'Editar Diário'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: DiarioFormWidget(
        diarioParaEditar: widget.diario,
        numeroOs: widget.diario.numeroOs,
        nomeCliente: widget.diario.nomeCliente,
        osId: widget.diario.osId,
        onSalvar: _atualizarDiario,
        isLoading: _isLoading,
        botaoTexto: 'Atualizar Diário',
        isReadOnly: widget.isReadOnly,
      ),
    );
  }
}