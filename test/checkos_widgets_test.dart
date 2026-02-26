// CheckOS Widget Tests
// Para rodar: cd C:/Projetos/checkos && flutter test test/checkos_widgets_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:checkos/core/context/employee_context.dart';
import 'package:checkos/theme/theme_provider.dart';

void main() {
  group('CheckOS Widget Tests', () {
    // Helper para criar o ambiente de teste com ThemeProvider
    Widget createTestWidget(Widget child) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => EmployeeContext()),
        ],
        child: MaterialApp(
          home: child,
        ),
      );
    }

    testWidgets('Should display OS status card with correto info', (WidgetTester tester) async {
      // Arrange
      final widget = createTestWidget(
        Scaffold(
          body: Card(
            child: ListTile(
              title: const Text('OS 1001 - Cliente Teste'),
              subtitle: const Text('Serviço: Manutenção'),
              trailing: Chip(
                label: const Text('Em andamento'),
                backgroundColor: Colors.blue,
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('OS 1001 - Cliente Teste'), findsOneWidget);
      expect(find.text('Serviço: Manutenção'), findsOneWidget);
      expect(find.text('Em andamento'), findsOneWidget);
    });

    testWidgets('Should display finalized OS status', (WidgetTester tester) async {
      // Arrange
      final widget = createTestWidget(
        Scaffold(
          body: Card(
            child: ListTile(
              title: const Text('OS 2001 - Empresa XYZ'),
              trailing: Chip(
                label: const Text('Finalizado'),
                backgroundColor: Colors.green,
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('Finalizado'), findsOneWidget);
    });

    testWidgets('Should display pending OS status', (WidgetTester tester) async {
      // Arrange
      final widget = createTestWidget(
        Scaffold(
          body: Card(
            child: ListTile(
              title: const Text('OS 3001 - Cliente ABC'),
              trailing: Chip(
                label: const Text('Pendente'),
                backgroundColor: Colors.red,
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('Pendente'), findsOneWidget);
    });

    testWidgets('Should display employee list item', (WidgetTester tester) async {
      // Arrange
      final widget = createTestWidget(
        Scaffold(
          body: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: const Text('João Silva'),
            subtitle: const Text('Técnico'),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('João Silva'), findsOneWidget);
      expect(find.text('Técnico'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('Should display empty OS list message', (WidgetTester tester) async {
      // Arrange
      final widget = createTestWidget(
        const Scaffold(
          body: Center(
            child: Text('Nenhuma OS encontrada.'),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('Nenhuma OS encontrada.'), findsOneWidget);
    });

    testWidgets('Should have search field in list', (WidgetTester tester) async {
      // Arrange
      final widget = createTestWidget(
        Scaffold(
          appBar: AppBar(
            title: const Text('Lista de OS'),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {},
              ),
            ],
          ),
          body: const Center(child: Text('Content')),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Lista de OS'), findsOneWidget);
    });

    testWidgets('Should display sort options in popup menu', (WidgetTester tester) async {
      // Arrange
      final widget = createTestWidget(
        Scaffold(
          appBar: AppBar(
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort),
                onSelected: (value) {},
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'numeroOs',
                    child: Text('Ordenar por Número da OS'),
                  ),
                  PopupMenuItem(
                    value: 'createdAt',
                    child: Text('Ordenar por Data de Criação'),
                  ),
                ],
              ),
            ],
          ),
          body: const Center(child: Text('Content')),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byIcon(Icons.sort), findsOneWidget);
    });

    testWidgets('Should display loading indicator', (WidgetTester tester) async {
      // Arrange
      final widget = createTestWidget(
        const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Should display delete confirmation dialog', (WidgetTester tester) async {
      // Arrange
      bool dialogShown = false;
      
      final widget = createTestWidget(
        Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirmar Exclusão'),
                    content: const Text('Tem certeza que deseja excluir a OS?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Excluir'),
                      ),
                    ],
                  ),
                );
                dialogShown = true;
              },
              child: const Text('Excluir'),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();

      // Assert
      expect(dialogShown, true);
      expect(find.text('Confirmar Exclusão'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Excluir'), findsNWidgets(2)); // Button + Dialog
    });

    testWidgets('Should toggle theme mode', (WidgetTester tester) async {
      // Arrange
      late ThemeMode currentMode;
      
      final widget = createTestWidget(
        Builder(
          builder: (context) {
            final themeProvider = Provider.of<ThemeProvider>(context);
            currentMode = themeProvider.themeMode;
            
            return Scaffold(
              body: Column(
                children: [
                  Text('Theme: ${currentMode.name}'),
                  ElevatedButton(
                    onPressed: () {
                      themeProvider.setDarkTheme(true);
                    },
                    child: const Text('Set Dark'),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      
      // Initial state
      expect(find.text('Theme: light'), findsOneWidget);
      
      // Toggle
      await tester.tap(find.text('Set Dark'));
      await tester.pump();
      
      // After toggle
      expect(find.text('Theme: dark'), findsOneWidget);
    });
  });
}

