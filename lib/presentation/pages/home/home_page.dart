import 'package:checkos/core/constants/app_strings.dart';
import 'package:checkos/presentation/pages/lista_page.dart';
import 'package:checkos/presentation/pages/config_page.dart';
import 'package:checkos/presentation/pages/novaos_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    ListaPage(),
    NovaOsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _abrirConfiguracoes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ConfigPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'configuracoes') {
                _abrirConfiguracoes();
              } 
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'configuracoes',
                child: Text(AppStrings.settings),
              ),
            ],
          ),
        ],
      ),

      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,

        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.onSurface.withValues(alpha: 0.6),

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: AppStrings.list,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: AppStrings.newRecord,
          ),
        ],
      ),
    );
  }
}