import 'package:checkos/data/models/employee/employee_model.dart';
import 'package:checkos/data/repositories/employee_repository.dart';
import 'package:checkos/presentation/pages/employee_management/employee_add_page.dart';
import 'package:flutter/material.dart';

class FuncionarioAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback? onAddEmployee;
  final VoidCallback? onRemoveEmployee;
  final bool showRemoveButton;

  const FuncionarioAutocompleteField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onAddEmployee,
    this.onRemoveEmployee,
    this.showRemoveButton = true,
  });

  @override
  State<FuncionarioAutocompleteField> createState() =>
      _FuncionarioAutocompleteFieldState();
}

class _FuncionarioAutocompleteFieldState
    extends State<FuncionarioAutocompleteField> {
  final EmployeeRepository _employeeRepository = EmployeeRepository();
  late FocusNode _focusNode;
  List<EmployeeModel> _funcionarios = [];
  List<EmployeeModel> _filtrados = [];
  bool _isLoadingFuncionarios = true;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _carregarFuncionarios();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      if (widget.controller.text.isEmpty) {
        setState(() {
          _filtrados = _funcionarios;
          _showSuggestions = true;
        });
      }
    } else {
      _promptToRegisterNewEmployeeIfNeeded();
    }
  }

  Future<void> _carregarFuncionarios() async {
    try {
      final funcionarios = await _employeeRepository.getEmployeesList();
      setState(() {
        _funcionarios = funcionarios;
        _isLoadingFuncionarios = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingFuncionarios = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar funcionários: $e')),
        );
      }
    }
  }

  void _filtrarFuncionarios(String value) {
    setState(() {
      if (value.isEmpty) {
        _filtrados = _funcionarios;
        _showSuggestions = _focusNode.hasFocus;
      } else {
        _filtrados = _funcionarios
            .where((f) => f.name.toLowerCase().contains(value.toLowerCase()))
            .toList();
        _showSuggestions = _filtrados.isNotEmpty;
      }
    });
  }

  void _selecionarFuncionario(EmployeeModel funcionario) {
    widget.controller.text = funcionario.name;
    widget.onChanged(funcionario.name);
    setState(() {
      _showSuggestions = false;
    });
    _focusNode.unfocus();
  }

  Future<void> _promptToRegisterNewEmployeeIfNeeded() async {
    final typedName = widget.controller.text.trim();
    if (typedName.isNotEmpty && _filtrados.isEmpty) {
      final exists = _funcionarios
          .any((f) => f.name.toLowerCase() == typedName.toLowerCase());
      if (!exists) {
        await _solicitarNovoFuncionario();
      }
    }
    if (mounted) {
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  Future<void> _solicitarNovoFuncionario() async {
    final nomeDigitado = widget.controller.text.trim();

    if (nomeDigitado.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o nome do funcionário primeiro')),
      );
      return;
    }

    // Verificar se já existe
    final jaExiste = _funcionarios
        .any((f) => f.name.toLowerCase() == nomeDigitado.toLowerCase());

    if (jaExiste) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este funcionário já está cadastrado')),
      );
      return;
    }

    if (mounted) {
      final resultado = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cadastrar Novo Funcionário'),
          content: Text(
            'O funcionário "$nomeDigitado" não está cadastrado. Deseja cadastrá-lo agora?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cadastrar'),
            ),
          ],
        ),
      );

      if (resultado == true && mounted) {
        // Usar EmployeeAddPage para cadastrar novo funcionário
        final novoFuncionarioCadastrado = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => const EmployeeAddPage(),
          ),
        );

        if (novoFuncionarioCadastrado == true || novoFuncionarioCadastrado == null) {
          await _carregarFuncionarios();

          if (_funcionarios.isNotEmpty) {
            final novoFuncionario = _funcionarios.firstWhere(
              (f) => f.name.toLowerCase() == nomeDigitado.toLowerCase(),
              orElse: () => _funcionarios.first,
            );
            _selecionarFuncionario(novoFuncionario);
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Funcionário cadastrado com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: 'Nome do Funcionário',
            hintText: 'Digite o nome do funcionário',
            prefixIcon: const Icon(Icons.person),
            border: const OutlineInputBorder(),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.green),
                  tooltip: 'Adicionar funcionário',
                  onPressed: widget.onAddEmployee,
                ),
                if (widget.showRemoveButton)
                  IconButton(
                    icon: const Icon(Icons.remove, color: Colors.red),
                    tooltip: 'Remover funcionário',
                    onPressed: widget.onRemoveEmployee,
                  ),
              ],
            ),
          ),
          onChanged: _filtrarFuncionarios,
          onFieldSubmitted: (value) {
            _promptToRegisterNewEmployeeIfNeeded();
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Campo obrigatório';
            }

            final funcionarioExiste = _funcionarios.any(
              (f) => f.name.toLowerCase() == value.toLowerCase(),
            );

            if (!funcionarioExiste) {
              return 'Funcionário não cadastrado.';
            }

            return null;
          },
        ),
        if (_showSuggestions && _filtrados.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              // Otimização: CacheExtent para manter itens na memória durante scroll
              cacheExtent: 200,
              itemCount: _filtrados.length,
              itemBuilder: (context, index) {
                final funcionario = _filtrados[index];
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  title: Text(funcionario.name),
                  subtitle: Text(funcionario.role),
                  onTap: () => _selecionarFuncionario(funcionario),
                );
              },
            ),
          ),
        if (_showSuggestions &&
            _filtrados.isEmpty &&
            widget.controller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ElevatedButton.icon(
              onPressed: _solicitarNovoFuncionario,
              icon: const Icon(Icons.person_add),
              label: Text('Cadastrar "${widget.controller.text}"'),
            ),
          ),
      ],
    );
  }
}
