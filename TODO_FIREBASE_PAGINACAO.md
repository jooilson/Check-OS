# TODO: Firebase Query Limits e Paginação

## Status: CONCLUÍDO ✓

## Tarefas:

### 1. os_repository.dart
- [x] Adicionar `orderBy('updatedAt', descending: true)` ao método `getOsPaginated()`
- [x] Limite alterado para 20

### 2. diario_repository.dart  
- [x] Adicionar `getDiariosPaginated(osId, {limit, lastDocument})`
- [x] Adicionar `getAllDiariosPaginated({limit, lastDocument})`

### 3. lista_page.dart
- [x] Atualizar limite de 50 para 20

### 4. Correções de tipo
- [x] Corrigir cast de `doc.data()` para `Map<String, dynamic>` em todos os métodos

## Resumo das Alterações:

### os_repository.dart:
- getOsPaginated(): limite padrão 20 + orderBy('updatedAt', descending: true)

### diario_repository.dart:
- getDiariosPaginated(): novo método com paginação por OS
- getAllDiariosPaginated(): novo método com paginação global
- Correções de cast em todos os métodos que usam fromMap

### lista_page.dart:
- Limite alterado de 50 para 20 (inicial e loadMore)

