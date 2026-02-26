import 'package:checkos/core/context/employee_context.dart';
import 'package:checkos/data/models/employee/employee_model.dart';
import 'package:checkos/data/repositories/employee_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmployeeRegistrationPage extends StatefulWidget {
  final VoidCallback onComplete;
  final String? initialName;
  final EmployeeModel? employee;

  const EmployeeRegistrationPage({
    super.key,
    required this.onComplete,
    this.initialName,
    this.employee,
  });

  @override
  State<EmployeeRegistrationPage> createState() =>
      _EmployeeRegistrationPageState();
}

class _EmployeeRegistrationPageState extends State<EmployeeRegistrationPage> {
  final EmployeeRepository _employeeRepository = EmployeeRepository();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final List<EmployeeModel> _addedEmployees = [];
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  EmployeeModel? _editableEmployee;
  bool _isInitialized = false;

  bool get _isEditMode => _editableEmployee != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final employeeArg = (args is EmployeeModel) ? args : widget.employee;

      if (employeeArg != null) {
        _editableEmployee = employeeArg;
        _populateFields(_editableEmployee!);
      } else if (widget.initialName != null) {
        _nameController.text = widget.initialName!;
      }
      _isInitialized = true;
    }
  }

  void _populateFields(EmployeeModel employee) {
    _nameController.text = employee.name;
    _emailController.text = employee.email;
    _roleController.text = employee.role;
    _phoneController.text = employee.phone;
    _cpfController.text = employee.cpf ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _roleController.dispose();
    _phoneController.dispose();
    _cpfController.dispose();
    super.dispose();
  }

  Future<void> _saveEmployee() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        (!_isEditMode && _passwordController.text.isEmpty) ||
        _roleController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, preencha todos os campos obrigatórios')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final emailInput = _emailController.text.trim();
      bool shouldCheckEmail = true;

      if (_isEditMode) {
        // Só verifica se o email mudou
        shouldCheckEmail = _editableEmployee!.email.toLowerCase() != emailInput.toLowerCase();
      }

      if (shouldCheckEmail) {
        final emailJaExiste =
            await _employeeRepository.emailExists(_emailController.text.trim());
        if (emailJaExiste) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Este email já está cadastrado')),
            );
          }
          setState(() => _isLoading = false);
          return;
        }
      }

      final employee = EmployeeModel(
        id: _isEditMode ? _editableEmployee!.id : '',
        name: _nameController.text.trim(),
        email: emailInput,
        role: _roleController.text.trim(),
        phone: _phoneController.text.trim(),
        cpf: _cpfController.text.isEmpty ? null : _cpfController.text.trim(),
        isActive: _isEditMode ? _editableEmployee!.isActive : true,
        createdAt: _isEditMode ? _editableEmployee!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEditMode) {
        await _employeeRepository.updateEmployee(employee);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Funcionário atualizado com sucesso!')),
          );
          Navigator.of(context).pop(true); // Retorna true para indicar sucesso
        }
      } else {
        // Para novo funcionário, busca o companyId do admin logado no Firestore
        final companyId = await _getCompanyId();
        if (companyId == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Erro: Empresa não encontrada. Faça login novamente.')),
            );
          }
          setState(() => _isLoading = false);
          return;
        }
        await _employeeRepository.addEmployee(employee, password: _passwordController.text.trim(), companyId: companyId);
        if (mounted) {
          setState(() {
            _addedEmployees.add(employee);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Funcionário adicionado com sucesso!')),
          );
        }
        _clearForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Erro ao ${_isEditMode ? 'atualizar' : 'adicionar'} funcionário: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _roleController.clear();
    _phoneController.clear();
    _cpfController.clear();
  }

  void _removeEmployee(int index) {
    setState(() {
      _addedEmployees.removeAt(index);
    });
  }

  void _continueWithoutEmployees() {
    widget.onComplete();
  }

  void _continueWithEmployees() {
    if (_addedEmployees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um funcionário')),
      );
      return;
    }
    widget.onComplete();
  }

  /// Busca o companyId do usuário logado no Firestore
  Future<String?> _getCompanyId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      // Busca na coleção employees primeiro (fonte principal)
      final employeeDoc = await FirebaseFirestore.instance
          .collection('employees')
          .doc(user.uid)
          .get();
      
      if (employeeDoc.exists && employeeDoc.data() != null) {
        return employeeDoc.data()!['companyId'];
      }

      // Fallback para coleção users
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (userDoc.exists && userDoc.data() != null) {
        return userDoc.data()!['companyId'];
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode
            ? 'Editar Funcionário'
            : 'Cadastre seus Funcionários'),
        automaticallyImplyLeading: _isEditMode,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isEditMode) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.primary, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 Próximo Passo: Cadastro de Funcionários',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Adicione os funcionários da sua equipe para melhor controle de auditoria. Você saberá exatamente quem criou, editou ou excluiu cada Ordem de Serviço.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            // Formulário de Adição
            Text(
              _isEditMode ? 'Dados do Funcionário' : 'Adicionar Funcionário',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome *',
                hintText: 'Digite o nome do funcionário',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email *',
                hintText: 'email@empresa.com',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            if (!_isEditMode) ...[
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Senha *',
                  hintText: 'Digite a senha',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _roleController,
              decoration: InputDecoration(
                labelText: 'Cargo *',
                hintText: 'Ex: Técnico, Encanador, etc.',
                prefixIcon: const Icon(Icons.work),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Telefone *',
                hintText: '(XX) XXXXX-XXXX',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cpfController,
              decoration: InputDecoration(
                labelText: 'CPF',
                hintText: 'XXX.XXX.XXX-XX',
                prefixIcon: const Icon(Icons.badge),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveEmployee,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_isEditMode ? Icons.save : Icons.add),
                label:
                    Text(_isEditMode ? 'Salvar Alterações' : 'Adicionar Funcionário'),
              ),
            ),
            const SizedBox(height: 24),
            // Lista de Funcionários Adicionados
            if (!_isEditMode && _addedEmployees.isNotEmpty) ...[
              Text(
                'Funcionários Adicionados (${_addedEmployees.length})',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                // Otimização: CacheExtent para manter itens na memória durante scroll
                cacheExtent: 200,
                itemCount: _addedEmployees.length,
                itemBuilder: (context, index) {
                  final employee = _addedEmployees[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          employee.name.isNotEmpty
                              ? employee.name[0].toUpperCase()
                              : '?',
                        ),
                      ),
                      title: Text(employee.name),
                      subtitle: Text('${employee.role} • ${employee.email}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeEmployee(index),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
            // Botões de Ação
            if (!_isEditMode) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _addedEmployees.isEmpty ? null : _continueWithEmployees,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Continuar com Funcionários'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _continueWithoutEmployees,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Pular Cadastro de Funcionários'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
