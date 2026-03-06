# push_notification_service.dart
(c:/Projetos/checkos/lib/services/push_notification_service.dart)

# Descricao Geral
Servico de notificacoes push via Firebase Cloud Messaging.

# Responsabilidade no Sistema
Gerencia envio e recebimento de notificacoes push.

# Metodos
- **initialize()** - Inicializa o servico
- **requestPermission()** - Solicita permissao
- **getToken()** - Obtem token do dispositivo
- **subscribeToTopic(String topic)** - Inscreve em topico
- **unsubscribeFromTopic(String topic)** - Desinscreve de topico

# Topicos
- empresa_{companyId}: Notificacoes da empresa
- os: Notificacoes de OS

# Integracao
- FirebaseMessaging
- Firebase Cloud Messaging (FCM)

