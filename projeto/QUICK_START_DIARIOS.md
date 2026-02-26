# 🚀 Quick Start - Sistema de Diários

## O que foi implementado?

Um **sistema completo de gerenciamento de diários** para cada Ordem de Serviço (OS), permitindo:
- ✅ Visualizar lista de diários de uma OS
- ✅ Criar novos diários com data e horários
- ✅ Editar diários existentes
- ✅ Deletar diários
- ✅ Atualização em tempo real (Real-time Firestore Stream)
- ✅ Cálculo automático de KM percorrido

---

## 📁 Arquivos Criados/Modificados

### ✨ Novos Arquivos
1. **`lib/data/models/diario_model.dart`** - Modelo de dados
2. **`lib/data/repositories/diario_repository.dart`** - Operações Firebase
3. **`lib/presentation/pages/editar_diario_page.dart`** - Página de edição
4. **`lib/presentation/widgets/diario_list_widget.dart`** - Widget de lista

### 📝 Arquivos Modificados
1. **`lib/presentation/pages/novo_diario_page.dart`** - Agora salva no Firebase
2. **`lib/presentation/pages/detalhes_os_page.dart`** - Integra lista de diários

---

## 🎯 Como Usar

### 1️⃣ Adicionar Novo Diário

```
Detalhes OS Page
    ↓
[Clique "Adicionar Diário"]
    ↓
Preencha: Data, KM, Horários
    ↓
[Clique "Salvar Diário"]
    ↓
✅ Diário aparece na lista automaticamente
```

### 2️⃣ Visualizar Diários

Na página de detalhes da OS:
- Role até **"Diários Registrados"**
- Clique em qualquer card para expandir
- Veja todos os dados incluindo KM percorrido calculado

### 3️⃣ Editar Diário

```
Expanda um diário
    ↓
[Clique "Editar"]
    ↓
Modifique os dados
    ↓
[Clique "Atualizar Diário"]
    ↓
✅ Alterações salvas e lista atualiza automaticamente
```

### 4️⃣ Deletar Diário

```
Expanda um diário
    ↓
[Clique "Deletar"]
    ↓
Confirme exclusão
    ↓
✅ Diário removido da lista
```

---

## 💾 Dados no Firebase

**Coleção**: `diarios`

**Campos salvos**:
- `osId` - ID da OS
- `numeroOs` - Número da OS
- `nomeCliente` - Nome do cliente
- `data` - Data do diário (ISO8601)
- `kmInicial` - KM inicial (opcional)
- `kmFinal` - KM final (opcional)
- `horaInicio` - Hora início (opcional)
- `intervaloInicio` - Início intervalo (opcional)
- `intervaloFim` - Fim intervalo (opcional)
- `horaTermino` - Hora término (opcional)
- `createdAt` - Data criação
- `updatedAt` - Data atualização

---

## 🔄 Real-time Updates

O widget usa `StreamBuilder` do Firestore:
- Qualquer mudança no Firebase é refletida **imediatamente**
- Funciona em múltiplos dispositivos simultaneamente
- Sem necessidade de recarregar a página

---

## 📋 Regras de Negócio

| Regra | Detalhe |
|---|---|
| **OS Pendente** | Botões editar/deletar aparecem apenas aqui |
| **OS Finalizada** | Sem botão "Adicionar Diário" |
| **Campos Opcionais** | Horários e KM podem estar vazios |
| **Ordenação** | Diários ordenados por data (mais recente primeiro) |
| **Cálculo KM** | Automático: `kmFinal - kmInicial` |

---

## ✅ Checklist de Testes

- [ ] Adicionar diário aparece na lista
- [ ] Dados salvos corretamente no Firebase
- [ ] Lista atualiza em tempo real
- [ ] Edição funciona
- [ ] Deletação funciona com confirmação
- [ ] KM percorrido calcula corretamente
- [ ] Apenas OS pendente mostra botões de editar/deletar
- [ ] Formulários validam corretamente

---

## 🐛 Troubleshooting

### Diário não aparece após salvar
- ✓ Verifique conexão com Firebase
- ✓ Confirme que está em uma OS pendente
- ✓ Verifique console para erros

### Stream não atualiza em tempo real
- ✓ Verifique índices no Firestore
- ✓ Confirme que tem permissão de leitura no Firebase Rules

### Botão "Adicionar Diário" não aparece
- ✓ Verifique se `os.pendente == true`
- ✓ Se `false`, a OS está finalizada

---

## 📚 Documentação Completa

| Documento | Conteúdo |
|---|---|
| **DIARIOS_README.md** | Guia completo de funcionalidades |
| **ARQUITETURA_DIARIOS.md** | Fluxos e arquitetura do sistema |
| **TESTES_DIARIOS.md** | Guide de testes manuais |
| **SUMARIO_ALTERACOES.md** | Resumo de todos os arquivos alterados |

---

## 🎨 Componentes da UI

### Novo Diário Page
```
┌─────────────────────────────┐
│  Novo Diário               │
├─────────────────────────────┤
│  Número OS: [read-only]     │
│  Data: [datepicker]         │
│  KM Inicial: [input]        │
│  KM Final: [input]          │
│  Hora Início: [input]       │
│  Intervalo: [start] [end]   │
│  Hora Término: [input]      │
│                             │
│  [Salvar]  [Cancelar]       │
└─────────────────────────────┘
```

### Diário Card (Expandido)
```
┌─────────────────────────────┐
│ 📅 Diário - 20/01/2026      │
│ Horário: 08:00 - 17:00      │
├─────────────────────────────┤
│ KM Inicial:        1000     │
│ KM Final:          1050     │
│ KM Percorrido:     50 km    │
│ Hora Início:       08:00    │
│ Intervalo:   12:00 - 13:00  │
│ Hora Término:      17:00    │
│                             │
│ [Editar]  [Deletar]         │
└─────────────────────────────┘
```

---

## 🚨 Erros Conhecidos/Em Desenvolvimento

- Atualmente aceita KM negativo (pode adicionar validação)
- Sem validação de formato HH:MM (salva como string)
- Sem campos de observações/notas
- Sem suporte a anexar fotos

---

## 🔮 Melhorias Futuras

- [ ] Adicionar fotos ao diário
- [ ] Campo de notas/observações
- [ ] Exportar diários em PDF
- [ ] Gráficos de KM por período
- [ ] Relatório consolidado
- [ ] Validação de horários
- [ ] Filtragem por data

---

## 📞 Suporte

Se encontrar problemas:
1. Verifique a console do Dart
2. Confirme Firebase Rules
3. Veja `TESTES_DIARIOS.md` para troubleshooting
4. Consulte `ARQUITETURA_DIARIOS.md` para entender o fluxo

---

## ✨ Resumo

**Total de arquivos**: 6 (4 novos, 2 modificados)
**Linhas de código**: ~790 linhas
**Dependências adicionadas**: 0 (usando o que já existe)
**Tempo estimado de implementação**: 2-3 horas
**Status**: ✅ Pronto para usar
