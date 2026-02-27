# TODO - Corrigir Firebase Web Error

## Problema
Erro "core_patch.dart:295 Uncaught Error at firebase_core_web.dart:327:26" ao inicializar Firebase no web

## Causa Raiz
- Firebase não configurado para web no firebase.json
- firebase_options.dart não existe ou não está configurado corretamente

## Tarefas:
- [x] 1. Adicionar configuração web no firebase.json
- [x] 2. Criar lib/firebase_options.dart com configurações para todas plataformas
- [x] 3. Atualizar main.dart para usar FirebaseOptions
- [ ] 4. Adicionar VAPID key válida no push_notification_service.dart
- [ ] 5. Testar a aplicação web

## Próximos Passos
1. Substitua os valores placeholder em lib/firebase_options.dart pelos valores reais do seu projeto Firebase:
   - YOUR_WEB_API_KEY
   - YOUR_IOS_API_KEY
   - iosClientId
   - iosBundleId

2. Configure a VAPID key no Firebase Console para push notifications web

3. Execute `flutter pub get` e `flutter build web` para testar
