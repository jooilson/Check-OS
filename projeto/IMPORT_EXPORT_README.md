# 📋 Serviço de Importação e Exportação de Dados

## 📖 Visão Geral

O `ImportExportService` fornece funcionalidades completas para exportar, importar e gerenciar backups de dados da aplicação CheckOS.

## ✨ Funcionalidades

### 1. **Exportação de Dados**
- ✅ Exportar em JSON (backup completo)
- ✅ Exportar em CSV (planilha de Ordens de Serviço)
- ✅ Exportar por período específico
- ✅ Backup completo com imagens

### 2. **Importação de Dados**
- ✅ Importar de arquivo JSON
- ✅ Validação automática de dados
- ✅ Suporte a múltiplos formatos

### 3. **Gerenciamento de Backups**
- ✅ Listar backups disponíveis
- ✅ Deletar backups
- ✅ Compartilhar backups
- ✅ Limpeza automática de dados locais

### 4. **Sincronização**
- ✅ Sincronizar com servidor Firebase
- ✅ Callback customizável

## 🚀 Como Usar

### Importação

```dart
import 'package:checkos/services/import_export_service.dart';
```

### Exemplo 1: Exportar Dados em JSON

```dart
final caminho = await ImportExportService.exportarDados(
  ordemServiços: minhaListaDeOS,
  diarios: minhaListaDeDiarios,
  logs: minhaListaDeLogs,
);
print('Arquivo exportado em: $caminho');
```

### Exemplo 2: Exportar em CSV

```dart
final caminho = await ImportExportService.exportarDadosCSV(
  ordemServiços: minhaListaDeOS,
);
print('CSV exportado em: $caminho');
```

### Exemplo 3: Importar Dados

```dart
try {
  final dados = await ImportExportService.importarDados(caminhoArquivo);
  
  if (ImportExportService.validarDadosImportados(dados)) {
    final osImportadas = dados['ordemServiços'] as List<OsModel>;
    final diariosImportados = dados['diarios'] as List<DiarioModel>;
    final logsImportados = dados['logs'] as List<LogModel>;
  }
} catch (e) {
  print('Erro ao importar: $e');
}
```

### Exemplo 4: Listar Backups

```dart
final backups = await ImportExportService.listarBackups();
for (var backup in backups) {
  print(backup.path);
}
```

### Exemplo 5: Deletar Backup

```dart
await ImportExportService.deletarBackup(caminhoArquivo);
```

### Exemplo 6: Exportar por Período

```dart
final caminho = await ImportExportService.exportarPorPeriodo(
  ordemServiços: minhaListaDeOS,
  dataInicio: DateTime(2024, 1, 1),
  dataFim: DateTime(2024, 12, 31),
);
```

## 🎨 Interface de Usuário

### ImportExportPage

Use a página `ImportExportPage` para uma interface completa:

```dart
ImportExportPage(
  ordemServiços: osRepository.obterTodas(),
  diarios: diarioRepository.obterTodos(),
  logs: logRepository.obterTodos(),
  onDadosImportados: () {
    // Callback após importação
    setState(() {});
  },
)
```

### Recursos da Página:
- 📥 Botão de Exportar JSON
- 📊 Botão de Exportar CSV
- 📂 Lista de backups disponíveis
- 🔄 Importar dados de backup
- 📤 Compartilhar backup via Share
- 🗑️ Deletar backup

## 📊 Estrutura de Dados

### Formato JSON
```json
{
  "dataExportacao": "2024-01-29T10:30:00.000Z",
  "versao": "1.0",
  "ordemServiços": [...],
  "diarios": [...],
  "logs": [...]
}
```

### Formato CSV
```csv
Número OS,Nome Cliente,Serviço,Responsável,KM Inicial,KM Final,Hora Início,Hora Término,Finalizado,Garantia,Pendente,Data Criação
OS-001,Cliente A,Serviço 1,Responsável A,100,150,08:00,12:00,true,false,false,2024-01-29
```

## 🔧 Métodos Disponíveis

### Exportação

| Método | Descrição | Retorno |
|--------|-----------|---------|
| `exportarDados()` | Exporta todos os dados em JSON | `String` (caminho) |
| `exportarDadosCSV()` | Exporta OS em CSV | `String` (caminho) |
| `exportarPorPeriodo()` | Exporta dados de um período | `String` (caminho) |
| `exportarBackupCompleto()` | Exporta com imagens | `String` (caminho) |

### Importação

| Método | Descrição | Retorno |
|--------|-----------|---------|
| `importarDados()` | Importa dados de arquivo JSON | `Map<String, dynamic>` |
| `validarDadosImportados()` | Valida integridade dos dados | `bool` |

### Gerenciamento

| Método | Descrição | Retorno |
|--------|-----------|---------|
| `listarBackups()` | Lista todos os backups | `List<FileSystemEntity>` |
| `deletarBackup()` | Deleta um backup específico | `Future<void>` |
| `limparDadosLocais()` | Remove backups locais | `Future<void>` |
| `obterCaminhoDocumentos()` | Obtém pasta de documentos | `String` |

### Sincronização

| Método | Descrição | Retorno |
|--------|-----------|---------|
| `sincronizarComServidor()` | Sincroniza com servidor | `Future<void>` |

## ⚙️ Configuração

### Dependências Necessárias (já estão no pubspec.yaml)

```yaml
dependencies:
  path_provider: ^2.1.4
  intl: ^0.20.2
  share_plus: ^12.0.1
```

### Permissões Necessárias

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSDocumentUsageDescription</key>
<string>Precisamos acessar seus documentos para exportar e importar dados</string>
<key>NSLocalNetworkUsageDescription</key>
<string>Dados de backup serão salvos localmente</string>
```

## 🔒 Boas Práticas de Segurança

1. **Validar dados sempre antes de importar**
   ```dart
   if (ImportExportService.validarDadosImportados(dados)) {
     // Processar dados
   }
   ```

2. **Usar backups criptografados em produção**
   ```dart
   // TODO: Implementar criptografia
   ```

3. **Fazer backup automático periodicamente**
   ```dart
   // Ver exemplo10_backupAutomatico em import_export_exemplos.dart
   ```

4. **Limitar número de backups locais**
   ```dart
   final backups = await ImportExportService.listarBackups();
   if (backups.length > 5) {
     // Remover backups antigos
   }
   ```

## 📱 Integração com UI

### Adicionar botão na AppBar
```dart
AppBar(
  title: const Text('Minhas OS'),
  actions: [
    IconButton(
      icon: const Icon(Icons.backup),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImportExportPage(
              ordemServiços: osRepository.obterTodas(),
              diarios: diarioRepository.obterTodos(),
              logs: logRepository.obterTodos(),
              onDadosImportados: () {
                setState(() {});
              },
            ),
          ),
        );
      },
    ),
  ],
)
```

## 🐛 Tratamento de Erros

```dart
try {
  final caminho = await ImportExportService.exportarDados(
    ordemServiços: minhaLista,
    diarios: minhaLista,
    logs: minhaLista,
  );
} on FileSystemException catch (e) {
  // Erro de acesso ao arquivo
  print('Erro de arquivo: $e');
} catch (e) {
  // Outro erro
  print('Erro ao exportar: $e');
}
```

## 📊 Exemplos Completos

Veja `import_export_exemplos.dart` para 10 exemplos práticos de uso, incluindo:

1. ✅ Exportar JSON
2. ✅ Exportar CSV
3. ✅ Importar dados
4. ✅ Listar backups
5. ✅ Deletar backup
6. ✅ Exportar por período
7. ✅ Obter caminho de documentos
8. ✅ Limpar dados locais
9. ✅ Sincronizar com servidor
10. ✅ Backup automático

## 🔄 Fluxo Recomendado

```
1. Usuário clica em "Exportar" ou "Importar"
2. Sistema executa a operação
3. Mostrar SnackBar com resultado
4. Atualizar lista de backups
5. Callback para atualizar UI
```

## 📅 Melhorias Futuras

- [ ] Criptografia de backups
- [ ] Sincronização automática
- [ ] Compressão ZIP
- [ ] Cloud storage (Google Drive, Dropbox)
- [ ] Backup agendado
- [ ] Histórico de versões
- [ ] Comparação entre backups
- [ ] Restauração seletiva

## 💡 Dicas

1. **Performance**: Para grandes volumes de dados, fazer exportação em background
2. **Armazenamento**: Limpar backups antigos periodicamente
3. **Sincronização**: Sincronizar após criar/editar dados importantes
4. **Validação**: Sempre validar dados importados antes de usar

## 📞 Suporte

Para dúvidas ou problemas, consulte:
- Documentação do `path_provider`
- Documentação do `intl`
- Documentação do `share_plus`
