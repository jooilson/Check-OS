# TODO: Implementar Paginação no Repository de OS

## Plano de Implementação

### 1. Modificar `os_repository.dart`
- [x] Adicionar método `getOsPaginated({int limit = 50, DocumentSnapshot? lastDocument})` 
  - Retorna Future com tupla (List<OsModel>, DocumentSnapshot último documento)
- [x] Manter método `getOs()` original para compatibilidade retroativa (ou converter para usar limit)

### 2. Modificar `lista_page.dart`
- [x] Adicionar ScrollController para detectar scroll infinito
- [x] Adicionar estado para controlar carregamento de mais dados
- [x] Adicionar indicador de carregamento no final da lista
- [x] Implementar lógica de carregamento incremental

### 3. Testes
- [ ] Verificar se a paginação funciona corretamente
- [ ] Verificar se a ordenação continua funcionando

