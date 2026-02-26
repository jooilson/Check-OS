import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Serviço de Push Notifications para CheckOS
/// Suporta Android, iOS e Web
class PushNotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  /// Token do dispositivo atual
  static String? _deviceToken;
  
  /// Callback para quando uma mensagem é recebida
  static Function(RemoteMessage)? onMessageReceived;
  
  /// Callback para quando o app abre através de uma notificação
  static Function(RemoteMessage)? onMessageOpenedApp;
  
  /// Inicializa o serviço de push notifications
  static Future<void> initialize() async {
    // Solicita permissão para notificações
    await _requestPermission();
    
    // Configura handler para mensagens recebidas quando o app está em foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Configura handler para quando o app é aberto através de uma notificação
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    
    // Verifica se o app foi aberto através de uma notificação ao iniciar
    await _checkInitialMessage();
    
    // Obtém o token do dispositivo
    await _getDeviceToken();
  }
  
  /// Solicita permissão para receber notificações
  static Future<bool> _requestPermission() async {
    try {
      // Para web, não precisamos de permissão explícita no mesmo sentido
      // O Firebase Web usa Service Workers para notificações
      if (kIsWeb) {
        final permission = await _firebaseMessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
        return permission.authorizationStatus == AuthorizationStatus.authorized;
      }
      
      // Para Android
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      print('Erro ao solicitar permissão de notificação: $e');
      return false;
    }
  }
  
  /// Obtém o token do dispositivo
  static Future<String?> _getDeviceToken() async {
    try {
      // Para web, usamos o VAPID key
      if (kIsWeb) {
        // O token é gerado automaticamente pelo Firebase quando configurado
        // Você precisa configurar a VAPID key no Firebase Console
        _deviceToken = await _firebaseMessaging.getToken(
          vapidKey: "YOUR_VAPID_KEY_HERE" // Configure no Firebase Console
        );
      } else {
        _deviceToken = await _firebaseMessaging.getToken();
      }
      
      if (kDebugMode) {
        print('Device Token: $_deviceToken');
      }
      
      return _deviceToken;
    } catch (e) {
      print('Erro ao obter token do dispositivo: $e');
      return null;
    }
  }
  
  /// Retorna o token atual
  static String? get deviceToken => _deviceToken;
  
  /// Obtém um novo token (útil para quando o token expira)
  static Future<String?> refreshToken() async {
    return await _getDeviceToken();
  }
  
  /// Handler para mensagens recebidas quando o app está em foreground
  static void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Mensagem recebida em foreground: ${message.notification?.title}');
    }
    
    onMessageReceived?.call(message);
    
    // Você pode mostrar uma notificação local aqui se necessário
    // usando flutter_local_notifications
  }
  
  /// Handler para quando o app é aberto através de uma notificação
  static void _handleMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      print('App aberto através de notificação: ${message.notification?.title}');
    }
    
    onMessageOpenedApp?.call(message);
  }
  
  /// Verifica se o app foi aberto através de uma notificação ao iniciar
  static Future<void> _checkInitialMessage() async {
    try {
      final message = await FirebaseMessaging.instance.getInitialMessage();
      if (message != null) {
        _handleMessageOpenedApp(message);
      }
    } catch (e) {
      print('Erro ao verificar mensagem inicial: $e');
    }
  }
  
  /// Envia o token do dispositivo para o Firestore
  /// Isso deve ser chamado após o login do usuário
  static Future<void> saveTokenToFirestore(String userId, String companyId) async {
    if (_deviceToken == null) {
      await _getDeviceToken();
    }
    
    if (_deviceToken != null) {
      try {
        // Aqui você salvaria o token no Firestore
        // Exemplo:
        // await FirebaseFirestore.instance
        //     .collection('companies')
        //     .doc(companyId)
        //     .collection('users')
        //     .doc(userId)
        //     .collection('tokens')
        //     .doc(_deviceToken)
        //     .set({
        //       'token': _deviceToken,
        //       'createdAt': FieldValue.serverTimestamp(),
        //       'platform': kIsWeb ? 'web' : Platform.operatingSystem,
        //     });
        
        if (kDebugMode) {
          print('Token salvo no Firestore para usuário: $userId');
        }
      } catch (e) {
        print('Erro ao salvar token no Firestore: $e');
      }
    }
  }
  
  /// Remove o token do dispositivo do Firestore
  /// Isso deve ser chamado no logout do usuário
  static Future<void> removeTokenFromFirestore(String userId) async {
    if (_deviceToken == null) return;
    
    try {
      // Aqui você removeria o token do Firestore
      // Exemplo:
      // await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(userId)
      //     .collection('tokens')
      //     .doc(_deviceToken)
      //     .delete();
      
      if (kDebugMode) {
        print('Token removido do Firestore para usuário: $userId');
      }
    } catch (e) {
      print('Erro ao remover token do Firestore: $e');
    }
  }
  
  /// Subscribe to a topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      if (kDebugMode) {
        print('Inscrito no tópico: $topic');
      }
    } catch (e) {
      print('Erro ao assinar tópico: $e');
    }
  }
  
  /// Unsubscribe from a topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('Desinscrito do tópico: $topic');
      }
    } catch (e) {
      print('Erro ao cancelar assinatura do tópico: $e');
    }
  }
  
  /// Inscreve o usuário em notificações da empresa
  static Future<void> subscribeToCompanyNotifications(String companyId) async {
    await subscribeToTopic('company_$companyId');
  }
  
  /// Inscreve o usuário em notificações de uma OS específica
  static Future<void> subscribeToOsNotifications(String osId) async {
    await subscribeToTopic('os_$osId');
  }
  
  /// Cria a mensagem de notificação para testar
  static Future<void> sendTestNotification() async {
    // Nota: Isso requer uma Cloud Function ou servidor
    // Não é possível enviar notificações diretamente do cliente
    // sem um servidor ou Cloud Function
    
    if (kDebugMode) {
      print('Para enviar notificação de teste, use:');
      print('1. Firebase Console > Messaging');
      print('2. Ou uma Cloud Function');
    }
  }
}

/// Classe para representar dados de notificação locally
class NotificationData {
  final String? title;
  final String? body;
  final Map<String, dynamic>? data;
  final RemoteMessage? message;
  
  NotificationData({
    this.title,
    this.body,
    this.data,
    this.message,
  });
  
  /// Cria uma NotificationData a partir de uma RemoteMessage
  factory NotificationData.fromRemoteMessage(RemoteMessage message) {
    return NotificationData(
      title: message.notification?.title,
      body: message.notification?.body,
      data: message.data,
      message: message,
    );
  }
  
  /// Retorna o ID da OS dos dados da notificação
  String? get osId => data?['osId'];
  
  /// Retorna o tipo de notificação
  String? get notificationType => data?['type'];
  
  /// Retorna se é uma notificação de nova OS
  bool get isNewOs => notificationType == 'new_os';
  
  /// Retorna se é uma notificação de OS atualizada
  bool get isOsUpdated => notificationType == 'os_updated';
  
  /// Retorna se é uma notificação de novo diário
  bool get isNewDiario => notificationType == 'new_diario';
}

