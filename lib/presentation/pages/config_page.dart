import 'package:checkos/core/context/employee_context.dart';
import 'package:checkos/core/utils/logger.dart';
import 'package:checkos/data/models/diario_model.dart';
import 'package:checkos/data/models/log_model.dart';
import 'package:checkos/data/models/os_model.dart';
import 'package:checkos/data/repositories/diario_repository.dart';
import 'package:checkos/data/repositories/log_repository.dart';
import 'package:checkos/data/repositories/os_repository.dart';
import 'package:checkos/presentation/pages/employee_management/employee_management_page.dart';
import 'package:checkos/services/import_export_service.dart';
import 'package:checkos/services/logo_service.dart';
import 'package:checkos/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  bool _isProcessing = false;
  File? _logoFile;

  final OsRepository _osRepository = OsRepository();
  final DiarioRepository _diarioRepository = DiarioRepository();
  final LogRepository _logRepository = LogRepository();

  @override
  void initState() {
    super.initState();
    _loadLogo();
  }

  Future<void> _loadLogo() async {
    final logo = await LogoService.getLogoFile();
    setState(() {
      _logoFile = logo;
    });
  }

  Future<void> _selecionarLogo() async {
    try {
      AppLogger.debug('[ConfigPage] Abrindo seletor de imagens');
      
      final resultado = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        allowCompression: false,
      );

      AppLogger.debug('[ConfigPage] Resultado do file picker: ${resultado?.files.length}');

      if (resultado == null || resultado.files.isEmpty) {
        AppLogger.debug('[ConfigPage] Usuário cancelou a seleção');
        return;
      }

      final caminhoArquivo = resultado.files.single.path;
      
      if (caminhoArquivo == null || caminhoArquivo.isEmpty) {
        AppLogger.warning('[ConfigPage] Erro: Caminho do arquivo é nulo ou vazio');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro: Caminho do arquivo inválido')),
          );
        }
        return;
      }

      AppLogger.debug('[ConfigPage] Caminho do arquivo: $caminhoArquivo');
      
      final logoFile = File(caminhoArquivo);
      
      // Valida se o arquivo existe
      final existe = await logoFile.exists();
      AppLogger.debug('[ConfigPage] Arquivo existe: $existe');
      
      if (!existe) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro: Arquivo não foi encontrado')),
          );
        }
        return;
      }

      AppLogger.debug('[ConfigPage] Salvando logo');
      final savedPath = await LogoService.saveLogo(logoFile);
      
      AppLogger.debug('[ConfigPage] Resultado do salvamento: $savedPath');
      
      if (savedPath != null && mounted) {
        setState(() {
          _logoFile = File(savedPath);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logo da empresa salvo com sucesso!')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar o logo. Verifique os logs.')),
        );
      }
    } catch (e) {
      AppLogger.error('[ConfigPage] Exceção ao selecionar logo', e);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar logo: $e')),
        );
      }
    }
  }

  Future<void> _removerLogo() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Logo'),
        content: const Text('Deseja remover o logo da empresa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await LogoService.deleteLogo();
      setState(() {
        _logoFile = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logo removido com sucesso!')),
        );
      }
    }
  }

  Future<void> _exportarDados() async {
    setState(() => _isProcessing = true);
    try {
      // Obtém o companyId do contexto do funcionário logado
      final companyId = context.read<EmployeeContext>().currentCompanyId;
      
      // Filtra OS por companyId
      final ordensServico = await _osRepository.getOsList(companyId: companyId);
      
      // Para diários e logs, como não têm companyId diretamente,
      // filtramos pelos IDs das OS da empresa
      final osIds = ordensServico.map((os) => os.id).toSet();
      
      // Busca todos os diários e filtra pelos IDs das OS da empresa
      final allDiarios = await _diarioRepository.getAllDiarios();
      final diariosFiltrados = allDiarios.where((d) => osIds.contains(d.osId)).toList();
      
      // Busca todos os logs e filtra pelos IDs das OS da empresa
      final allLogs = await _logRepository.getLogsList();
      final logsFiltrados = allLogs.where((l) => osIds.contains(l.osId)).toList();

      final caminho = await ImportExportService.exportarDados(
        ordemServicos: ordensServico,
        diarios: diariosFiltrados,
        logs: logsFiltrados,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dados exportados com sucesso para: $caminho'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar dados: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _importarDados() async {
    try {
      final resultado = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (resultado == null || resultado.files.single.path == null) {
        return; // Usuário cancelou
      }

      final caminhoArquivo = resultado.files.single.path!;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Importar Dados'),
          content: const Text(
              'Isso substituirá TODOS os dados existentes. Esta ação não pode ser desfeita. Deseja continuar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Importar'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      setState(() => _isProcessing = true);

      final dados = await ImportExportService.importarDados(caminhoArquivo);

      // Limpar dados antigos
      await _osRepository.deleteAllOs();
      await _diarioRepository.deleteAllDiarios();
      await _logRepository.deleteAllLogs();

      // Inserir novos dados
      final ordensServico = dados['ordemServicos'] as List<OsModel>;
      final diarios = dados['diarios'] as List<DiarioModel>;
      final logs = dados['logs'] as List<LogModel>;

      for (final os in ordensServico) {
        await _osRepository.addOs(os);
      }
      for (final diario in diarios) {
        await _diarioRepository.addDiario(diario);
      }
      for (final log in logs) {
        await _logRepository.addLog(log);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados importados com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao importar dados: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final formKey = GlobalKey<FormState>();
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    
    // Variáveis de estado locais do diálogo
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Alterar Senha'),
              content: SizedBox(
                width: double.maxFinite,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: currentPassController,
                          obscureText: obscureCurrent,
                          decoration: InputDecoration(
                            labelText: 'Senha Atual',
                            suffixIcon: IconButton(
                              icon: Icon(obscureCurrent ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => obscureCurrent = !obscureCurrent),
                            ),
                          ),
                          validator: (v) => v?.isEmpty == true ? 'Informe a senha atual' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: newPassController,
                          obscureText: obscureNew,
                          decoration: InputDecoration(
                            labelText: 'Nova Senha',
                            suffixIcon: IconButton(
                              icon: Icon(obscureNew ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => obscureNew = !obscureNew),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Informe a nova senha';
                            if (v.length < 6) return 'Mínimo de 6 caracteres';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: confirmPassController,
                          obscureText: obscureConfirm,
                          decoration: InputDecoration(
                            labelText: 'Confirmar Nova Senha',
                            suffixIcon: IconButton(
                              icon: Icon(obscureConfirm ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
                            ),
                          ),
                          validator: (v) {
                            if (v != newPassController.text) return 'As senhas não conferem';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setState(() => isLoading = true);
                            try {
                              // 1. Reautenticar o usuário para garantir segurança
                              final cred = EmailAuthProvider.credential(
                                email: user.email!,
                                password: currentPassController.text,
                              );
                              await user.reauthenticateWithCredential(cred);
                              
                              // 2. Atualizar a senha
                              await user.updatePassword(newPassController.text);
                              
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Senha alterada com sucesso!')),
                                );
                              }
                            } on FirebaseAuthException catch (e) {
                              setState(() => isLoading = false);
                              String msg = 'Erro ao alterar senha';
                              if (e.code == 'wrong-password') msg = 'Senha atual incorreta';
                              if (e.code == 'weak-password') msg = 'A nova senha é muito fraca';
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                              }
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente sair do aplicativo?'),
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

    if (confirm == true) {
      // Limpa o contexto do funcionário antes de fazer logout
      context.read<EmployeeContext>().clearCurrentEmployee();
      
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        centerTitle: true,
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildLogoSection(theme, colors),
                const SizedBox(height: 24),
                _buildSectionHeader(theme, 'Gerenciamento'),
                Card(
                  elevation: 2,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.people_outline),
                        title: const Text('Funcionários'),
                        subtitle: const Text('Gerenciar equipe e acessos'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pushNamed(
                            context, '/employee-management'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.history),
                        title: const Text('Logs de Auditoria'),
                        subtitle: const Text('Histórico de atividades'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pushNamed(context, '/logs'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(theme, 'Dados e Backup'),
                Card(
                  elevation: 2,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.download_outlined),
                        title: const Text('Exportar Dados'),
                        subtitle: const Text('Salvar backup em JSON'),
                        onTap: _exportarDados,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.upload_outlined),
                        title: const Text('Importar Dados'),
                        subtitle: const Text('Restaurar backup de arquivo'),
                        onTap: _importarDados,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(theme, 'Conta'),
                Card(
                  elevation: 2,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('Alterar Senha'),
                    subtitle: const Text('Atualizar senha de acesso'),
                    onTap: _changePassword,
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(theme, 'Aplicativo'),
                Card(
                  elevation: 2,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('Sobre'),
                        subtitle: const Text('Versão 1.0.0'),
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'CheckOS',
                            applicationVersion: '1.0.0',
                            applicationLegalese: '© 2025 CheckOS',
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Sair'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.error,
                      side: BorderSide(color: colors.error),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildLogoSection(ThemeData theme, ColorScheme colors) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _selecionarLogo,
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(color: colors.outline, width: 2),
                image: _logoFile != null
                    ? DecorationImage(
                        image: FileImage(_logoFile!),
                        fit: BoxFit.contain, // Contain para não cortar logos retangulares
                      )
                    : null,
              ),
              child: _logoFile == null
                  ? Icon(Icons.add_a_photo,
                      size: 40, color: colors.onSurfaceVariant)
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          if (_logoFile != null)
            TextButton.icon(
              onPressed: _removerLogo,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Remover Logo'),
              style: TextButton.styleFrom(foregroundColor: colors.error),
            )
          else
            Text(
              'Toque para adicionar o logo da empresa',
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}