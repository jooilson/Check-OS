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
  final _repo = EmployeeRepository();
  late Stream<List<EmployeeModel>> _stream;
  
  bool? _filter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final companyId = context.read<EmployeeContext>().currentCompanyId;
    _stream = _repo.getEmployeesStream(companyId: companyId);
  }

  List<EmployeeModel> _applyFilter(List<EmployeeModel> list) {
    if (_filter == null) return list;
    return list.where((e) => e.isActive == _filter).toList();
  }

  Future<void> _delete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desativar'),
        content: const Text('Confirmar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Desativar')),
        ],
      ),
    );
    if (confirm == true) {
      await _repo.deleteEmployee(id);
    }
  }

  void _edit(EmployeeModel e) {
    Navigator.pushNamed(context, '/add-employee', arguments: e);
  }

  Future<void> _activate(EmployeeModel e) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ativar'),
        content: const Text('Confirmar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ativar')),
        ],
      ),
    );
    if (confirm == true) {
      final updated = e.copyWith(isActive: true, updatedAt: DateTime.now());
      await _repo.updateEmployee(updated);
    }
  }

  Future<void> _remove(EmployeeModel e) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Funcionário'),
        content: Text('Tem certeza que deseja excluir "${e.name}"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _repo.deleteEmployee(e.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Funcionários'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                switch (value) {
                  case 'inativos':
                    _filter = false;
                    break;
                  case 'ativos':
                    _filter = true;
                    break;
                  default:
                    _filter = null;
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'todos',
                child: Row(
                  children: [
                    if (_filter == null) const Icon(Icons.check, size: 18),
                    const SizedBox(width: 8),
                    const Text('Todos'),
                  ],
                ),
              ),
              
              PopupMenuItem(
                value: 'ativos',
                child: Row(
                  children: [
                    if (_filter == true) const Icon(Icons.check, size: 18),
                    const SizedBox(width: 8),
                    const Text('Ativos'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'inativos',
                child: Row(
                  children: [
                    if (_filter == false) const Icon(Icons.check, size: 18),
                    const SizedBox(width: 8),
                    const Text('Inativos'),
                  ],
                ),
              ),
              
            ],
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar',
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _stream,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = _applyFilter(snap.data ?? []);
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Nenhum funcionário ${_filter == true ? "ativo" : _filter == false ? "inativo" : ""}'),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final e = list[i];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(e.name.isNotEmpty ? e.name[0].toUpperCase() : '?'),
                  ),
                  title: Text(e.name),
                  subtitle: Text('${e.role} • ${e.email}'),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _edit(e);
                          break;
                        case 'delete':
                          _delete(e.id);
                          break;
                        case 'activate':
                          _activate(e);
                          break;
                        case 'remove':
                          _remove(e);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      if (e.isActive)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Desativar', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        )
                      else
                        const PopupMenuItem(
                          value: 'activate',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, size: 20, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Ativar', style: TextStyle(color: Colors.green)),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'remove',
                        child: Row(
                          children: [
                            Icon(Icons.remove_circle, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Excluir', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-employee'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
