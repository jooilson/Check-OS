import 'package:checkos/core/constants/app_route_names.dart';
import 'package:checkos/core/context/employee_context.dart';
import 'package:checkos/core/routes/app_router.dart';
import 'package:checkos/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        // EmployeeContext para rastrear o funcionário atual logado
        // Usado para auditoria e rastreamento de ações
        ChangeNotifierProvider(
          create: (_) => EmployeeContext(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'CheckOS',

            // Usando temas centralizados do AppTheme
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            initialRoute: AppRouteNames.authWrapper,
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}

