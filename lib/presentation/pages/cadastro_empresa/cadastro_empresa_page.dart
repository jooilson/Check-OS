import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:checkos/core/constants/app_route_names.dart';

/// Página de cadastro de empresa - onboarding obrigatório
/// Usuários sem companyId devem acessar esta página primeiro
class CadastroEmpresaPage extends StatefulWidget {
  const CadastroEmpresaPage({super.key});

  @override
  State<CadastroEmpresaPage> createState() => _CadastroEmpresaPageState();
}

class _CadastroEmpresaPageState extends State<CadastroEmpresaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeEmpresaController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _enderecoController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingCnpj = false;
  String? _errorMessage;
  String? _successMessage;

  /// Busca CNPJ - API pública
  Future<void> _buscarCnpj() async {
    final cnpj = _cnpjController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (cnpj.length != 14) {
      setState(() {
        _errorMessage = 'CNPJ deve ter 14 dígitos';
      });
      return;
    }

    setState(() {
      _isLoadingCnpj = true;
      _errorMessage = null;
    });

    try {
      // API pública - BrasilAPI
      final response = await http.get(
        Uri.parse('https://brasilapi.com.br/api/cnpj/v1/$cnpj'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _nomeEmpresaController.text = data['razao_social'] ?? '';
          _emailController.text = data['email'] ?? '';
          _telefoneController.text = data['ddd'] != null && data['telefone'] != null
              ? '(${data['ddd']}) ${data['telefone']}'
              : '';
          
          final endereco = [
            data['logradouro'],
            data['numero'],
            data['complemento'],
            data['bairro'],
            data['municipio'],
            data['uf'],
          ].where((e) => e != null && e.toString().isNotEmpty).join(', ');
          
          _enderecoController.text = endereco;
          _successMessage = 'Dados do CNPJ preenchidos automaticamente!';
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _errorMessage = 'CNPJ não encontrado. Preencha manualmente.';
        });
      } else {
        setState(() {
          _errorMessage = 'Erro ao buscar CNPJ. Preencha manualmente.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro de conexão. Preencha manualmente.';
      });
    } finally {
      setState(() {
        _isLoadingCnpj = false;
      });
    }
  }

  /// Valida CNPJ duplicado
  Future<bool> _validarCnpjDuplicado(String cnpj) async {
    if (cnpj.isEmpty) return true;
    final cnpjLimpo = cnpj.replaceAll(RegExp(r'[^0-9]'), '');
    if (cnpjLimpo.length != 14) return true;

    final snapshot = await FirebaseFirestore.instance
        .collection('companies')
        .where('cnpj', isEqualTo: cnpjLimpo)
        .limit(1)
        .get();

    return snapshot.docs.isEmpty;
  }

  /// Criar empresa com transação Firestore
  Future<void> _criarEmpresa() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      final cnpj = _cnpjController.text.replaceAll(RegExp(r'[^0-9]'), '');

      if (cnpj.isNotEmpty && !(await _validarCnpjDuplicado(cnpj))) {
        throw Exception('CNPJ já cadastrado no sistema');
      }

      final db = FirebaseFirestore.instance;
      
      await db.runTransaction((transaction) async {
        // 1. Criar a empresa
        final companyRef = db.collection('companies').doc();
        final companyId = companyRef.id;

        transaction.set(companyRef, {
          'name': _nomeEmpresaController.text.trim(),
          'cnpj': cnpj,
          'email': _emailController.text.trim().toLowerCase(),
          'phone': _telefoneController.text.trim(),
          'address': _enderecoController.text.trim(),
          'plan': 'free',
          'isActive': true,
          'ownerId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 2. Atualizar usuário com companyId
        final userRef = db.collection('users').doc(user.uid);
        transaction.update(userRef, {
          'companyId': companyId,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 3. Atualizar ou criar na coleção employees
        final employeeRef = db.collection('employees').doc(user.uid);
        final employeeDoc = await employeeRef.get();
        if (employeeDoc.exists) {
          transaction.update(employeeRef, {
            'companyId': companyId,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          transaction.set(employeeRef, {
            'name': user.displayName ?? user.email?.split('@').first ?? 'Usuário',
            'email': user.email,
            'role': 'admin',
            'companyId': companyId,
            'phone': '',
            'isActive': true,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Empresa criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, AppRouteNames.home);
      }
    } on FirebaseException catch (e) {
      setState(() {
        _errorMessage = 'Erro no banco de dados: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nomeEmpresaController.dispose();
    _cnpjController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Empresa'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.business, size: 80, color: colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  'Bem-vindo!',
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete o cadastro da sua empresa para continuar',
                  style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

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
                        Expanded(child: Text(_errorMessage!, style: TextStyle(color: colorScheme.error))),
                      ],
                    ),
                  ),

                if (_successMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(child: Text(_successMessage!, style: const TextStyle(color: Colors.green))),
                      ],
                    ),
                  ),

                TextFormField(
                  controller: _cnpjController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'CNPJ (opcional)',
                    hintText: '00.000.000/0001-00',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    suffixIcon: _isLoadingCnpj
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : IconButton(icon: const Icon(Icons.search), onPressed: _buscarCnpj, tooltip: 'Buscar CNPJ'),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final cnpj = value.replaceAll(RegExp(r'[^0-9]'), '');
                      if (cnpj.length != 14) return 'CNPJ deve ter 14 dígitos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Text('Se preferir, preencha manualmente', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nomeEmpresaController,
                  decoration: const InputDecoration(labelText: 'Nome da Empresa *', prefixIcon: Icon(Icons.business_outlined)),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Por favor, insira o nome da empresa';
                    if (value.trim().length < 3) return 'Nome deve ter pelo menos 3 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email da Empresa', prefixIcon: Icon(Icons.email_outlined)),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!value.contains('@') || !value.contains('.')) return 'Email inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _telefoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Telefone', prefixIcon: Icon(Icons.phone_outlined)),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _enderecoController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Endereço', prefixIcon: Icon(Icons.location_on_outlined), alignLabelWithHint: true),
                ),
                const SizedBox(height: 32),

                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _criarEmpresa,
                  icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check),
                  label: Text(_isLoading ? 'CRIANDO...' : 'CRIAR EMPRESA'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

