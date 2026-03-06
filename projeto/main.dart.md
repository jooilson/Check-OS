# main.dart
(c:/Projetos/checkos/lib/main.dart)

# Descrição Geral
Ponto de entrada principal do aplicativo CheckOS. Responsável por inicializar o Firebase, App Check e Push Notifications antes de iniciar o aplicativo Flutter.

# Responsabilidade no Sistema
Este arquivo é o primeiro código executado quando o aplicativo inicia. Ele coordena a inicialização de serviços externos necessários para o funcionamento do app.

# Dependências
- checkos/app.dart
- checkos/core/utils/logger.dart
- checkos/firebase_options.dart
- checkos/services/push_notification_service.dart
- firebase_core
- firebase_app_check
- firebase_messaging
- flutter/material.dart

# Classes
Nenhuma classe definida. Apenas função main().

# Métodos / Funções
- **main()** (Future<void>)
  - Finalidade: Inicializar o aplicativo de forma assíncrona
  - Comportamento interno:
    1. Garante que WidgetsFlutterBinding esteja inicializado
    2. Verifica e inicializa o Firebase (trata caso já esteja inicializado para evitar erros em hot reload)
    3. Ativa o App Check (desabilitado para web e em modo debug para evitar erros)
    4. Inicializa o serviço de Push Notifications
    5. Executa o widget principal MyApp

# Fluxo de Execução
1. O app inicia chamando main()
2. Firebase.initializeApp() é chamado com as opções de plataforma
3. FirebaseAppCheck ativa (Android debug provider em produção seria necessário configurar)
4. PushNotificationService.initialize() configura notificações
5. runApp(const MyApp()) inicia a interface Flutter

# Integração com o Sistema
- Firebase Core: Configuração global do Firebase
- App Check: Segurança adicional para Firebase services
- Push Notifications: Serviço de notificações push

# Estrutura de Dados
Nenhuma estrutura de dados específica.

# Regras de Negócio
- O Firebase deve ser inicializado antes de qualquer uso
- App Check é pulado em modo web (requer configuração adicional no Firebase Console)
- Push Notifications são opcionais - o app funciona mesmo se falharem

# Pontos Críticos
- A verificação de Firebase.apps.isNotEmpty é importante para hot reload durante desenvolvimento
- O App Check em modo debug pode bloquear uploads ao Storage se muitas requisições forem feitas
- Push Notifications podem falhar em alguns dispositivos - não bloqueia o app

# Melhorias Possíveis
- Adicionar tratamento de erro mais robusto para Firebase.initializeApp
- Configurar App Check corretamente para produção (safetyNetProvider para Android)
- Adicionar splash screen enquanto serviços inicializam

# Observações Técnicas
- Suporta múltiplas plataformas: Android, iOS, Web, Windows
- Usa DefaultFirebaseOptions.currentPlatform para configuração automática por plataforma
- O código tem tratamento de erro para não bloquear o app se algum serviço falhar

