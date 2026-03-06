import 'package:checkos/core/constants/app_route_names.dart';
import 'package:checkos/core/constants/app_strings.dart';
import 'package:checkos/core/constants/login_strings.dart';
import 'package:checkos/core/context/employee_context.dart';
import 'package:checkos/data/models/employee/employee_model.dart';
import 'package:checkos/data/repositories/employee_repository.dart';
import 'package:checkos/services/firebase/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({Key? key, required this.showRegisterPage}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  // text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _rememberMe = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  void _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    if (email != null) {
      setState(() {
        _emailController.text = email;
        _rememberMe = true;
      });
    }
  }

  Future<void> _signIn() async {
    // Valida o formulário antes de continuar
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (_rememberMe) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', _emailController.text.trim());
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('email');
    }

    try {
      // 1. Realiza o login no Firebase Auth
      final userCredential = await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Verifica o papel (role) do usuário no Firestore
      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;
        debugPrint("USER: ${userCredential.user?.uid}");
        
        final role = await _authService.getUserRole(uid);
        
        // 3. Busca os dados do funcionário atual (filtrando pelo UID do usuário logado)
        final employeeRepo = EmployeeRepository();
        
        // Busca o funcionário pelo ID do usuário autenticado
        var currentEmployee = await employeeRepo.getEmployeeById(uid);
        
        // Fallback: se não encontrar em employees, busca em users
        if (currentEmployee == null) {
          debugPrint('[LoginPage] Funcionário não encontrado em employees, buscando em users...');
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get();
          
          if (userDoc.exists && userDoc.data() != null) {
            final data = userDoc.data() as Map<String, dynamic>;
            // Cria um EmployeeModel a partir dos dados do usuário
            currentEmployee = EmployeeModel(
              id: uid,
              name: data['name'] ?? '',
              email: data['email'] ?? '',
              role: data['role'] ?? 'employee',
              phone: '',
              companyId: data['companyId'],
              isActive: data['isActive'] ?? true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            debugPrint('[LoginPage] Funcionário encontrado em users: ${currentEmployee.name}, companyId: ${currentEmployee.companyId}');
          }
        }
        
        if (currentEmployee == null) {
          // ERRO: Usuário não encontrado em nenhuma coleção
          debugPrint('[LoginPage] ERRO: Funcionário não encontrado para UID: $uid');
          await _authService.signOut();
          if (mounted) {
            setState(() {
              _errorMessage = 'Erro nos dados da conta. Faça login novamente.';
            });
          }
          return;
        }
        
        // Validação de segurança: verificar se o employee tem companyId
        if (currentEmployee.companyId == null || currentEmployee.companyId!.isEmpty) {
          debugPrint('[LoginPage] Usuário sem empresa - redirecionando para onboarding');
          
          // Define o employee temporariamente (sem companyId)
          if (mounted) {
            context.read<EmployeeContext>().setCurrentEmployee(currentEmployee);
          }
          
          // Redirecionar para página de cadastro de empresa (ONBOARDING OBRIGATÓRIO)
          if (mounted) {
            Navigator.pushReplacementNamed(context, AppRouteNames.cadastroEmpresa);
          }
          return;
        }
        
        debugPrint("EMPRESA ID: ${currentEmployee.companyId}");
        
        // Define o funcionário atual no contexto global (inclui companyId)
        if (mounted) {
          context.read<EmployeeContext>().setCurrentEmployee(currentEmployee);
        }
        
        if (mounted) {
          if (role == 'admin') {
            // Redireciona para Home do Admin
            Navigator.pushReplacementNamed(context, AppRouteNames.home, arguments: {'role': 'admin'});
          } else {
            // Redireciona para Home do Funcionário
            // Passamos o argumento para que a HomePage possa esconder botões de configuração, etc.
            Navigator.pushReplacementNamed(context, AppRouteNames.home, arguments: {'role': 'employee'});
          }
        }
      }

    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Erro ao fazer login';
      });
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AuthStrings.forgotPasswordEmailEmpty)),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AuthStrings.forgotPasswordEmailSent)),
      );
    } on FirebaseAuthException catch (e) {
      String message = AppStrings.errorOccurred;
      if (e.code == 'user-not-found') {
        message = AuthStrings.forgotPasswordEmailNotFound;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_person,
                        size: 80,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        AppStrings.welcome,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.loginSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 48),
                      // email textfield
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: AppStrings.email,
                          hintText: AuthStrings.emailHint,
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: colorScheme.surfaceVariant.withValues(alpha: 0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: colorScheme.primary),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AuthStrings.emailRequired;
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return AuthStrings.emailInvalid;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // password textfield
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: AppStrings.password,
                          prefixIcon: const Icon(Icons.lock_outline),
                          filled: true,
                          fillColor: colorScheme.surfaceVariant.withValues(alpha: 0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: colorScheme.primary),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () => setState(
                                () => _isPasswordVisible = !_isPasswordVisible),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AuthStrings.passwordRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: _rememberMe,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)),
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(AuthStrings.rememberMe,
                                  style: theme.textTheme.bodySmall),
                            ],
                          ),
                          TextButton(
                            onPressed: _forgotPassword,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(AuthStrings.forgotPasswordButton),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

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
                              Icon(Icons.error_outline,
                                  color: colorScheme.error),
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

                      // sign in button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signIn,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: colorScheme.onPrimary,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  AuthStrings.loginButton,
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // not a member? register now
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(AuthStrings.switchToRegister.split('?')[0] + '?',
                              style: theme.textTheme.bodyMedium),
                          TextButton(
                            onPressed: widget.showRegisterPage,
                            child: const Text(
                              AuthStrings.createNow,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
