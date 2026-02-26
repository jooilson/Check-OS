# TODO: Adicionar Suporte Web e PWA ao CheckOS

## Plano de Implementação - Web

- [x] 1. Atualizar lib/main.dart - Adicionar verificação kIsWeb para Firebase e App Check
- [x] 2. Atualizar lib/services/import_export_service.dart - Adicionar verificações de plataforma
- [x] 3. Atualizar lib/services/logo_service.dart - Adicionar verificações de plataforma
- [x] 4. Atualizar lib/presentation/widgets/diario_form_widget.dart - Adicionar verificações de plataforma
- [x] 5. Atualizar web/index.html - Melhorar título e descrição
- [x] 6. Executar flutter build web para verificar

## Plano de Implementação - PWA

- [x] 1. Atualizar web/manifest.json - Configurações PWA completas
- [x] 2. Adicionar web/sw.js - Service Worker para cache offline
- [x] 3. Adicionar web/offline.html - Página para modo offline
- [x] 4. Atualizar web/index.html - Tela de carregamento e meta tags PWA

## Melhorias PWA Avançadas

- [x] 1. Atualizar manifest.json com share_target e file_handlers
- [x] 2. Adicionar ícone iOS (180x180) no index.html
- [x] 3. Configurar Firebase Messaging para push notifications
- [ ] 4. Implementar cache offline com IndexedDB (Futuro)
- [ ] 5. Configurar VAPID key no Firebase Console (Para push web)

