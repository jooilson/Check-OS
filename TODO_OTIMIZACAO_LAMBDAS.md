# TODO - Otimização Funções Anônimas no Build

## Tarefa: Extrair lambdas para métodos da classe em novaos_page.dart

### Passos:
- [x] 1. Criar método `_onTemPedidoChanged` para callback de temPedido
- [x] 2. Criar método `_onAddFuncionario` para callback de adicionar funcionário
- [x] 3. Criar método `_onRemoveFuncionario` para callback de remover funcionário
- [x] 4. Criar método `_onImagensChanged` para callback de imagens
- [x] 5. Criar métodos de assinatura: `_onPointerDown`, `_onPointerUp`, `_onPointerCancel`
- [x] 6. Criar método `_limparAssinatura` para botão limpar
- [x] 7. Substituir lambdas por referências de métodos no build()

## Resumo das Alterações:
- `onTemPedidoChanged`: lambda → `_onTemPedidoChanged`
- `onAdd` (Funcionários): lambda → `_onAddFuncionario`
- `onRemove` (Funcionários): lambda → `_onRemoveFuncionario`
- `onImagensChanged`: lambda → `_onImagensChanged`
- `onPointerDown` (assinatura): lambda → `_onPointerDown`
- `onPointerUp` (assinatura): lambda → `_onPointerUp`
- `onPointerCancel` (assinatura): lambda → `_onPointerCancel`
- Botão "Limpar Assinatura": lambda → `_limparAssinatura`


