
import 'package:checkos/app.dart';
import 'package:checkos/core/utils/logger.dart';
import 'package:checkos/firebase_options.dart';
import 'package:checkos/services/push_notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Verifica se o Firebase já foi inicializado para evitar erro "duplicate-app"
  // Isso é útil em hot reload durante desenvolvimento
  try {
    // Verifica se já existem apps inicializados
    if (Firebase.apps.isNotEmpty) {
      // Firebase já foi inicializado, usa o app existente
      print('Firebase já estava inicializado, usando app existente');
    } else {
      // Firebase não foi inicializado, inicializa agora
      print('Inicializando Firebase...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    // Se falhar a verificação, tenta inicializar normalmente
    // Isso pode acontecer em alguns casos edge
    print('Erro ao verificar Firebase, tentando inicializar: $e');
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (initError) {
      print('Erro ao inicializar Firebase: $initError');
    }
  }
  
  // App Check desabilitado para desenvolvimento
  // Erro "Too many attempts" impede uploads ao Storage
  // Para produção, use safetyNetProvider ou desabilite App Check no Firebase Console
  // Observação: App Check no web requer configuração adicional no Firebase Console
  try {
    if (kIsWeb) {
      // Para web, App Check pode não estar configurado corretamente
      // Pulamos a ativação para evitar erros
      AppLogger.info('App Check não ativado em modo web (requer configuração adicional)');
    } else {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
      );
    }
  } catch (e) {
    AppLogger.warning('Falha ao ativar App Check: $e');
  }
  
  // Inicializa Push Notifications
  try {
    await PushNotificationService.initialize();
    AppLogger.debug('Push Notifications inicializado com sucesso');
  } catch (e) {
    AppLogger.warning('Falha ao inicializar Push Notifications: $e');
  }
  
  runApp(const MyApp());
}
