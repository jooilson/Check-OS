import 'package:checkos/core/context/employee_context.dart';
import 'package:checkos/data/models/diario_model.dart';
import 'package:checkos/data/models/os_model.dart';
import 'package:checkos/data/repositories/diario_repository.dart';
import 'package:checkos/data/repositories/os_repository.dart';
import 'package:checkos/presentation/widgets/diario_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NovoDiarioPage extends StatefulWidget {
  final OsModel os;

  const NovoDiarioPage({super.key, required this.os});

  @override
  State<NovoDiarioPage> createState() => _NovoDiarioPageState();
}

class _NovoDiarioPageState extends State<NovoDiarioPage> {
  final DiarioRepository _diarioRepository = DiarioRepository();
  final OsRepository _osRepository = OsRepository();
  bool _isLoading = false;

  void _salvarDiario(DiarioModel diario) async {
    setState(() => _isLoading = true);

    try {
      // Obtém o companyId do contexto do funcionário logado
      final companyId = context.read<EmployeeContext>().currentCompanyId;
      if (companyId == null) {
        throw Exception('Empresa não identificada. Faça login novamente.');
      }

      await _diarioRepository.addDiario(diario, companyId);
      await _osRepository.calcularAtualizarTotalKm(widget.os.id);

      if (diario.osfinalizado) {
        final osAtualizada = OsModel(
          id: widget.os.id,
          numeroOs: widget.os.numeroOs,
          nomeCliente: widget.os.nomeCliente,
          servico: widget.os.servico,
          relatoCliente: widget.os.relatoCliente,
          responsavel: widget.os.responsavel,
          temPedido: widget.os.temPedido,
          numeroPedido: widget.os.numeroPedido,
          kmInicial: widget.os.kmInicial,
          kmFinal: widget.os.kmFinal,
          horaInicio: widget.os.horaInicio,
          intervaloInicio: widget.os.intervaloInicio,
          intervaloFim: widget.os.intervaloFim,
          horaTermino: widget.os.horaTermino,
          osfinalizado: true,
          garantia: widget.os.garantia,
          pendente: false,
          pendenteDescricao: widget.os.pendenteDescricao,
          relatoTecnico: widget.os.relatoTecnico,
          assinatura: widget.os.assinatura,
          imagens: widget.os.imagens,
          funcionarios: widget.os.funcionarios,
          createdAt: widget.os.createdAt,
          updatedAt: DateTime.now(),
        );
        await _osRepository.updateOs(osAtualizada);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Diário salvo com sucesso!')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar diário: $e')),
      );
    } finally {
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
        title: const Text('Novo Diário'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DiarioFormWidget(
          numeroOs: widget.os.numeroOs,
          nomeCliente: widget.os.nomeCliente,
          osId: widget.os.id,
          isLoading: _isLoading,
          onSalvar: _salvarDiario,
          botaoTexto: 'Salvar Diário',
          servico: widget.os.servico,
          relatoCliente: widget.os.relatoCliente,
          responsavel: '',
          temPedido: widget.os.temPedido,
          numeroPedido: widget.os.numeroPedido,
        ),
      ),
    );
  }
}
