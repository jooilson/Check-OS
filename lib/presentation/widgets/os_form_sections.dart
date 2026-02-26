import 'dart:io';
import 'package:checkos/presentation/widgets/funcionario_autocomplete_field.dart';
import 'package:checkos/utils/formatters.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

// --- Seção de Informações Básicas ---
class OsInfoBasicaForm extends StatelessWidget {
  final TextEditingController numeroOsController;
  final TextEditingController nomeClienteController;
  final TextEditingController servicoController;
  final TextEditingController relatoClienteController;
  final TextEditingController responsavelController;
  final TextEditingController numeroPedidoController;
  final bool temPedido;
  final ValueChanged<bool?> onTemPedidoChanged;
  final String? numeroOsError;

  const OsInfoBasicaForm({
    super.key,
    required this.numeroOsController,
    required this.nomeClienteController,
    required this.servicoController,
    required this.relatoClienteController,
    required this.responsavelController,
    required this.numeroPedidoController,
    required this.temPedido,
    required this.onTemPedidoChanged,
    this.numeroOsError,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      // Otimização: Reduzir elevation para melhorar performance de GPU
      elevation: 2,
      shadowColor: Theme.of(context).colorScheme.shadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextFormField(
              controller: numeroOsController,
              decoration: InputDecoration(
                labelText: 'Número da OS',
                hintText: 'Digite o número da OS',
                prefixIcon: const Icon(Icons.numbers),
                border: const OutlineInputBorder(),
                errorText: numeroOsError,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) return 'Por favor, insira o número da OS';
                if (int.tryParse(value) == null) return 'O número da OS deve ser numérico';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: nomeClienteController,
              inputFormatters: [TitleCaseInputFormatter()],
              decoration: InputDecoration(
                labelText: 'Nome do Cliente',
                hintText: 'Digite o nome do cliente',
                prefixIcon: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                border: const OutlineInputBorder(),
              ),
              validator: (value) => (value == null || value.isEmpty) ? 'Por favor, insira o nome do cliente' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: servicoController,
              decoration: const InputDecoration(
                labelText: 'Serviço',
                hintText: 'Digite o serviço',
                prefixIcon: Icon(Icons.build),
                border: OutlineInputBorder(),
              ),
              validator: (value) => (value == null || value.isEmpty) ? 'Por favor, insira o serviço' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: relatoClienteController,
              decoration: const InputDecoration(
                labelText: 'Relato do Cliente',
                hintText: 'Digite o relato do cliente',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) => (value == null || value.isEmpty) ? 'Por favor, insira o relato do cliente' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: responsavelController,
              decoration: const InputDecoration(
                labelText: 'Responsável pelo Acompanhamento',
                hintText: 'Digite o responsável',
                prefixIcon: Icon(Icons.supervisor_account),
                border: OutlineInputBorder(),
              ),
              validator: (value) => (value == null || value.isEmpty) ? 'Por favor, insira o responsável' : null,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('OS com Pedido'),
              value: temPedido,
              onChanged: onTemPedidoChanged,
            ),
            if (temPedido) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: numeroPedidoController,
                decoration: const InputDecoration(
                  labelText: 'Número do Pedido',
                  hintText: 'Digite o número do pedido',
                  prefixIcon: Icon(Icons.receipt),
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (temPedido && (value == null || value.isEmpty)) return 'Por favor, insira o número do pedido';
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// --- Seção de Funcionários ---
class OsFuncionariosForm extends StatelessWidget {
  final List<TextEditingController> controllers;
  final VoidCallback onAdd;
  final Function(int index) onRemove;

  const OsFuncionariosForm({
    super.key,
    required this.controllers,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      // Otimização: Reduzir elevation para melhorar performance de GPU
      elevation: 2,
      shadowColor: Theme.of(context).colorScheme.shadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ...controllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: FuncionarioAutocompleteField(
                  controller: controller,
                  onChanged: (value) {},
                  onAddEmployee: onAdd,
                  onRemoveEmployee: controllers.length > 1 ? () => onRemove(index) : null,
                  showRemoveButton: controllers.length > 1,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// --- Seção de Horários e KM ---
class OsHorariosKmForm extends StatelessWidget {
  final TextEditingController kmInicialController;
  final TextEditingController kmFinalController;
  final TextEditingController kmPercorridoController;
  final TextEditingController horaInicioController;
  final TextEditingController horaTerminoController;
  final TextEditingController intervaloInicioController;
  final TextEditingController intervaloFimController;
  final bool isReadOnly;
  final Function(TextEditingController) onSelectTime;

  const OsHorariosKmForm({
    super.key,
    required this.kmInicialController,
    required this.kmFinalController,
    required this.kmPercorridoController,
    required this.horaInicioController,
    required this.horaTerminoController,
    required this.intervaloInicioController,
    required this.intervaloFimController,
    required this.isReadOnly,
    required this.onSelectTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      // Otimização: Reduzir elevation para melhorar performance de GPU
      elevation: 2,
      shadowColor: Theme.of(context).colorScheme.shadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: kmInicialController,
                    decoration: const InputDecoration(
                      labelText: 'KM Inicial',
                      hintText: 'Digite o KM inicial',
                      prefixIcon: Icon(Icons.speed),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: kmFinalController,
                    decoration: const InputDecoration(
                      labelText: 'KM Final',
                      hintText: 'Digite o KM final',
                      prefixIcon: Icon(Icons.speed),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final kmFinal = double.tryParse(value);
                        final kmInicial = double.tryParse(kmInicialController.text);
                        if (kmFinal != null && kmInicial != null && kmFinal <= kmInicial) {
                          return 'Deve ser maior que KM Inicial';
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
              controller: kmPercorridoController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'KM Percorrido',
                prefixIcon: Icon(Icons.directions_car),
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            _buildTimeRow(context, 'Hora Início', horaInicioController, 'Hora Término', horaTerminoController),
            const SizedBox(height: 16),
            _buildTimeRow(context, 'Início Intervalo', intervaloInicioController, 'Fim Intervalo', intervaloFimController),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRow(BuildContext context, String label1, TextEditingController ctrl1, String label2, TextEditingController ctrl2) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: ctrl1,
            decoration: InputDecoration(labelText: label1, border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.access_time)),
            readOnly: true,
            onTap: isReadOnly ? null : () => onSelectTime(ctrl1),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: ctrl2,
            decoration: InputDecoration(labelText: label2, border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.access_time_filled)),
            readOnly: true,
            onTap: isReadOnly ? null : () => onSelectTime(ctrl2),
          ),
        ),
      ],
    );
  }
}

// --- Seção de Imagens (Stateful para isolar o loading) ---
class OsImagensForm extends StatefulWidget {
  final List<String> imagensUrls;
  final Function(List<String>) onImagensChanged;

  const OsImagensForm({
    super.key,
    required this.imagensUrls,
    required this.onImagensChanged,
  });

  @override
  State<OsImagensForm> createState() => _OsImagensFormState();
}

class _OsImagensFormState extends State<OsImagensForm> {
  bool _isUploading = false;

  Future<void> _selecionarImagens() async {
    final picker = ImagePicker();
    // Otimização: Limita qualidade e tamanho na origem para economizar RAM e Dados
    final imagens = await picker.pickMultiImage(
      imageQuality: 70,
      maxWidth: 1024,
    );
    if (imagens.isEmpty) return;

    setState(() => _isUploading = true);

    final List<String> newUrls = List.from(widget.imagensUrls);
    for (final xfile in imagens) {
      try {
        final url = await _uploadImage(xfile);
        newUrls.add(url);
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao enviar imagem: $e')));
      }
    }

    widget.onImagensChanged(newUrls);
    if (mounted) setState(() => _isUploading = false);
  }

  Future<String> _uploadImage(XFile xfile) async {
    final ext = p.extension(xfile.path);
    final filename = '${DateTime.now().millisecondsSinceEpoch}${ext.isEmpty ? ".jpg" : ext}';
    final ref = FirebaseStorage.instance.ref().child('os_images').child(filename);
    final mimeType = ext.toLowerCase().contains('png') ? 'image/png' : 'image/jpeg';
    final metadata = SettableMetadata(contentType: mimeType);

    // Otimização: Usa putFile para streaming direto do disco (menos RAM)
    final snapshot = await ref.putFile(File(xfile.path), metadata).whenComplete(() {});
    if (snapshot.state != TaskState.success) throw Exception('Falha no upload');
    return await snapshot.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ElevatedButton(onPressed: _selecionarImagens, child: const Text('Anexar Imagens')),
        if (_isUploading) const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Center(child: CircularProgressIndicator())),
        if (widget.imagensUrls.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.imagensUrls.asMap().entries.map((entry) {
              final index = entry.key;
              final url = entry.value;
              return Stack(
                children: [
                  _buildImagePreview(url),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        final newUrls = List<String>.from(widget.imagensUrls)..removeAt(index);
                        widget.onImagensChanged(newUrls);
                      },
                      child: Container(
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildImagePreview(String url) {
    if (url.startsWith('http')) {
      return Container(
        width: 100,
        height: 100,
        color: Colors.grey[200],
        child: Image.network(
          url,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          cacheWidth: 200, // Otimização de Memória: Decodifica menor
          cacheHeight: 200,
          loadingBuilder: (ctx, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator()),
          errorBuilder: (ctx, err, stack) => const Icon(Icons.error),
        ),
      );
    } else {
      return Container(
        width: 100,
        height: 100,
        color: Colors.grey[200],
        child: Image.file(
          File(url),
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          cacheWidth: 200, // Otimização de Memória: Decodifica menor
          cacheHeight: 200,
          errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, size: 36, color: Colors.grey),
        ),
      );
    }
  }
}

// --- Painter da Assinatura ---
class SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  final Color strokeColor;
  final Paint _paint;

  SignaturePainter({required this.points, required this.strokeColor})
      : _paint = Paint()
          ..color = strokeColor
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, _paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SignaturePainter oldDelegate) {
    // Otimização: Comparação mais eficiente - verifica se os pontos são diferentes
    // usando a verificação de identidade primeiro (快速路径)
    if (identical(points, oldDelegate.points)) return false;
    if (points.length != oldDelegate.points.length) return true;
    
    // Verificação detalhada apenas se o tamanho for igual
    for (int i = 0; i < points.length; i++) {
      if (points[i] != oldDelegate.points[i]) return true;
    }
    return false;
  }
}
