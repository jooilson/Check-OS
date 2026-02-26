# 📊 Visão Geral do Sistema de Diários

## 🎯 Objetivo

Permitir que o usuário visualize, crie, edite e delete **diários de trabalho** para cada Ordem de Serviço (OS), registrando horários, quilometragem e outras informações do dia.

---

## 🏗️ Estrutura Técnica

```
┌──────────────────────────────────────────────────────┐
│         CAMADA DE APRESENTAÇÃO (UI)                   │
├──────────────────────────────────────────────────────┤
│                                                       │
│  DetalhesOsPage            NovoDiarioPage            │
│  ├── Informações OS        ├── Form Input            │
│  ├── Diários Registrados   └── Validação            │
│  └── DiarioListWidget                                │
│      ├── Card Expansível    EditarDiarioPage         │
│      ├── Editar            ├── Form Edição           │
│      ├── Deletar           └── Validação             │
│      └── Real-time Updates                           │
│                                                       │
└────────────────┬─────────────────────────────────────┘
                 │
┌────────────────┴─────────────────────────────────────┐
│         CAMADA DE LÓGICA (Repositories)               │
├──────────────────────────────────────────────────────┤
│                                                       │
│         DiarioRepository                             │
│         ├── addDiario()                              │
│         ├── updateDiario()                           │
│         ├── deleteDiario()                           │
│         ├── getDiario()                              │
│         ├── getDiarios() → List                      │
│         └── getDiariosStream() → Stream (Real-time)  │
│                                                       │
└────────────────┬─────────────────────────────────────┘
                 │
┌────────────────┴─────────────────────────────────────┐
│         CAMADA DE DADOS (Firebase)                    │
├──────────────────────────────────────────────────────┤
│                                                       │
│  Firestore Database                                  │
│  ├── Collection: diarios                             │
│  │   ├── Document 1                                  │
│  │   │   ├── osId: "ABC123"                         │
│  │   │   ├── numeroOs: "OS-001"                     │
│  │   │   ├── data: "2026-01-20"                     │
│  │   │   ├── kmInicial: 1000                        │
│  │   │   ├── kmFinal: 1050                          │
│  │   │   └── ...                                     │
│  │   │                                               │
│  │   └── Document 2                                  │
│  │       └── ...                                     │
│  │                                                   │
│  └── Índices:                                        │
│      ├── (osId, data DESC)                           │
│      └── Filtro automático por OS                    │
│                                                       │
└──────────────────────────────────────────────────────┘
```

---

## 🔄 Fluxo de Dados

### 1. Criar Diário
```
User Action
    ↓
NovoDiarioPage.build()
    ↓
Form Validation
    ├─ Valid    → NovoDiarioPage._salvarDiario()
    └─ Invalid  → Error shown
    ↓
DiarioRepository.addDiario(diario)
    ↓
Firebase Firestore.collection('diarios').add()
    ↓
Firestore emits event to Stream
    ↓
DiarioListWidget StreamBuilder catches event
    ↓
UI refreshes with new diary
    ↓
✅ User sees new diary in list
```

### 2. Real-time Updates (Stream)
```
DetalhesOsPage mounted
    ↓
DiarioListWidget initialized
    ↓
DiarioRepository.getDiariosStream(osId) started
    ↓
Firestore listener active for this OS
    ↓
Any user modifies data in this OS → Firestore event
    ↓
StreamBuilder catches event → rebuilds
    ↓
All connected users see update immediately
```

### 3. Editar Diário
```
User clicks Edit
    ↓
Navigator → EditarDiarioPage(diario)
    ↓
Form fields populated with current values
    ↓
User modifies and clicks "Atualizar"
    ↓
Form validation
    ├─ Valid    → EditarDiarioPage._salvarDiario()
    └─ Invalid  → Error shown
    ↓
DiarioRepository.updateDiario(updated)
    ↓
Firebase Firestore.doc(id).update()
    ↓
Stream detects change → UI updates
    ↓
✅ User sees updated data
```

### 4. Deletar Diário
```
User clicks Delete
    ↓
ShowDialog confirmation
    ├─ Cancel → Close dialog
    └─ Confirm → DiarioRepository.deleteDiario(id)
    ↓
Firebase Firestore.doc(id).delete()
    ↓
Stream detects deletion → UI updates
    ↓
✅ Diary removed from list
```

---

## 📱 Interface Visual

```
╔════════════════════════════════════════════════╗
║         DETALHES DA OS                         ║
╠════════════════════════════════════════════════╣
║                                                ║
║  Informações Básicas                           ║
║  ├─ Cliente: João da Silva                    ║
║  ├─ Serviço: Manutenção                       ║
║  ├─ Responsável: Técnico A                    ║
║  └─ Status: Pendente                          ║
║                                                ║
║  [Adicionar Diário] ← Button when pendente    ║
║                                                ║
║  ─────────────────────────────────────────    ║
║                                                ║
║  Diários Registrados                           ║
║                                                ║
║  ┌───────────────────────────────────────┐   ║
║  │ 📅 Diário - 20/01/2026                │   ║
║  │ Horário: 08:00 - 17:00                │   ║
║  │ [+] Expandir                          │   ║
║  └───────────────────────────────────────┘   ║
║     ├─ KM Inicial: 1000                      ║
║     ├─ KM Final: 1050                        ║
║     ├─ KM Percorrido: 50 km                  ║
║     ├─ Hora Início: 08:00                    ║
║     ├─ Intervalo: 12:00 - 13:00              ║
║     ├─ Hora Término: 17:00                   ║
║     └─ [Editar] [Deletar]                    ║
║                                                ║
║  ┌───────────────────────────────────────┐   ║
║  │ 📅 Diário - 19/01/2026                │   ║
║  │ Horário: 08:00 - 17:00                │   ║
║  │ [+] Expandir                          │   ║
║  └───────────────────────────────────────┘   ║
║                                                ║
╚════════════════════════════════════════════════╝
```

---

## 💾 Estrutura Firebase

### Collection: `diarios`

```json
{
  "osId": "string",
  "numeroOs": "string",
  "nomeCliente": "string",
  "data": "2026-01-20T00:00:00.000Z",
  "kmInicial": 1000.0,
  "kmFinal": 1050.0,
  "horaInicio": "08:00",
  "intervaloInicio": "12:00",
  "intervaloFim": "13:00",
  "horaTermino": "17:00",
  "createdAt": "2026-01-20T10:30:00.000Z",
  "updatedAt": "2026-01-20T10:30:00.000Z"
}
```

### Índices do Firestore

| Campo | Ordem | Uso |
|---|---|---|
| osId | Ascending | Filtro |
| data | Descending | Ordenação |

---

## 🎯 Funcionalidades por Estado da OS

### OS Pendente ✅ Completo
- [x] Ver diários
- [x] Adicionar diário
- [x] Editar diário
- [x] Deletar diário
- [x] Real-time updates

### OS Finalizada ⛔ Bloqueada
- [x] Ver diários
- [ ] Adicionar diário (botão oculto)
- [ ] Editar diário (botões ocultos)
- [ ] Deletar diário (botões ocultos)
- [x] Real-time updates (read-only)

---

## 📊 Métricas de Performance

| Métrica | Target | Status |
|---|---|---|
| Load da lista | < 1s | ✅ |
| Salvar diário | < 2s | ✅ |
| Real-time update | < 100ms | ✅ |
| Editar diário | < 2s | ✅ |
| Deletar diário | < 1s | ✅ |

---

## 🔐 Segurança

### Firestore Rules (Recomendadas)

```
match /diarios/{document=**} {
  allow read: if request.auth != null;
  allow create: if request.auth != null && request.resource.data.osId != null;
  allow update, delete: if request.auth != null && request.auth.uid == get(/databases/$(database)/documents/diarios/$(document)).data.uid;
}
```

---

## 🧪 Casos de Teste

| Caso | Esperado | Status |
|---|---|---|
| Criar diário | Aparece na lista em tempo real | ✅ |
| Editar diário | Dados atualizados imediatamente | ✅ |
| Deletar diário | Remove da lista com confirmação | ✅ |
| Múltiplos usuários | Ambos veem atualizações | ✅ |
| OS finalizada | Botões ocultos | ✅ |
| Campos vazios | Salva com horários opcionais | ✅ |
| KM calculado | `final - inicial` correto | ✅ |

---

## 📈 Roadmap Futuro

### Fase 1 (Current) ✅
- [x] CRUD básico
- [x] Real-time updates
- [x] Validação

### Fase 2 (Próximo)
- [ ] Fotos
- [ ] Observações
- [ ] Assinatura

### Fase 3 (Longo prazo)
- [ ] Relatórios
- [ ] Exportar PDF
- [ ] Gráficos
- [ ] Análise de dados

---

## 🎓 Lições Aprendidas

1. **Stream é poder** - Atualizações em tempo real sem polling
2. **Model simples** - Fácil de manter e estender
3. **Separation of concerns** - Repository separa lógica
4. **User feedback** - Loading indicators e error messages importantes
5. **Validation early** - Evita erros no Firebase

---

## ✨ Conclusão

Um sistema robusto, escalável e fácil de usar para gerenciar diários de trabalho por OS. Pronto para produção com espaço para crescimento futuro.
