import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:checkos/core/context/employee_context.dart';
import 'package:checkos/data/models/employee/employee_model.dart';
import 'package:checkos/data/repositories/employee_repository.dart';
import 'package:checkos/services/firebase/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmployeeAddPage extends StatefulWidget {
  final EmployeeModel? employee;

  const EmployeeAddPage({super.key, this.employee});

  @override
  State<EmployeeAddPage> createState() => _EmployeeAddPageState();
}

class _EmployeeAddPageState extends State<EmployeeAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _authService = AuthService();
  final _employeeRepository = EmployeeRepository();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isActive = true;
  String _selectedRole = 'employee'; // Padrão: funcionário comum
  
  String? _editingEmployeeId;
  String? _editingCompanyId;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _isEditMode = true;
      _editingEmployeeId = widget.employee!.id;
      _editingCompanyId = widget.employee!.companyId;
      _nameController.text = widget.employee!.name;
      _emailController.text = widget.employee!.email;
      _isActive = widget.employee!.isActive;
      _selectedRole = widget.employee!.role;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Obtém o companyId do admin logado com tratamento de erro completo
  Future<String?> _getCompanyId() async {
    try {
      if (!mounted) return null;
      
      final employeeContext = context.read<EmployeeContext>();
      final companyIdFromContext = employeeContext.currentCompanyId;
      
      debugPrint('[EmployeeAddPage] CompanyId do EmployeeContext: $companyIdFromContext');
      
      if (companyIdFromContext != null && companyIdFromContext.isNotEmpty) {
        return companyIdFromContext;
      }
    } catch (e) {
      debugPrint('[EmployeeAddPage] Erro ao obter companyId do contexto: $e');
    }

    if (_isEditMode && widget.employee != null) {
      final companyId = widget.employee!.companyId;
      debugPrint('[EmployeeAddPage] CompanyId do widget.employee: $companyId');
      if (companyId != null && companyId.isNotEmpty) {
        return companyId;
      }
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('[EmployeeAddPage] Usuário não autenticado');
        return null;
      }
      
      debugPrint('[EmployeeAddPage] UID do usuário: ${user.uid}');
      final companyId = await _employeeRepository.getCompanyIdByUid(user.uid);
      
      if (companyId != null && companyId.isNotEmpty) {
        debugPrint('[EmployeeAddPage] CompanyId encontrado via Repository: $companyId');
        return companyId;
      }

      debugPrint('[EmployeeAddPage] CompanyId não encontrado');
      return null;
    } catch (e) {
      debugPrint('[EmployeeAddPage] Erro ao buscar companyId: $e');
      return null;
    }
  }

  /// Função para cadastrar funcionário com tratamento completo
  Future<void> _cadastrarFuncionario() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final companyId = await _getCompanyId();
      
      debugPrint('[EmployeeAddPage] companyId obtido: $companyId');

      if (companyId == null || companyId.isEmpty) {
        setState(() {
          _errorMessage = 'Erro: Empresa não encontrada. Faça login novamente.';
          _isLoading = false;
        });
        return;
      }

      final companyDoc = await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .get();
      
      if (!companyDoc.exists) {
        setState(() {
          _errorMessage = 'Erro: Empresa inválida. Faça login novamente.';
          _isLoading = false;
        });
        return;
      }

      debugPrint('[EmployeeAddPage] Cadastrando funcionário na empresa: $companyId com role: $_selectedRole');

      // Cadastrar o funcionário via AuthService
      await _authService.registerEmployee(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        companyId: companyId,
        role: _selectedRole, // Enviando o role selecionado
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_selectedRole == 'admin' 
              ? 'Administrador cadastrado com sucesso!' 
              : 'Funcionário cadastrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Ocorreu um erro ao salvar.';
      if (e.code == 'weak-password') {
        message = 'A senha fornecida é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Este email já está em uso por outra conta.';
      } else if (e.code == 'invalid-email') {
        message = 'O formato do email é inválido.';
      } else if (e.code == 'requires-recent-login') {
        message = 'Sessão expirada. Faça login novamente.';
      }
      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[EmployeeAddPage] Erro desconhecido: $e');
      setState(() {
        _errorMessage = 'Erro desconhecido. Tente novamente.';
        _isLoading = false;
      });
    }
  }

  /// Função para atualizar funcionário existente
  Future<void> _atualizarFuncionario() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_passwordController.text.isNotEmpty) {
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await user.updatePassword(_passwordController.text.trim());
          }
        } catch (e) {
          setState(() {
            _errorMessage = 'Erro ao atualizar senha. Faça login novamente.';
            _isLoading = false;
          });
          return;
        }
      }

      final updatedEmployee = widget.employee!.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        role: _selectedRole,
        isActive: _isActive,
        updatedAt: DateTime.now(),
      );

      await _employeeRepository.updateEmployee(updatedEmployee);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Funcionário atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao atualizar funcionário.';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveEmployee() async {
    if (_isEditMode) {
      await _atualizarFuncionario();
    } else {
      await _cadastrarFuncionario();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar Funcionário' : 'Cadastrar Funcionário'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: colorScheme.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira o nome do funcionário';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira o email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Por favor, insira um email válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password fields (for new and edit mode)
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: _isEditMode ? 'Nova Senha (opcional)' : 'Senha',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
                validator: (value) {
                  if (_isEditMode && (value == null || value.isEmpty)) {
                    return null;
                  }
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma senha';
                  }
                  if (value.length < 6) {
                    return 'A senha deve ter no mínimo 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: _isEditMode ? 'Confirmar Nova Senha' : 'Confirmar Senha',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                  ),
                ),
                validator: (value) {
                  if (_isEditMode && (value == null || value.isEmpty)) {
                    return null;
                  }
                  if (value != _passwordController.text) {
                    return 'As senhas não conferem';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tipo de Usuário (Role) - NOVO CAMPO
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.admin_panel_settings,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tipo de Acesso',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    RadioListTile<String>(
                      title: const Text('Funcionário'),
                      subtitle: const Text('Acesso básico ao sistema'),
                      value: 'employee',
                      groupValue: _selectedRole,
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    RadioListTile<String>(
                      title: const Text('Administrador'),
                      subtitle: const Text('Acesso total: gerenciar funcionários, empresas e configurações'),
                      value: 'admin',
                      groupValue: _selectedRole,
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Ativo/Inativo Switch
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: _isActive ? Colors.green.withAlpha(26) : Colors.red.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isActive ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isActive ? Icons.check_circle : Icons.cancel,
                          color: _isActive ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _isActive ? 'Funcionário Ativo' : 'Funcionário Inativo',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: _isActive ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                      activeColor: Colors.green,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveEmployee,
                icon: _isLoading
                    ? const SizedBox()
                    : Icon(_isEditMode ? Icons.save : Icons.person_add_alt_1),
                label: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditMode ? 'SALVAR' : 'CADASTRAR'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

