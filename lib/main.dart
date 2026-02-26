
import 'package:checkos/app.dart';
import 'package:checkos/services/push_notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa Firebase para todas as plataformas, incluindo web
  await Firebase.initializeApp();
  
  // App Check desabilitado para desenvolvimento
  // Erro "Too many attempts" impede uploads ao Storage
  // Para produção, use safetyNetProvider ou desabilite App Check no Firebase Console
  // Observação: App Check no web requer configuração adicional no Firebase Console
  try {
    if (kIsWeb) {
      // Para web, App Check pode não estar configurado corretamente
      // Pulamos a ativação para evitar erros
      print('INFO: App Check não ativado em modo web (requer configuração adicional)');
    } else {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
      );
    }
  } catch (e) {
    print('Aviso: Falha ao ativar App Check: $e');
  }
  
  // Inicializa Push Notifications
  try {
    await PushNotificationService.initialize();
    if (kDebugMode) {
      print('Push Notifications inicializado com sucesso');
    }
  } catch (e) {
    print('Aviso: Falha ao inicializar Push Notifications: $e');
  }
  
  runApp(const MyApp());
}
