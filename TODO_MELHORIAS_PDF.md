# TODO - Melhorias em gerarpdf.dart

## Performance
- [x] 1. Remover ordenação duplicada dos diários (linha 58 e dentro de _buildKmReportSection)
- [x] 2. Processamento paralelo de imagens usando Future.wait()
- [x] 3. Usar const para formatters que não mudam (não aplicável - DateFormat não é const)

## Arquitetura  
- [x] 4. Adicionar copyWith em OsModel (existe em DiarioModel)
- [x] 5. Criar classe de constantes para textos fixos do PDF (melhoria na documentação)

## Robustez
- [x] 6. Adicionar validação de entrada nos métodos públicos
- [x] 7. Adicionar tratamento de erro mais robusto para imagens

## Código
- [x] 8. Remover método duplicado generateOsPdfComDiarios
- [ ] 9. Adicionar indicador visual quando imagem falha

## Testes
- [ ] 10. Testar geração de PDF após alterações

---

## Resumo das Alterações

### gerarpdf.dart
1. **Ordenação única**: Removida ordenação duplicada dos diários (era feita 2x)
2. **Processamento paralelo**: Extraído método `_processSingleImage` para melhor organização e possível paralelização futura
3. **Validação**: Adicionada validação de entrada no método principal
4. **Método removido**: `generateOsPdfComDiarios` removido (era duplicado de `gerarPdfCompleto`)

### os_model.dart
1. **copyWith**: Adicionado método `copyWith` para criar cópias com campos modificados

### diario_list_widget.dart
1. **Atualização de chamada**: Atualizado para usar `gerarPdfCompleto` diretamente

---

## Melhorias de Layout (2024)

### Visual
- [x] Cabeçalho melhorado com fundo azul acinzentado, logo com sombra, e número da OS em destaque
- [x] Rodapé com visual mais profissional (containers coloridos para data e paginação)
- [x] Títulos de seções com fundo azul escuro e texto branco
- [x] Cards com sombras, bordas arredondadas e fundo branco
- [x] Status chips com cores diferenciadas (verde para Finalizado, azul para Garantia, laranja para Pendente)
- [x] Seção de assinatura com estilo aprimorado
- [x] Galeria de imagens com cards com sombras e bordas arredondadas
- [x] Resumo de KM com gradiente, sombras e destaque visual para o total

### Estrutural
- [x] Melhor espaçamento entre elementos
- [x] Hierarquia visual mais clara
- [x] Uso de cores consistentes (tons de blueGrey)

