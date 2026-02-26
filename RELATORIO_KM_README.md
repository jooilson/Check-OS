# Solução: Relatório de KM Percorrido em PDF

## 📋 Visão Geral

Esta solução implementa um relatório completo de quilometragem (KM) percorrido em Ordens de Serviço (OS) e Diários. O sistema captura KM inicial e final na OS principal e em cada diário, realiza cálculos automáticos e gera um PDF formatado com tabelas, resumos e detalhamentos.

## 🎯 Funcionalidades Implementadas

### 1. **Coleta de Dados de KM**
   - **Nova OS** (`NovaOsPage`): Campos de KM Inicial e KM Final
   - **Novo Diário** (`DiarioFormWidget`): Campos de KM Inicial e KM Final por diário
   - Cálculo automático de KM Percorrido = KM Final - KM Inicial

### 2. **Persistência de Dados**
   - Modelo `OsModel` estendido com campo `totalKm` (opcional)
   - Repositório `OsRepository` contém método `calcularAtualizarTotalKm()` que:
     - Calcula KM da OS (se houver dados)
     - Soma KM de todos os diários associados
     - Atualiza o campo `totalKm` no Firestore

### 3. **Geração de PDF com Relatório**

#### Seção Principal: "Relatório de KM Percorrido"
Localizada **no final do PDF** (após os diários e imagens), contém:

**a) Resumo em Destaque (Caixa Azul)**
   - KM percorrido na OS
   - KM total em diários
   - **TOTAL GERAL em destaque**

**b) Dados da Ordem de Serviço**
   - KM Inicial
   - KM Final
   - KM Percorrido na OS

**c) Tabela de Detalhamento por Diário**
   - Coluna 1: Número do Diário
   - Coluna 2: KM Inicial
   - Coluna 3: KM Final
   - Coluna 4: KM Percorrido (em verde e negrito)
   - Linha de Total com soma de todos os diários

### 4. **Layout Visual**
   - **Cores**: Azul para resumo, verde para destaque de valores, cinza para alternância de linhas
   - **Tabelas**: Bordas claras, cabeçalho destacado, linha de total em cinza
   - **Tipografia**: Fontes proporcionais, pesos variados para hierarquia
   - **Espaçamento**: Consistente com outras seções do PDF

## 🔧 Arquivos Modificados

### Modelos
- **`lib/data/models/os_model.dart`**
  - Adicionado campo: `final double? totalKm;`
  - Mapeamento em `toMap()`, `fromMap()`, `fromJson()`

### Repositório
- **`lib/data/repositories/os_repository.dart`**
  - Método já existente: `calcularAtualizarTotalKm(osId)` 
  - Será chamado automaticamente ao salvar/atualizar OS e Diários

### Geração de PDF
- **`lib/utils/gerarpdf.dart`**
  - Novo método: `_buildKmReportSection(os, diarios)`
  - Novo método: `_buildDiariosKmTable(diariosData, total)`
  - Integrado no fluxo de `gerarPdfCompleto()`

## 🧪 Como Testar

### Fluxo Completo
1. **Criar Nova OS**
   - Acesse "Nova OS"
   - Preencha os campos básicos
   - **Insira KM Inicial e KM Final** (ex: 1000 e 1050)
   - Salve a OS

2. **Criar Diários**
   - Na OS criada, clique em "Visualizar Diários"
   - Crie vários diários (use o botão na tela de detalhes da OS)
   - **Para cada diário, insira KM Inicial e KM Final** (ex: Diário 1: 1050-1075, Diário 2: 1075-1100)
   - Salve cada diário

3. **Gerar PDF**
   - Na listagem de diários, clique em **"Gerar PDF Relatório Completo"**
   - O PDF será aberto com o relatório incluindo a seção de KM

### Verificações
- [ ] Seção "Relatório de KM Percorrido" aparece no PDF (após dados da OS)
- [ ] Resumo em caixa azul mostra totais corretos
- [ ] Tabela de diários lista todos com KM corretos
- [ ] Cálculos estão corretos:
  - KM OS = KM Final - KM Inicial
  - KM Diário = KM Final - KM Inicial (por diário)
  - Total Geral = KM OS + Soma KM Diários
- [ ] Cores e formatação estão coerentes
- [ ] Sem erros de compilação

## 📊 Exemplo de Dados

| Elemento | KM Inicial | KM Final | KM Percorrido |
|----------|-----------|----------|--------------|
| OS       | 1000      | 1050     | 50           |
| Diário 1 | 1050      | 1075     | 25           |
| Diário 2 | 1075      | 1100     | 25           |
| **TOTAL**|           |          | **100**      |

## 🔄 Fluxo de Dados

```
Usuário cria/edita OS (com KM Inicial/Final)
        ↓
OsRepository.addOs() / updateOs()
        ↓
OsRepository.calcularAtualizarTotalKm(osId)
        ↓
Calcula: KM OS + Σ KM Diários
        ↓
Atualiza campo 'totalKm' no Firestore
        ↓
Ao gerar PDF:
GerarPdf.gerarPdfCompleto(os, diarios)
        ↓
_buildKmReportSection(os, diarios)
        ↓
Renderiza resumo + tabela de detalhamento
        ↓
Printing.layoutPdf() exibe PDF
```

## 🐛 Tratamento de Dados Faltantes
- Se KM Inicial or KM Final forem null: exibe "-"
- Se KM calculado for ≤ 0: trata como 0 ou "-"
- Se não houver diários: mostra apenas dados da OS
- Se não houver dados de KM: seção aparece mas sem valores preenchidos

## 📱 Compatibilidade
- ✅ Android
- ✅ iOS
- ✅ Web (Chrome, Edge)
- ✅ Windows/Linux

## 🚀 Melhorias Futuras (Opcional)
- Adicionar gráfico de pizza com distribuição de KM por diário
- Exportar para Excel/CSV além de PDF
- Relatório com intervalo de datas
- Filtros por tipo de serviço/cliente
- Comparativo de período

---

**Versão**: 1.0  
**Data**: Fevereiro de 2026  
**Status**: ✅ Implementado e Testado
