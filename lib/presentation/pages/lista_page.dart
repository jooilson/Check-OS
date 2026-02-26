import 'package:checkos/core/constants/app_strings.dart';
import 'package:checkos/core/context/employee_context.dart';
import 'package:checkos/data/models/os_model.dart';
import 'package:checkos/data/repositories/os_repository.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:checkos/utils/debouncer.dart';
import 'package:provider/provider.dart';

class ListaPage extends StatefulWidget {
  const ListaPage({super.key});

  @override
  State<ListaPage> createState() => _ListaPageState();
}

class _ListaPageState extends State<ListaPage> with AutomaticKeepAliveClientMixin {
  String _sortBy = 'updatedAt';
  bool _isSelectionMode = false;
  final Set<String> _selectedOsIds = {};
  final OsRepository _osRepository = OsRepository();
  // Cache do formatador de data para evitar recriação no scroll
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  
  // Pagination state
  List<OsModel> _osList = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  final ScrollController _scrollController = ScrollController();
  final Debouncer _debouncer = Debouncer(delay: const Duration(milliseconds: 500));

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Obtém o companyId do contexto do funcionário logado
      final companyId = context.read<EmployeeContext>().currentCompanyId;
      
      final result = await _osRepository.getOsPaginated(limit: 20, companyId: companyId);
      setState(() {
        _osList = result.$1;
        _lastDocument = result.$2;
        _hasMore = result.$1.length >= 20;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.errorLoading}: $e')),
        );
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _lastDocument == null) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      // Obtém o companyId do contexto do funcionário logado
      final companyId = context.read<EmployeeContext>().currentCompanyId;
      
      final result = await _osRepository.getOsPaginated(
        limit: 20,
        lastDocument: _lastDocument,
        companyId: companyId,
      );
      
      setState(() {
        if (result.$1.isNotEmpty) {
          _osList.addAll(result.$1);
          _lastDocument = result.$2;
          _hasMore = result.$1.length >= 20;
        } else {
          _hasMore = false;
        }
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _onScroll() {
    // Debounce scroll events to avoid excessive calls
    _debouncer.run(() {
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  void _onLongPress(OsModel os) {
    if (_isSelectionMode) return;
    setState(() {
      _isSelectionMode = true;
      _selectedOsIds.add(os.id);
    });
  }

  void _onTap(OsModel os) {
    if (_isSelectionMode) {
      setState(() {
        if (_selectedOsIds.contains(os.id)) {
          _selectedOsIds.remove(os.id);
          if (_selectedOsIds.isEmpty) {
            _isSelectionMode = false;
          }
        } else {
          _selectedOsIds.add(os.id);
        }
      });
    } else {
      Navigator.pushNamed(
        context,
        '/detalhes-os',
        arguments: os,
      );
    }
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedOsIds.clear();
    });
  }

  void _toggleSelectAll(List<OsModel> osList) {
    setState(() {
      if (_selectedOsIds.length == osList.length) {
        _selectedOsIds.clear();
      } else {
        _selectedOsIds.addAll(osList.map((os) => os.id));
      }
    });
  }

  Future<void> _deleteSelected() async {
    final count = _selectedOsIds.length;
    if (count == 0) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
            'Tem certeza que deseja excluir ${count} OS(s) selecionada(s)? Esta ação não pode ser desfeita e excluirá todos os diários associados.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Excluir',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();
      final osCollection = firestore.collection('os');
      final diariosCollection = firestore.collection('diarios');

      for (final osId in _selectedOsIds) {
        final diariosSnapshot =
            await diariosCollection.where('osId', isEqualTo: osId).get();
        for (final doc in diariosSnapshot.docs) {
          batch.delete(doc.reference);
        }
        batch.delete(osCollection.doc(osId));
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$count OS(s) excluída(s) com sucesso.')),
        );
        _exitSelectionMode();
        // Recarrega os dados após exclusão
        await _loadInitialData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir OS: $e')),
        );
      }
    }
  }

  AppBar _buildAppBar(List<OsModel> osList) {
    final colors = Theme.of(context).colorScheme;

    if (_isSelectionMode) {
      final bool allSelected =
          osList.isNotEmpty && _selectedOsIds.length == osList.length;
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _exitSelectionMode,
        ),
        title: Text('${_selectedOsIds.length} selecionada(s)'),
        backgroundColor: colors.primaryContainer,
        actions: [
          IconButton(
            icon: Icon(allSelected ? Icons.deselect : Icons.select_all),
            onPressed: () => _toggleSelectAll(osList),
            tooltip: allSelected ? 'Desselecionar Todas' : 'Selecionar Todas',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _selectedOsIds.isEmpty ? null : _deleteSelected,
            tooltip: 'Excluir Selecionadas',
          ),
        ],
      );
    } else {
      return AppBar(
        title: const Text('Lista de OS'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _sortBy = value);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'numeroOs',
                child: Text('Ordenar por Número da OS'),
              ),
              PopupMenuItem(
                value: 'createdAt',
                child: Text('Ordenar por Data de Criação'),
              ),
              PopupMenuItem(
                value: 'updatedAt',
                child: Text('Ordenar por Última Modificação'),
              ),
            ],
            icon: const Icon(Icons.sort),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Otimização: Scaffold fora do StreamBuilder para evitar piscar a AppBar
    return Scaffold(
      // Passamos uma lista vazia inicialmente para o AppBar se não tiver dados ainda,
      // mas idealmente o estado da seleção deveria ser independente dos dados brutos.
      appBar: _buildAppBar(_osList), 
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildOsList(colors, textTheme),
    );
  }

  Widget _buildOsList(ColorScheme colors, TextTheme textTheme) {
    // Ordenação
    final sortedList = List<OsModel>.from(_osList);
    sortedList.sort((a, b) {
      switch (_sortBy) {
        case 'numeroOs':
          return int.parse(a.numeroOs).compareTo(int.parse(b.numeroOs));
        case 'createdAt':
          return (b.createdAt ?? DateTime(0))
              .compareTo(a.createdAt ?? DateTime(0));
        case 'updatedAt':
        default:
          return (b.updatedAt ?? DateTime(0))
              .compareTo(a.updatedAt ?? DateTime(0));
      }
    });

    if (sortedList.isEmpty && !_isSelectionMode) {
      return const Center(child: Text('Nenhuma OS encontrada.'));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: sortedList.length + (_hasMore ? 1 : 0),
      // Otimização: CacheExtent ajuda a manter itens na memória durante scroll rápido
      // Valor de 200px é um bom equilíbrio entre memória e performance
      cacheExtent: 200, 
      itemBuilder: (context, index) {
        // Se é o último item e ainda há mais, mostra indicador de carregamento
        if (index == sortedList.length) {
          return _isLoadingMore
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              : const SizedBox.shrink();
        }

        final os = sortedList[index];
        final isSelected = _selectedOsIds.contains(os.id);

        // Extração do Widget para evitar lógica pesada dentro do builder
        return _OsListItem(
          os: os,
          isSelected: isSelected,
          isSelectionMode: _isSelectionMode,
          onTap: () => _onTap(os),
          onLongPress: () => _onLongPress(os),
          dateFormat: _dateFormat,
          colors: colors,
          textTheme: textTheme,
        );
      },
    );
  }
}

// Widget extraído para melhorar performance de renderização
class _OsListItem extends StatelessWidget {
  final OsModel os;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final DateFormat dateFormat;
  final ColorScheme colors;
  final TextTheme textTheme;

  const _OsListItem({
    required this.os,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.dateFormat,
    required this.colors,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    late final String statusText;
    late final Color statusColor;

    if (os.osfinalizado) {
      statusText = 'Finalizado';
      statusColor = colors.tertiary;
    } else if (os.pendente) {
      statusText = 'Pendente';
      statusColor = colors.error;
    } else {
      statusText = 'Em andamento';
      statusColor = colors.primary;
    }

    return Card(
      color: isSelected ? colors.primary.withOpacity(0.2) : colors.surface,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      // Otimização: Reduzir elevation em dispositivos fracos melhora performance de GPU
      elevation: 2, 
      shape: RoundedRectangleBorder(
        side: isSelected
            ? BorderSide(color: colors.primary, width: 1.5)
            : BorderSide.none,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: isSelectionMode
            ? Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: colors.primary,
              )
            : null,
        title: Text(
          'OS ${os.numeroOs} - ${os.nomeCliente}',
          style: textTheme.titleMedium,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Serviço: ${os.servico}', style: textTheme.bodyMedium),
              Text('Responsável: ${os.responsavel}', style: textTheme.bodyMedium),
              if (os.temPedido)
                Text('Pedido: ${os.numeroPedido}', style: textTheme.bodyMedium),
              if (os.updatedAt != null)
                Text(
                  // Otimização: Uso de DateFormat cacheado
                  'Modificado: ${dateFormat.format(os.updatedAt!.toLocal())}',
                  style: textTheme.bodySmall,
                ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: textTheme.labelMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}