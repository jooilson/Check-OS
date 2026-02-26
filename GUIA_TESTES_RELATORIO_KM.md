# Guia de Testes - Relatório de KM Percorrido

## 📝 Escopo do Teste

Validação da funcionalidade de relatório de KM percorrido em Ordens de Serviço e Diários, incluindo:
- Coleta de dados de KM
- Cálculos automáticos
- Persistência em Firestore
- Geração de PDF com layout melhorado

## ✅ Casos de Teste

### CT-001: Criar Nova OS com KM

**Pré-requisitos:**
- Usuário autenticado no app
- Acesso à tela "Nova OS"

**Passos:**
1. Clique em "Nova OS"
2. Preencha todos os campos obrigatórios:
   - Número da OS: `OS001`
   - Nome do Cliente: `Cliente Teste`
   - Serviço: `Manutenção`
   - Relato do Cliente: `Teste de KM`
   - Responsável: `Técnico 1`
3. Procure os campos de quilometragem:
   - KM Inicial: `1000`
   - KM Final: `1050`
4. Verifique se o campo "KM Percorrido" auto-calcula para `50`
5. Salve a OS
6. Verificar nos logs: `calcularAtualizarTotalKm()` foi chamado

**Resultado Esperado:**
- ✓ OS criada com sucesso
- ✓ Campo KM Percorrido mostra `50`
- ✓ Dados persistem no Firestore
- ✓ Campo `totalKm` recebe valor na OS (inicialmente = `50`)

---

### CT-002: Criar Diário com KM

**Pré-requisitos:**
- OS criada (CT-001)
- Acesso a "Visualizar Diários" na OS

**Passos:**
1. Na tela de detalhes da OS, clique em "Visualizar Diários"
2. Clique em "Adicionar Diário" (ou equivalente)
3. Preencha todos os campos, incluindo:
   - KM Inicial: `1050`
   - KM Final: `1075`
4. Verifique cálculo automático: `25` km
5. Finalize o diário com status apropriado
6. Salve o diário
7. Verifique logs: `calcularAtualizarTotalKm()` foi chamado novamente

**Resultado Esperado:**
- ✓ Diário criado com sucesso
- ✓ Campo KM Percorrido mostra `25`
- ✓ Dados persistem no Firestore
- ✓ Campo `totalKm` na OS atualizado para `75` (50 da OS + 25 do diário)

---

### CT-003: Criar Múltiplos Diários

**Pré-requisitos:**
- OS criada (CT-001)
- Ao menos um diário já criado (CT-002)

**Passos:**
1. Crie mais dois diários (Diário 2 e 3):
   - **Diário 2**: KM 1075 → 1095 (20 km)
   - **Diário 3**: KM 1095 → 1110 (15 km)
2. Salve cada um
3. Verifique persistência no Firestore
4. Confirme que `calcularAtualizarTotalKm()` atualiza `totalKm`

**Resultado Esperado:**
- ✓ Todos os diários criados
- ✓ Cálculos corretos: 50 + 25 + 20 + 15 = 110 km total
- ✓ Campo `totalKm` na OS = `110`

---

### CT-004: Gerar PDF com Relatório de KM

**Pré-requisitos:**
- OS + múltiplos diários criados (CT-001 a CT-003)
- Disponível a opção de gerar PDF

**Passos:**
1. Acesse a listagem de diários da OS
2. Clique em **"Gerar PDF Relatório Completo"**
3. Aguarde a geração do PDF
4. Visualize o PDF gerado
5. Procure pela seção **"Relatório de KM Percorrido"**

**Validações no PDF:**

#### a) Layout da Seção
- [ ] Seção aparece **no final do PDF** (após histórico de diários e imagens)
- [ ] Título: "Relatório de KM Percorrido" em font grande/bold
- [ ] Conteúdo organizado em cards/containers

#### b) Resumo em Destaque (Caixa Azul)
- [ ] Fundo azul claro com borda azul
- [ ] Texto "Resumo Total"
- [ ] Dois valores à esquerda:
  - "OS: 50 km"
  - "Diários: 60 km"
- [ ] Caixa à direita com destaque:
  - "TOTAL: 110 km" em negrito

#### c) Dados da Ordem de Serviço
- [ ] Subseção "Dados da Ordem de Serviço"
- [ ] KM Inicial: 1000
- [ ] KM Final: 1050
- [ ] KM Percorrido: 50 km

#### d) Tabela de Detalhamento por Diário
- [ ] Cabeçalho com colunas:
  - Diário | KM Ini. | KM Fin. | KM Perc.
- [ ] Linhas para cada diário:
  - Diário #1.0 | 1050 | 1075 | 25 (em verde/bold)
  - Diário #2.0 | 1075 | 1095 | 20 (em verde/bold)
  - Diário #3.0 | 1095 | 1110 | 15 (em verde/bold)
- [ ] Linha de TOTAL:
  - TOTAL | | | 60 km (em azul/bold)
- [ ] Cores alternadas nas linhas (cinza claro/branco)
- [ ] Bordas visíveis entre colunas

**Resultado Esperado:**
- ✓ PDF gerado sem erros
- ✓ Seção de KM renderizada corretamente
- ✓ Todos os valores calculados corretamente
- ✓ Layout visualmente atraente
- ✓ Sem sobreposição de texto ou elementos

---

### CT-005: Editar Diário e Recalcular KM

**Pré-requisitos:**
- OS + múltiplos diários (CT-003)
- Acesso a editar diário

**Passos:**
1. Edite o Diário 2:
   - Altere KM Final: `1095` → `1100`
   - Nova diferença: 25 km (antes era 20)
2. Salve as alterações
3. Verifique se `totalKm` foi recalculado: deve ser `115` agora

**Resultado Esperado:**
- ✓ Diário atualizado
- ✓ KM Percorrido mostra `25`
- ✓ `totalKm` na OS = `115` (50 + 25 + 25 + 15)

---

### CT-006: Dados Faltantes/Nulos

**Pré-requisitos:**
- Criar uma OS sem dados de KM

**Passos:**
1. Crie uma OS **sem preencher** KM Inicial e KM Final
2. Crie um diário também **sem dados de KM**
3. Gere o PDF

**Resultado Esperado:**
- ✓ PDF gerado sem erros
- ✓ Campos nulos mostram "-"
- ✓ Totais mostram "0" ou "-"
- ✓ Tabela vazia ou sem linhas se não houver diários

---

### CT-007: Gerar PDF com Uma Diária Única

**Pré-requisitos:**
- OS com um único diário

**Passos:**
1. Crie OS com KM 2000 → 2050
2. Crie um único diário com KM 2050 → 2100
3. Gere o PDF

**Validações:**
- [ ] Resumo mostra:
  - OS: 50 km
  - Diários: 50 km
  - TOTAL: 100 km
- [ ] Tabela contém apenas uma linha de diário
- [ ] TOTAL da tabela: 50 km

**Resultado Esperado:**
- ✓ Tudo renderizado corretamente mesmo com um único diário

---

## 🔍 Validação de Código

### Verificações Estáticas
- [ ] Nenhum erro de compilação no `gerarpdf.dart`
- [ ] Método `_buildKmReportSection()` existe e é chamado
- [ ] Método `_buildDiariosKmTable()` existe e é usado
- [ ] Model `OsModel` contém campo `totalKm`
- [ ] Mapeamento `totalKm` funciona em `toMap()`, `fromMap()`, `fromJson()`
- [ ] Repositório `calcularAtualizarTotalKm()` está operacional

### Verificações de Runtime
- [ ] Sem exceções ao gerar PDF
- [ ] Sem erros de null pointer
- [ ] Sem formatação incorreta de números
- [ ] Cores renderizam corretamente

---

## 📊 Matriz de Testes

| CT | Descrição | Status | Data | Observações |
|----|-----------|--------|------|------------|
| CT-001 | Criar Nova OS com KM | ⏳ | | |
| CT-002 | Criar Diário com KM | ⏳ | | |
| CT-003 | Múltiplos Diários | ⏳ | | |
| CT-004 | Gerar PDF Completo | ⏳ | | |
| CT-005 | Editar e Recalcular | ⏳ | | |
| CT-006 | Dados Nulos | ⏳ | | |
| CT-007 | Diária Única | ⏳ | | |

**Legenda:**
- ✅ Passou
- ❌ Falhou
- ⏳ Pendente

---

## 🐛 Problemas Conhecidos / Limitações

Nenhum identificado no momento.

---

## 📚 Referências

- [Arquivo README da Solução](./RELATORIO_KM_README.md)
- [Classe GerarPdf](./lib/utils/gerarpdf.dart)
- [Modelo OsModel](./lib/data/models/os_model.dart)
- [DiarioModel](./lib/data/models/diario_model.dart)

---

**Versão do Guia:** 1.0  
**Data de Criação:** Fevereiro 2026  
**Última Atualização:** 10/02/2026
