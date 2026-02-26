import 'package:checkos/core/context/employee_context.dart';
import 'package:checkos/data/models/employee/employee_model.dart';
import 'package:checkos/data/repositories/employee_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmployeeManagementPage extends StatefulWidget {
  const EmployeeManagementPage({super.key});

  @override
  State<EmployeeManagementPage> createState() => _EmployeeManagementPageState();
}

class _EmployeeManagementPageState extends State<EmployeeManagementPage> {
  final EmployeeRepository _employeeRepository = EmployeeRepository();
  late Stream<List<EmployeeModel>> _employeesStream;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  void _loadEmployees() {
    // Obtém o companyId do contexto do funcionário logado
    final companyId = context.read<EmployeeContext>().currentCompanyId;
    _employeesStream = _employeeRepository.getEmployeesStream(companyId: companyId);
  }

  Future<void> _deleteEmployee(String employeeId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desativar Funcionário'),
        content: const Text('Tem certeza que deseja desativar este funcionário?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Desativar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _employeeRepository.deleteEmployee(employeeId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Funcionário desativado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao desativar funcionário: $e')),
        );
      }
    }
  }

  void _editEmployee(EmployeeModel employee) {
    Navigator.pushNamed(context, '/add-employee', arguments: employee);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Funcionários'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<EmployeeModel>>(
        stream: _employeesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro: ${snapshot.error}'),
            );
          }

          final employees = snapshot.data ?? [];

          if (employees.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: colors.outline,
                  ),
                  const SizedBox(height: 16),
                  const Text('Nenhum funcionário cadastrado'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            // Otimização: CacheExtent para manter itens na memória durante scroll
            cacheExtent: 200,
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final employee = employees[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: employee.isActive ? () => _editEmployee(employee) : null,
                  leading: CircleAvatar(
                    backgroundColor: employee.isActive ? colors.primaryContainer : colors.surfaceVariant,
                    child: Text(
                      employee.name.isNotEmpty ? employee.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: employee.isActive ? colors.onPrimaryContainer : colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  title: Text(
                    employee.name,
                    style: TextStyle(
                      decoration: employee.isActive ? null : TextDecoration.lineThrough,
                      color: employee.isActive ? null : colors.onSurface.withAlpha(128),
                    ),
                  ),
                  subtitle: Text(
                    '${employee.role} • ${employee.email}',
                    style: TextStyle(
                      color: employee.isActive ? null : colors.onSurface.withAlpha(128),
                    ),
                  ),
                  trailing: employee.isActive ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        color: colors.primary,
                        onPressed: () => _editEmployee(employee),
                        tooltip: 'Editar Funcionário',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: colors.error,
                        onPressed: () => _deleteEmployee(employee.id),
                        tooltip: 'Desativar Funcionário',
                      ),
                    ],
                  ) : const Chip(label: Text('Inativo', style: TextStyle(fontSize: 10))),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-employee');
        },
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Funcionário',
      ),
    );
  }
}
