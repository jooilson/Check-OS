import 'dart:io';

import 'package:checkos/data/models/diario_model.dart';
import 'package:checkos/utils/debouncer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:checkos/presentation/widgets/funcionario_autocomplete_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DiarioFormWidget extends StatefulWidget {
  final DiarioModel? diarioParaEditar;
  final String numeroOs;
  final String nomeCliente;
  final Function(DiarioModel) onSalvar;
  final bool isLoading;
  final String? botaoTexto;
  final String osId;
  final bool isReadOnly;

  const DiarioFormWidget({
    super.key,
    this.diarioParaEditar,
    required this.numeroOs,
    required this.nomeCliente,
    required this.onSalvar,
    required this.isLoading,
    this.botaoTexto,
    required this.osId,
    this.servico,
    this.relatoCliente,
    this.responsavel,
    this.funcionarios,
    this.isReadOnly = false,
  });

  final String? servico;
  final String? relatoCliente;
  final String? responsavel;
  final List<String>? funcionarios;

  @override
  State<DiarioFormWidget> createState() => _DiarioFormWidgetState();
}

class _DiarioFormWidgetState extends State<DiarioFormWidget> {
  late TextEditingController _kmInicialController;
  late TextEditingController _kmFinalController;
  late TextEditingController _kmPercorridoController;
  late TextEditingController _horaInicioController;
  late TextEditingController _intervaloInicioController;
  late TextEditingController _intervaloFimController;
  late TextEditingController _horaTerminoController;
  late TextEditingController _servicoController;
  late TextEditingController _relatoClienteController;
  late TextEditingController _responsavelController;
  late DateTime _dataSelecionada;
  late List<TextEditingController> _funcionariosControllers;
  late TextEditingController _pendenteDescricaoController;
  late TextEditingController _relatoTecnicoController;
  late ValueNotifier<List<Offset?>> _signatureNotifier;
  late List<String> _imagensUrls;
  
  // Debouncer para validações em tempo real (otimização de performance)
  late Debouncer _kmDebouncer;
  bool _osfinalizado = false;
  bool _garantia = false;
  bool _pendente = false;
  bool _scrollEnabled = true;
  bool _formChanged = false;
  final _formKey = GlobalKey<FormState>();

  String _serializeSignature(List<Offset?> points) {
    return points.map((p) => p == null ? 'null' : '${p.dx},${p.dy}').join(';');
  }

  List<Offset?> _deserializeSignature(String signature) {
    if (signature.isEmpty || signature.trim().isEmpty) return [];
    try {
      final parts = signature.split(';');
      return parts.map((s) {
        if (s.trim().isEmpty || s == 'null') return null;
        final coords = s.split(',');
        if (coords.length != 2) return null;
        final dx = double.tryParse(coords[0].trim());
        final dy = double.tryParse(coords[1].trim());
        if (dx != null && dy != null) {
          return Offset(dx, dy);
        }
        return null;
      }).toList();
    } catch (e) {
      print('Erro ao desserializar assinatura: $e');
      return [];
    }
  }

  void _calcularKmPercorrido() {
    final inicial = double.tryParse(_kmInicialController.text);
    final finalKm = double.tryParse(_kmFinalController.text);

    if (inicial != null && finalKm != null && finalKm >= inicial) {
      final diff = finalKm - inicial;
      // Remove zeros decimais desnecessários (ex: 50.0 -> 50)
      _kmPercorridoController.text =
          diff.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
    } else {
      _kmPercorridoController.text = '';
    }
  }

  @override
  void initState() {
    super.initState();
    _signatureNotifier = ValueNotifier<List<Offset?>>([]);
    _dataSelecionada = widget.diarioParaEditar?.data ?? DateTime.now();
    
    // Inicializa o Debouncer para validações em tempo real
    _kmDebouncer = Debouncer(delay: const Duration(milliseconds: 300));
    
    _kmInicialController =
        TextEditingController(text: widget.diarioParaEditar?.kmInicial?.toString() ?? '');
    _kmFinalController =
        TextEditingController(text: widget.diarioParaEditar?.kmFinal?.toString() ?? '');
    _kmPercorridoController = TextEditingController();

    // Usa debouncer para evitar chamadas excessivas durante digitação
    _kmInicialController.addListener(() {
      _kmDebouncer.run(_calcularKmPercorrido);
    });
    _kmFinalController.addListener(() {
      _kmDebouncer.run(_calcularKmPercorrido);
    });
    _calcularKmPercorrido(); // Calcular valor inicial se houver dados

    _horaInicioController =
        TextEditingController(text: widget.diarioParaEditar?.horaInicio ?? '');
    _intervaloInicioController =
        TextEditingController(text: widget.diarioParaEditar?.intervaloInicio ?? '');
    _intervaloFimController =
        TextEditingController(text: widget.diarioParaEditar?.intervaloFim ?? '');
    _horaTerminoController =
        TextEditingController(text: widget.diarioParaEditar?.horaTermino ?? '');
    _servicoController =
        TextEditingController(text: widget.diarioParaEditar?.servico ?? widget.servico ?? '');
    _relatoClienteController =
        TextEditingController(text: widget.diarioParaEditar?.relatoCliente ?? widget.relatoCliente ?? '');
    _responsavelController =
        TextEditingController(text: widget.diarioParaEditar?.responsavel ?? widget.responsavel ?? '');
    _pendenteDescricaoController =
        TextEditingController(text: widget.diarioParaEditar?.pendenteDescricao ?? '');
    _relatoTecnicoController =
        TextEditingController(text: widget.diarioParaEditar?.relatoTecnico ?? '');
    
    if (widget.diarioParaEditar != null && widget.diarioParaEditar!.funcionarios.isNotEmpty) {
      _funcionariosControllers = widget.diarioParaEditar!.funcionarios
          .map((f) => TextEditingController(text: f))
          .toList();
    } else if (widget.funcionarios != null && widget.funcionarios!.isNotEmpty) {
      _funcionariosControllers = widget.funcionarios!
          .map((f) => TextEditingController(text: f))
          .toList();
    } else {
      _funcionariosControllers = [TextEditingController()];
    }
    
    _osfinalizado = widget.diarioParaEditar?.osfinalizado ?? false;
    _garantia = widget.diarioParaEditar?.garantia ?? false;
    _pendente = widget.diarioParaEditar?.pendente ?? false;
    _imagensUrls = widget.diarioParaEditar?.imagens ?? [];
    
    if (widget.diarioParaEditar?.assinatura != null && widget.diarioParaEditar!.assinatura!.isNotEmpty) {
      _signatureNotifier.value = _deserializeSignature(widget.diarioParaEditar!.assinatura!);
    }
  }

  @override
  void dispose() {
    _kmDebouncer.dispose();
    _kmInicialController.dispose();
    _kmFinalController.dispose();
    _kmPercorridoController.dispose();
    _horaInicioController.dispose();
    _intervaloInicioController.dispose();
    _intervaloFimController.dispose();
    _horaTerminoController.dispose();
    _servicoController.dispose();
    _relatoClienteController.dispose();
    _responsavelController.dispose();
    _pendenteDescricaoController.dispose();
    _relatoTecnicoController.dispose();
    _signatureNotifier.dispose();
    for (var controller in _funcionariosControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      final assinatura = _serializeSignature(_signatureNotifier.value);
      final funcionarios = _funcionariosControllers
          .map((c) => c.text)
          .where((text) => text.isNotEmpty)
          .toList();
      
      final diario = DiarioModel(
        id: widget.diarioParaEditar?.id ?? '',
        osId: widget.osId,
        numeroOs: widget.numeroOs,
        numeroDiario: widget.diarioParaEditar?.numeroDiario ?? 0.0,
        nomeCliente: widget.nomeCliente,
        servico: _servicoController.text.isNotEmpty ? _servicoController.text : null,
        relatoCliente: _relatoClienteController.text.isNotEmpty ? _relatoClienteController.text : null,
        responsavel: _responsavelController.text.isNotEmpty ? _responsavelController.text : null,
        funcionarios: funcionarios,
        data: _dataSelecionada,
        kmInicial: _kmInicialController.text.isEmpty
            ? null
            : double.parse(_kmInicialController.text),
        kmFinal: _kmFinalController.text.isEmpty
            ? null
            : double.parse(_kmFinalController.text),
        horaInicio:
            _horaInicioController.text.isEmpty ? null : _horaInicioController.text,
        intervaloInicio: _intervaloInicioController.text.isEmpty
            ? null
            : _intervaloInicioController.text,
        intervaloFim: _intervaloFimController.text.isEmpty
            ? null
            : _intervaloFimController.text,
        horaTermino:
            _horaTerminoController.text.isEmpty ? null : _horaTerminoController.text,
        osfinalizado: _osfinalizado,
        garantia: _garantia,
        pendente: _pendente,
        pendenteDescricao: _pendenteDescricaoController.text.isNotEmpty 
            ? _pendenteDescricaoController.text 
            : null,
        relatoTecnico: _relatoTecnicoController.text.isNotEmpty
            ? _relatoTecnicoController.text
            : null,
        assinatura: assinatura.isNotEmpty ? assinatura : null,
        imagens: _imagensUrls,
        createdAt: widget.diarioParaEditar?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onSalvar(diario);
    }
  }
  void _selecionarImagens() async {
    final picker = ImagePicker();
    final imagens = await picker.pickMultiImage();
    if (imagens.isEmpty) return;
    final List<String> savedPaths = [];
    for (final xfile in imagens) {
      try {
        final saved = await _saveImagePersistently(xfile);
        savedPaths.add(saved);
      } catch (e) {
        // se não conseguir salvar, ainda adiciona o path original como fallback
        try {
          if (xfile.path.isNotEmpty) savedPaths.add(xfile.path);
        } catch (_) {}
      }
    }
    setState(() {
      _formChanged = true;
      _imagensUrls.addAll(savedPaths);
    });
  }

  Future<String> _saveImagePersistently(XFile xfile) async {
    // Web não suporta salvamento local de arquivos - usa o path temporário
    if (kIsWeb) {
      return xfile.path;
    }
    
    final appDir = await getApplicationDocumentsDirectory();
    final filename = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(xfile.path)}';
    final newPath = p.join(appDir.path, filename);
    final savedFile = await File(xfile.path).copy(newPath);
    return savedFile.path;
  }

  Widget _buildImageWidget(String url) {
    final file = File(url);
    return FutureBuilder<bool>(
      future: file.exists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container(
            width: 100,
            height: 100,
            color: Colors.grey[200],
            child: const Center(child: SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2))),
          );
        }
        final exists = snapshot.data ?? false;
        if (!exists) {
          return Container(
            width: 100,
            height: 100,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, size: 36, color: Colors.grey),
          );
        }
        return Image.file(File(url), width: 100, height: 100, fit: BoxFit.cover);
      },
    );
  }

  Future<void> _selecionarHora(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        controller.text = '$hour:$minute';
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (!_formChanged) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar alterações?'),
        content: const Text(
            'Existem alterações não salvas. Deseja realmente sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Form(
        key: _formKey,
        onChanged: () {
          if (!_formChanged) {
            setState(() => _formChanged = true);
          }
        },
        child: SingleChildScrollView(
          physics: _scrollEnabled ? null : const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
              'Informações do Diário',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              // Otimização: Reduzir elevation para melhorar performance de GPU
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue: widget.numeroOs,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Número da OS',
                        prefixIcon: Icon(Icons.numbers),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: widget.nomeCliente,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Cliente',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _servicoController,
                      decoration: const InputDecoration(
                        labelText: 'Serviço',
                        prefixIcon: Icon(Icons.build),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _relatoClienteController,
                      decoration: const InputDecoration(
                        labelText: 'Relato do Cliente',
                        prefixIcon: Icon(Icons.comment),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Funcionários',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              // Otimização: Reduzir elevation para melhorar performance de GPU
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    ..._funcionariosControllers.asMap().entries.map(
                      (entry) {
                        final controller = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: FuncionarioAutocompleteField(
                            controller: controller,
                            onChanged: (value) {},
                            onAddEmployee: () {
                              setState(() {
                                _formChanged = true;
                                _funcionariosControllers.add(
                                  TextEditingController(),
                                );
                              });
                            },
                            onRemoveEmployee: _funcionariosControllers.length > 1
                                ? () {
                                    setState(() {
                                      _formChanged = true;
                                      controller.dispose();
                                      _funcionariosControllers.remove(controller);
                                    });
                                  }
                                : null,
                            showRemoveButton: _funcionariosControllers.length > 1,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Horários e KM',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              // Otimização: Reduzir elevation para melhorar performance de GPU
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _kmInicialController,
                            decoration: const InputDecoration(
                              labelText: 'KM Inicial',
                              hintText: 'Digite o KM inicial',
                              prefixIcon: Icon(Icons.speed),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _kmFinalController,
                            decoration: const InputDecoration(
                              labelText: 'KM Final',
                              hintText: 'Digite o KM final',
                              prefixIcon: Icon(Icons.speed),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final kmFinal = double.tryParse(value);
                                final kmInicialText = _kmInicialController.text;
                                if (kmInicialText.isNotEmpty) {
                                  final kmInicial = double.tryParse(kmInicialText);
                                  if (kmFinal != null && kmInicial != null && kmFinal <= kmInicial) {
                                    return 'Deve ser maior que KM Inicial';
                                  }
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _kmPercorridoController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'KM Percorrido (Neste Diário)',
                        prefixIcon: Icon(Icons.directions_car),
                        border: OutlineInputBorder(),
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _horaInicioController,
                      decoration: const InputDecoration(
                        labelText: 'Hora Início',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      readOnly: true,
                      onTap: widget.isReadOnly
                          ? null
                          : () => _selecionarHora(_horaInicioController),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _horaTerminoController,
                      decoration: const InputDecoration(
                        labelText: 'Hora Término',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.access_time_filled),
                      ),
                      readOnly: true,
                      onTap: widget.isReadOnly
                          ? null
                          : () => _selecionarHora(_horaTerminoController),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _intervaloInicioController,
                      decoration: const InputDecoration(
                        labelText: 'Início Intervalo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.pause),
                      ),
                      readOnly: true,
                      onTap: widget.isReadOnly
                          ? null
                          : () => _selecionarHora(_intervaloInicioController),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _intervaloFimController,
                      decoration: const InputDecoration(
                        labelText: 'Fim Intervalo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.play_arrow),
                      ),
                      readOnly: true,
                      onTap: widget.isReadOnly
                          ? null
                          : () => _selecionarHora(_intervaloFimController),
                    ),
                  ),
                ],
              ), 
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Status do Serviço',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              // Otimização: Reduzir elevation para melhorar performance de GPU
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    CheckboxListTile(
                      title: const Text('Finalizado'),
                      value: _osfinalizado,
                      controlAffinity: ListTileControlAffinity.leading,
                      enabled: !_pendente,
                      onChanged: (value) {
                        setState(() {
                          _formChanged = true;
                          _osfinalizado = value ?? false;
                          if (_osfinalizado) {
                            _pendente = false;
                          }
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Garantia'),
                      value: _garantia,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (value) {
                        setState(() {
                          _formChanged = true;
                          _garantia = value ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Pendente'),
                      value: _pendente,
                      controlAffinity: ListTileControlAffinity.leading,
                      enabled: !_osfinalizado,
                      onChanged: (value) {
                        setState(() {
                          _formChanged = true;
                          _pendente = value ?? false;
                          if (_pendente) {
                            _osfinalizado = false;
                          }
                        });
                      },
                    ),
                    /*if (_pendente) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _pendenteDescricaoController,
                              decoration: const InputDecoration(
                                labelText: 'Descrição',
                                hintText: 'Digite a descrição',
                                prefixIcon: Icon(Icons.description),
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                          ],*/
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
                  TextFormField(
                    controller: _relatoTecnicoController,
                    decoration: const InputDecoration(
                      labelText: 'Relato Técnico / Atividades Realizadas',
                      hintText: 'Digite o relato técnico',
                      prefixIcon: Icon(Icons.engineering),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Assinatura',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _responsavelController,
                      decoration: const InputDecoration(
                        labelText: 'Responsável pelo Acompanhamento',
                        prefixIcon: Icon(Icons.person_pin),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  const SizedBox(height: 8),
Container(
  height: 150,
  width: double.infinity,
  decoration: BoxDecoration(
    border: Border.all(color: Theme.of(context).dividerColor),
    borderRadius: BorderRadius.circular(8),
  ),
  child: ClipRect(
    child: Listener(
      onPointerDown: (_) => setState(() => _scrollEnabled = false),
      onPointerUp: (_) => setState(() => _scrollEnabled = true),
      onPointerCancel: (_) => setState(() => _scrollEnabled = true),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (details) {
          if (!_formChanged) setState(() => _formChanged = true);
          _signatureNotifier.value = [
            ..._signatureNotifier.value,
            details.localPosition,
          ];
        },
        onPanUpdate: (details) {
          _signatureNotifier.value = [
            ..._signatureNotifier.value,
            details.localPosition,
          ];
        },
        onPanEnd: (details) {
          _signatureNotifier.value = [
            ..._signatureNotifier.value,
            null,
          ];
        },
        child: Container(
          color: Colors.transparent,
          child: ValueListenableBuilder<List<Offset?>>(
            valueListenable: _signatureNotifier,
            builder: (context, points, _) {
              // Otimização: RepaintBoundary isolado ao redor do CustomPaint
              return RepaintBoundary(
                child: CustomPaint(
                  key: ValueKey(points.length),
                  painter: SignaturePainter(
                    points,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  size: Size.infinite,
                ),
              );
            },
          ),
        ),
      ),
    ),
  ),
),

                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _formChanged = true;
                            _signatureNotifier.value = [];
                          });
                        },
                        child: const Text('Limpar Assinatura'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Imagens Anexadas',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _selecionarImagens,
                    child: const Text('Anexar Imagens'),
                  ),
                  if (_imagensUrls.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _imagensUrls.map((url) => _buildImageWidget(url)).toList(),
                    ),
                  ],
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: widget.isLoading ? null : _salvar,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 8,
                  ),
                  child: widget.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Text(
                          widget.botaoTexto ?? 'Salvar Diário',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: widget.isLoading
                      ? null
                      : () {
                          _onWillPop().then((shouldPop) {
                            if (shouldPop) Navigator.of(context).pop();
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                    elevation: 8,
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}
class SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  final Color color;

  SignaturePainter(this.points, {required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        if (i == 0 || points[i - 1] == null) {
          canvas.drawCircle(points[i]!, paint.strokeWidth / 2, paint);
        }
      }
    }
    if (points.isNotEmpty && points.last != null) {
      if (points.length == 1 || points[points.length - 2] == null) {
        canvas.drawCircle(points.last!, paint.strokeWidth / 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SignaturePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.color != color;
  }
}