# Guia de Testes - Sistema de Diários

## Testes Manuais

### Teste 1: Adicionar um novo diário
1. Abra a aplicação
2. Vá até a lista de OS
3. Clique em uma OS com status "Pendente"
4. Na página de detalhes, clique em "Adicionar Diário"
5. Preencha os campos:
   - KM Inicial: 1000
   - KM Final: 1050
   - Hora Início: 08:00
   - Início Intervalo: 12:00
   - Fim Intervalo: 13:00
   - Hora Término: 17:00
6. Clique em "Salvar Diário"
7. **Esperado**: Mensagem de sucesso e volta para detalhes da OS

### Teste 2: Visualizar diário criado
1. Na página de detalhes da OS (após salvar)
2. Role para baixo até "Diários Registrados"
3. Veja a lista com o novo diário
4. Clique no card para expandir
5. **Esperado**: Vê os dados completos do diário e um campo mostrando "KM Percorrido: 50 km"

### Teste 3: Editar um diário
1. Na página de detalhes, role até "Diários Registrados"
2. Expanda um diário
3. Clique em "Editar"
4. Altere algum valor (ex: KM Inicial de 1000 para 1005)
5. Clique em "Atualizar Diário"
6. **Esperado**: Volta para detalhes e o KM percorrido agora mostra "45 km"

### Teste 4: Deletar um diário
1. Na página de detalhes, role até "Diários Registrados"
2. Expanda um diário
3. Clique em "Deletar"
4. Confirme a exclusão
5. **Esperado**: Diário desaparece da lista e mostra mensagem de sucesso

### Teste 5: Verificar que diários aparecem em tempo real
1. Abra dois navegadores/dispositivos com a mesma OS
2. Em um, clique "Adicionar Diário"
3. Preencha e salve
4. No outro dispositivo, veja a lista se atualizar automaticamente
5. **Esperado**: Novo diário aparece sem precisar recarregar

### Teste 6: Testar validações
1. Clique em "Adicionar Diário"
2. Deixe os campos vazios
3. Clique em "Salvar Diário"
4. **Esperado**: Formulário ainda está visível (não salva)

## Testes em Firebase

### Verificar dados salvos
1. Abra Firebase Console
2. Vá para Firestore Database
3. Acesse a coleção `diarios`
4. **Esperado**: Vê documentos com estrutura:
   ```json
   {
     "osId": "...",
     "numeroOs": "OS-001",
     "nomeCliente": "Nome do Cliente",
     "data": "2026-01-20T00:00:00.000Z",
     "kmInicial": 1000,
     "kmFinal": 1050,
     "horaInicio": "08:00",
     "intervaloInicio": "12:00",
     "intervaloFim": "13:00",
     "horaTermino": "17:00",
     "createdAt": "2026-01-20T10:30:00.000Z",
     "updatedAt": "2026-01-20T10:30:00.000Z"
   }
   ```

### Testar índices
1. Se receber erro "composite index required"
2. Firebase oferece link direto para criar índice
3. Crie o índice conforme sugerido
4. **Esperado**: Diários aparecem ordenados corretamente por data

## Testes de Erro

### Teste 1: Sem conexão
1. Desconecte internet
2. Tente adicionar diário
3. **Esperado**: Mostrar erro "Erro ao salvar diário"

### Teste 2: OS finalizada
1. Crie ou edite uma OS para estar com status "Finalizada"
2. Abra a página de detalhes
3. **Esperado**: Não há botão "Adicionar Diário" e não há botões de editar/deletar

### Teste 3: Valores negativos no KM
1. Clique "Adicionar Diário"
2. Digite "-100" em KM Inicial
3. Clique "Salvar Diário"
4. **Esperado**: Salva normalmente (não há validação contra negativos)

## Casos Extremos

### Teste 1: Dados faltando
1. Deixe todos os campos de horário em branco
2. Preencha apenas data
3. Clique "Salvar Diário"
4. **Esperado**: Salva com sucesso (horários são opcionais)

### Teste 2: Múltiplos diários
1. Crie 10+ diários para a mesma OS
2. Vá para a página de detalhes
3. **Esperado**: Todos aparecem ordenados por data (mais recentes primeiro)

### Teste 3: Formato de horário
1. Digite "1800" em Hora Início
2. Clique salvar
3. **Esperado**: Salva como "1800" (sem validação de formato HH:MM)

## Checklist de Verificação

- [ ] Adicionar diário funciona
- [ ] Lista atualiza automaticamente
- [ ] Editar diário funciona
- [ ] Deletar diário funciona
- [ ] Cálculo de KM está correto
- [ ] Campos opcionais funcionam
- [ ] Erros são mostrados corretamente
- [ ] Firebase contém os dados corretos
- [ ] Stream funciona em tempo real
- [ ] Botões aparecem apenas para OS pendente
- [ ] Data é exibida no formato correto (dd/MM/yyyy)
- [ ] Campos em branco não aparecem
- [ ] Loading indicator funciona
- [ ] Confirmação de deleção funciona
- [ ] Volta para detalhes OS após salvar

## Performance

- Tempo para carregar lista: < 1 segundo
- Tempo para salvar diário: < 2 segundos
- Atualização em tempo real: < 100ms
- Sem lag ao expandir/recolher cards
