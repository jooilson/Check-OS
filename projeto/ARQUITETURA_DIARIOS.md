# Fluxo do Sistema de Diários

## Arquitetura

```
┌─────────────────────────────────────────────────────────────────┐
│                      Detalhes OS Page                           │
│ ┌──────────────────────────────────────────────────────────────┐│
│ │ - Informações Básicas da OS                                   ││
│ │ - Horários e KM                                               ││
│ │ - Status da OS                                                ││
│ └──────────────────────────────────────────────────────────────┘│
│                              │                                   │
│                     ┌────────┴────────┐                         │
│                     │                 │                         │
│              ┌──────▼──────┐   ┌──────▼──────────┐              │
│              │ Novo Diário │   │ Diário List     │              │
│              │   Button    │   │   (Stream)      │              │
│              └──────┬──────┘   └─────────────────┘              │
│                     │                                            │
│                     │ Clica "Adicionar Diário"                  │
│                     │                                            │
│                ┌────▼─────────────┐                             │
│                │ Novo Diario Page │                             │
│                ├──────────────────┤                             │
│                │ - Data           │                             │
│                │ - KM Inicial     │                             │
│                │ - KM Final       │                             │
│                │ - Hora Início    │                             │
│                │ - Intervalo      │                             │
│                │ - Hora Término   │                             │
│                └────┬─────────────┘                             │
│                     │ Salvar                                     │
│                     │                                            │
│              ┌──────▼──────────────┐                            │
│              │ Diario Repository   │                            │
│              │ (addDiario)         │                            │
│              └──────┬──────────────┘                            │
│                     │                                            │
│              ┌──────▼──────────────┐                            │
│              │ Firebase Firestore  │                            │
│              │ Collection: diarios │                            │
│              └─────────────────────┘                            │
│                                                                  │
│ ┌─────────────────────────────────────────────────────────────┐│
│ │ Diario List Widget (Real-time Stream)                        ││
│ │ ┌────────────────────────────────────────────────────────┐  ││
│ │ │ Diário 1 - 20/01/2026                                 │  ││
│ │ │ Horário: 08:00 - 17:00                                │  ││
│ │ │ [EXPANDIR]                                            │  ││
│ │ │                                                        │  ││
│ │ │ KM Inicial: 1000                                      │  ││
│ │ │ KM Final: 1050                                        │  ││
│ │ │ KM Percorrido: 50 km                                 │  ││
│ │ │ Hora Início: 08:00                                    │  ││
│ │ │ Intervalo: 12:00 - 13:00                            │  ││
│ │ │ Hora Término: 17:00                                  │  ││
│ │ │ [EDITAR] [DELETAR]                                   │  ││
│ │ └────────────────────────────────────────────────────────┘  ││
│ │ ┌────────────────────────────────────────────────────────┐  ││
│ │ │ Diário 2 - 19/01/2026                                 │  ││
│ │ │ Horário: 08:00 - 17:00                                │  ││
│ │ │ [EXPANDIR]                                            │  ││
│ │ └────────────────────────────────────────────────────────┘  ││
│ └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

## Fluxo de Dados

```
CRIAR DIÁRIO:
─────────────
User Input → Novo Diario Page → DiarioRepository.addDiario() → Firebase → Stream atualiza → Lista se atualiza

EDITAR DIÁRIO:
──────────────
Expande Card → Clica Editar → Editar Diario Page → DiarioRepository.updateDiario() → Firebase → Stream atualiza

DELETAR DIÁRIO:
───────────────
Expande Card → Clica Deletar → Confirmação → DiarioRepository.deleteDiario() → Firebase → Stream remove → Lista se atualiza
```

## Componentes Principais

### 1. Models
- `DiarioModel` - Representa um diário

### 2. Repositories
- `DiarioRepository` - CRUD operations no Firebase

### 3. Pages
- `DetalhesOsPage` - Mostra OS e integra diários
- `NovoDiarioPage` - Cria novo diário
- `EditarDiarioPage` - Edita diário existente

### 4. Widgets
- `DiarioListWidget` - Lista de diários com real-time updates

## Fluxo de Validação

```
Formulário → Validação → Se válido → Salvar
                      ↓
                   Se inválido → Mostra erro
```

## Real-time Updates

O `DiarioListWidget` usa `StreamBuilder` para monitorar mudanças:

```dart
StreamBuilder<List<DiarioModel>>(
  stream: _diarioRepository.getDiariosStream(widget.osId),
  builder: (context, snapshot) {
    // Atualiza automaticamente quando Firebase muda
  }
)
```

## Regras de Negócio

- ✓ Diários só podem ser adicionados/editados/deletados se a OS estiver **pendente**
- ✓ Cada diário é vinculado a uma OS específica
- ✓ Diários são ordenados por data (mais recente primeiro)
- ✓ Cálculo automático de KM percorrido
- ✓ Timestamps automáticos (createdAt, updatedAt)
- ✓ Todos os campos de horários são opcionais
- ✓ KM pode ser inteiro ou decimal

## Performance

- Stream só atualiza para a OS específica (filtro: `where('osId', isEqualTo: osId)`)
- Limitado apenas aos diários da OS atual (sem N+1 queries)
- Utiliza orderBy para manter ordem consistente
- NeverScrollableScrollPhysics evita múltiplos scrolls
