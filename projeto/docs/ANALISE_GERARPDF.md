# MAPA DE COMPREENSÃO - gerarpdf.dart

## 1. VISÃO GERAL

O `gerarpdf.dart` é uma classe utilitária Dart/Flutter que gera PDFs completos para Ordens de Serviço. Usa os pacotes:
- `pdf` - Para criar o documento PDF
- `printing` - Para pré-visualizar/imprimir
- `intl` - Para formatação de datas
- `http` - Para baixar imagens de URLs
- `image` - Para comprimir imagens

**Todas as funções são estáticas** - não precisa instanciar a classe.

---

## 2. PONTOS DE ENTRADA (Métodos Públicos)

### 2.1 Método Principal
```dart
GerarPdf.gerarPdfCompleto(OsModel os, List<DiarioModel> diarios)
```
Gera o PDF completo com todos os dados.

### 2.2 Métodos de Compatibilidade
```dart
GerarPdf.generateOsPdf(OsModel os)           // Só OS (chama gerarPdfCompleto)
GerarPdf.generateDiariosPdf(List<DiarioModel> diarios, String numeroOs, String nomeCliente)  // Só Diários
```

---

## 3. ESTRUTURA DO PDF GERADO

O PDF segue esta ordem:

```
┌─────────────────────────────────────────┐
│ CABEÇALHO (todas as páginas)            │
│ Logo | Título | OS N°                   │
├─────────────────────────────────────────┤
│ DADOS GERAIS                            │
│ Cliente, Serviço, Responsável, KM...    │
├─────────────────────────────────────────┤
│ RELATOS                                 │
│ Relato do Cliente | Relato Técnico      │
├─────────────────────────────────────────┤
│ STATUS                                  │
│ Finalizado | Garantia | Pendente        │
├─────────────────────────────────────────┤
│ ASSINATURA DO CLIENTE                   │
│ [Imagem da assinatura]                  │
├─────────────────────────────────────────┤
│ IMAGENS DA OS PRINCIPAL                 │
│ [Galeria de fotos]                      │
├─────────────────────────────────────────┤
│ HISTÓRICO DE ATENDIMENTOS               │
│ Diário #1 | Diário #2 | ...             │
│ (cada um com seus dados + imagens)      │
├─────────────────────────────────────────┤
│ RELATÓRIO DE KM                         │
│ Resumo + Tabela detalhada               │
├─────────────────────────────────────────┤
│ RODAPÉ (todas as páginas)               │
│ "Gerado em: XX/XX/XXXX" | "Página X/Y"  │
└─────────────────────────────────────────┘
```

---

## 4. MÉTODOS DE CONSTRUÇÃO (Widgets PDF)

Cada seção do PDF é construída por um método privado (começa com `_`):

| Método | O que constrói |
|--------|-----------------|
| `_buildHeader()` | Cabeçalho com logo e número da OS |
| `_buildFooter()` | Rodapé com data e paginação |
| `_buildSectionHeader()` | Título de cada seção |
| `_buildStandardCard()` | Container padrão com borda |
| `_buildInfoRow()` | Linha "Rótulo: Valor" |
| `_buildOsInfoSection()` | Dados Gerais da OS |
| `_buildReportsSection()` | Relatos (cliente/técnico) |
| `_buildStatusSection()` | Indicadores de status |
| `_buildKmReportSection()` | Relatório de KM |
| `_buildDiariosKmTable()` | Tabela de KM por diário |
| `_statusChip()` | Chip de status (verde/azul/laranja) |
| `_buildSignatureSection()` | Imagem da assinatura |
| `_buildDiarioItem()` | Card de um diário |
| `_buildInlineImages()` | Galeria de imagens |

---

## 5. FLUXO DE EXECUÇÃO (gerarPdfCompleto)

```
1. Validar número da OS
2. Criar documento PDF
3. Criar formatadores de data/hora
4. Ordenar diários por número
5. Processar assinatura da OS
6. Coletar todas as imagens (OS + Diários)
7. Preparar/comprimir imagens
8. Carregar logo da empresa
9. Processar assinaturas dos diários
10. Criar MultiPage com todo o conteúdo
11. Exibir/Imprimir PDF
```

---

## 6. TRATAMENTO DE IMAGENS

### 6.1 Coleta de Imagens
```dart
_collectAllImages(os, diarios)
// Retorna: {'OS Principal': [...], 'Diário #2': [...], 'Diário #3': [...]}
```

### 6.2 Processamento
```dart
_prepareImages(imagePaths)
// - Baixa de URL ou lê do disco local
// - Comprime para max 800px (otimizado para Android)
// - Converte para pw.MemoryImage
```

### 6.3 Exibição
```dart
_buildInlineImages(images, title: 'Imagens da OS Principal')
// Galeria com wrap (quebra automática)
```

---

## 7. ASSINATURAS

### 7.1 Formato da String
A assinatura é armazenada como string serializada:
```
"10.0,20.5;11.2,22.0;null;14.0,19.5;..."
```
- Pontos separados por `;`
- Coordenadas separadas por `,`
- `null` = caneta levantada (quebra na linha)

### 7.2 Processamento
```dart
_deserializeSignature(signature)  // String → List<Offset?>
_generateSignatureImage(signature)  // String → Uint8List (PNG)
```

---

## 8. MODELOS DE DADOS USADOS

### OsModel (Ordem de Serviço)
```dart
- id, numeroOs, nomeCliente, servico
- relatoCliente, relatoTecnico
- responsavel, funcionarios
- kmInicial, kmFinal
- horaInicio, intervaloInicio, intervaloFim, horaTermino
- imagens, assinatura
- osfinalizado, garantia, pendente, pendenteDescricao
- createdAt, updatedAt
- temPedido, numeroPedido
```

### DiarioModel (Diário de Atendimento)
```dart
- id, numeroDiario, data
- relatoTecnico, relatoCliente
- horaInicio, intervaloInicio, intervaloFim, horaTermino
- kmInicial, kmFinal
- funcionarios, imagens, assinatura
```

---

## 9. CUSTOMIZAÇÕES POSSÍVEIS

### 9.1 Alterar Conteúdo
- **Adicionar campo na OS**: Adicionar `_buildInfoRow('Novo Campo', os.novoCampo)` em `_buildOsInfoSection()`
- **Adicionar campo no Diário**: Adicionar em `_buildDiarioItem()`
- **Nova seção**: Criar método `_buildNovaSecao()` e adicionar em `build:`

### 9.2 Alterar Estilo
- **Cores**: Mudar `PdfColors.*` (ex: `PdfColors.blueGrey700`)
- **Fontes**: Alterar `fontSize` em `pw.TextStyle()`
- **Espaçamento**: Modificar `pw.SizedBox(height: X)` ou `pw.EdgeInsets`
- **Bordas/Sombras**: Editar em `pw.BoxDecoration()`

### 9.3 Alterar Layout
- **Ordem das seções**: Reordenar widgets na lista `build:` do `pw.MultiPage`
- **Largura de colunas**: Editar em `_buildDiariosKmTable()` usando `FlexColumnWidth`

---

## 10. EXEMPLO: COMO ADICIONAR UM NOVO CAMPO

Suponha que você quer adicionar "Email do Cliente" na seção de Dados Gerais:

1. Encontre o método `_buildOsInfoSection()`
2. Adicione uma nova linha:
```dart
_buildInfoRow('Email', os.emailCliente),
```
3. Certifique-se que `OsModel` tem o campo `emailCliente`

---

## 11. DICAS PARA EDIÇÃO

1. **Sempre use `pw.`** antes de widgets do pacote pdf
2. **Teste frequentemente** - PDFs são difíceis de debugar
3. **Use `_buildStandardCard()`** para envolver conteúdo em containers
4. **Mantenha a ordem** das seções lógica e intuitiva
5. **Imagens consomem memória** - mantenha a compressão otimizada
6. **Assinaturas são opcionais** - sempre verifique se não são null/vazias

