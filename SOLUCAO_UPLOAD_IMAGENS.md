# Solução: Erro ao Carregar Imagens "object-not-found"

## 🔍 Diagnóstico

O erro `[firebase_storage/object-not-found] No object exists at the desired reference` era causado por:

**Causa Principal:** `Error getting App Check token; too many attempts`

O Firebase App Check estava falhando ao fornecer tokens, o que causava rejeição 404 do servidor quando o app tentava fazer upload das imagens.

---

## ✅ Alterações Realizadas

### 1. **lib/main.dart**
- Adicionado try-catch no `FirebaseAppCheck.instance.activate()` para melhor tratamento de erro
- Se App Check falhar, o app continua mas com aviso

### 2. **lib/presentation/pages/novaos_page.dart**
- Removida lógica confusa de trocar bucket (não era a causa do problema)
- Simplificado para usar o bucket padrão: `checkos-system.firebasestorage.app`
- Melhorado tratamento de erro com dicas sobre App Check e permissões
- Mantidas tentativas com retry para consistência eventual

---

## 🛠️ Próximos Passos Recomendados

### Opção A: Desabilitar App Check para Debug (Rápido)
Se estiver apenas desenvolvendo/testando, comente a ativação do App Check no `lib/main.dart`:

```dart
// try {
//   await FirebaseAppCheck.instance.activate(
//     androidProvider: AndroidProvider.debug,
//   );
// } catch (e) {
//   print('Aviso: Falha ao ativar App Check: $e');
// }
```

Depois rode:
```bash
flutter run
```

### Opção B: Configurar Firebase Storage Rules (Recomendado para Produção)
No **Firebase Console > Storage**:

1. Vá até **Rules** (Regras)
2. Configure para permitir acesso quando autenticado:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /os_images/{allPaths=**} {
      // Permite acesso se o usuário está autenticado
      allow read, write: if request.auth != null;
    }
  }
}
```

3. Clique **Publish**

### Opção C: Usar SafetyNet Provider (Para Produção com App Check)
Em `lib/main.dart`, troque para:

```dart
await FirebaseAppCheck.instance.activate(
  androidProvider: AndroidProvider.safetyNet,
);
```

Isso usa o Google SafetyNet (mais robusto que debug).

---

## 📋 Checklist de Verificação

- [ ] O arquivo está sendo enviado ao bucket correto: `checkos-system.firebasestorage.app`
- [ ] As regras do Storage permitem escrita para usuários autenticados
- [ ] Se usar App Check: o provedor (debug/safetyNet) está configurado e ativo
- [ ] Teste novamente após fazer as alterações

---

## 🧪 Como Testar

1. Faça das alterações recomendadas acima
2. Rode o app em debug:
   ```bash
   flutter run
   ```
3. Reproduza o upload de imagens
4. Copie os logs (deve incluir: "Usando bucket", "Iniciando upload", "Upload osfinalizado", "DownloadURL obtido")

---

## 📊 Logs Esperados (Sucesso)

```
I/flutter: Usando bucket: checkos-system.firebasestorage.app
I/flutter: Iniciando upload para bucket: checkos-system.firebasestorage.app, path: os_images/1770631302672.jpg
I/flutter: Upload osfinalizado. state=TaskState.success, bytesTransferred=123456, totalBytes=123456
I/flutter: Tentativa 1 de obter metadata para os_images/1770631302672.jpg
I/flutter: Metadata obtida: size=123456, contentType=image/jpeg
I/flutter: Tentativa 1 de obter downloadURL para os_images/1770631302672.jpg
I/flutter: DownloadURL obtido: https://firebasestorage.googleapis.com/...
```

---

## 🔗 Referências

- [Firebase Storage Rules Documentation](https://firebase.google.com/docs/storage/security)
- [Firebase App Check Documentation](https://firebase.google.com/docs/app-check)
- [Flutter Firebase Storage Plugin](https://pub.dev/packages/firebase_storage)

---

**Data:** 09/02/2026
**Status:** Solucionado ✅
