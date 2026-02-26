# 🧪 GUIA DE TESTES - Sistema de Funcionários em OS

## ✅ Checklist de Validação

### 🟢 Testes Básicos

- [ ] **T1: Campo vazio ao abrir Nova OS**
  - Abrir "Nova OS"
  - Campo de funcionário deve estar vazio
  - Texto "Digite o nome do funcionário" deve aparecer

- [ ] **T2: Lista ao focar no campo**
  - Clicar no campo de funcionário vazio
  - Deve mostrar lista de TODOS os funcionários cadastrados
  - Cada funcionário mostra nome e cargo

- [ ] **T3: Filtro por digitação**
  - Digitar "Maria"
  - Deve filtrar apenas funcionários com "Maria" no nome
  - Maiúsculas/minúsculas não devem importar

- [ ] **T4: Seleção de funcionário existente**
  - Selecionar "Maria Silva" da lista
  - Campo deve preencher com "Maria Silva"
  - Sugestões devem desaparecer

- [ ] **T5: Validação positiva**
  - Preencher campo com funcionário da lista
  - Tentar salvar OS
  - Deve aceitar e NOT mostrar erro

---

### 🟡 Testes de Novo Funcionário

- [ ] **T6: Cadastro de novo funcionário**
  - Digitar "Carlos Silva" (não cadastrado)
  - Deve oferecer botão "Cadastrar 'Carlos Silva'"
  - Clicar botão

- [ ] **T7: Confirmação de cadastro**
  - Após clicar "Cadastrar"
  - Deve abrir AlertDialog perguntando se quer cadastrar
  - Opções: "Cancelar" e "Cadastrar"

- [ ] **T8: Formulário pré-preenchido**
  - Ao clicar "Cadastrar" no diálogo
  - Deve abrir EmployeeRegistrationPage
  - Campo "Nome" deve estar pré-preenchido com "Carlos Silva"
  - Foco deve estar em "Email"

- [ ] **T9: Preenchimento e salvamento**
  - Preencher Email, Cargo, Telefone
  - Clicar "Adicionar Funcionário"
  - Deve salvar no Firebase

- [ ] **T10: Retorno automático**
  - Após salvar, deve voltar para NovaOsPage
  - Campo deve estar preenchido com "Carlos Silva"
  - Toast verde com "Funcionário cadastrado com sucesso!"

---

### 🔴 Testes de Validação

- [ ] **T11: Campo vazio é inválido**
  - Deixar campo vazio
  - Tentar salvar OS
  - Deve mostrar erro "Campo obrigatório" em vermelho

- [ ] **T12: Nome não cadastrado é inválido**
  - Digitar "Roberto Silva" (sem confirmar cadastro)
  - Tentar salvar OS
  - Deve mostrar erro "Funcionário não cadastrado. Pressione Enter para cadastrar."

- [ ] **T13: Funciona com Enter**
  - Digitar nome não cadastrado
  - Pressionar Enter
  - Deve abrir diálogo de confirmação

- [ ] **T14: Cancelar cadastro preserva nome**
  - Digitar "João Silva"
  - Oferecer cadastro
  - Clicar "Cancelar"
  - Campo mantém "João Silva" mas ainda é inválido

---

### 🟦 Testes de Múltiplos Campos

- [ ] **T15: Adicionar novo campo (+)**
  - Preencher campo 1 com "Maria Silva"
  - Clicar ícone [+] verde
  - Novo campo deve aparecer abaixo
  - Pode ter até N campos

- [ ] **T16: Remover campo (-)**
  - Ter 2 ou mais campos preenchidos
  - Clicar ícone [-] vermelho em campo 2
  - Campo 2 deve ser removido
  - Campos abaixo sobem de posição

- [ ] **T17: Botão + e - aparecem correto**
  - Campo 1: [Funcionário1] [+] (sem [-])
  - Campo 2: [Funcionário2] [+] [-]
  - Campo 3: [Funcionário3] [+] [-]
  - Só o primeiro não tem [-]

- [ ] **T18: Múltiplos funcionários salvam**
  - Preencher 3 campos com funcionários diferentes
  - Salvar OS
  - OS deve conter todos os 3 funcionários
  - OsModel.funcionarios = [Func1, Func2, Func3]

---

### 🟣 Testes de Edição

- [ ] **T19: Carrega OS existente**
  - Editar OS com funcionários: [Maria, João, Pedro]
  - Campos devem carregar com os dados salvos
  - Campo 1: [Maria Silva]
  - Campo 2: [João Santos]
  - Campo 3: [Pedro Costa]

- [ ] **T20: Pode remover funcionário na edição**
  - OS tem [Maria, João, Pedro]
  - Remover João com [-]
  - Salvar
  - OS agora tem [Maria, Pedro]

- [ ] **T21: Pode adicionar novo na edição**
  - OS tem [Maria, João]
  - Adicionar campo 3
  - Digitar "Paulo Silva" (novo)
  - Cadastrar Paulo
  - Salvar
  - OS tem [Maria, João, Paulo Silva]

- [ ] **T22: Pode mudar funcionário**
  - Campo tem [Maria Silva]
  - Limpar e digitar [João Santos]
  - Clicar em João das sugestões
  - Campo muda para [João Santos]

---

### 🟪 Testes de Integração

- [ ] **T23: LogModel registra funcionário**
  - Criar OS com funcionário "Maria Silva"
  - Verificar LogModel salvo
  - employeeName deve ser "Maria Silva"
  - employeeId deve ter ID de Maria

- [ ] **T24: Funcionários aparecem na OS**
  - Listar OS criadas
  - Clicar em uma OS
  - Deve mostrar funcionários na visualização

- [ ] **T25: Funciona com Soft Delete**
  - Desativar funcionário em Configurações
  - Novo campo de funcionário NOT mostra o desativado
  - Mas OS antiga pode ainda ter o nome dele

- [ ] **T26: Integração com EmployeeRepository**
  - Cadastrar novo funcionário na OS
  - Verificar em "Gerenciar Funcionários"
  - Deve aparecer na lista

---

### 🔵 Testes de Erro

- [ ] **T27: Sem funcionários cadastrados**
  - Se usuário não tem funcionários
  - Clicar campo
  - Deve mostrar mensagem ou lista vazia
  - Oferecer ir para Configurações

- [ ] **T28: Erro ao carregar funcionários**
  - Se Firebase não responde
  - Campo deve mostrar erro
  - Toast com mensagem de erro

- [ ] **T29: Erro ao cadastrar funcionário**
  - Email já existe
  - Deve mostrar erro "Email já existe"
  - Campo permanece e pode tentar novamente

- [ ] **T30: Erro ao salvar OS**
  - Se Firebase falha ao salvar
  - Deve mostrar toast de erro
  - Dados permanecem no formulário

---

### 🟢 Testes de UX

- [ ] **T31: Foco automático no Email**
  - Abrir cadastro de novo funcionário
  - Foco deve estar em Email, não em Nome

- [ ] **T32: Sugestões com máximo de altura**
  - Muitos funcionários cadastrados
  - Lista de sugestões deve ter altura máxima
  - Deve ter scrollbar se muito longo

- [ ] **T33: Cargo aparece na sugestão**
  - Lista mostra:
    - Linha 1: Nome
    - Linha 2: Cargo (em menor texto)

- [ ] **T34: Toasts informativos**
  - Sucesso ao cadastrar: Verde, "Funcionário cadastrado com sucesso!"
  - Erro ao carregar: Vermelho, mensagem de erro
  - Campo obrigatório: vermelho ao salvar

- [ ] **T35: Teclado funciona bem**
  - Tab move para próximo campo
  - Enter confirma ou cadastra
  - Backspace apaga caracter
  - Setas filtram lista

---

### 🟣 Testes de Performance

- [ ] **T36: Autocomplete é rápido**
  - Digitar deve filtrar em < 100ms
  - Não deve travar a UI

- [ ] **T37: Lista grande não trava**
  - 1000+ funcionários cadastrados
  - Campo deve funcionar sem lag
  - Scroll na lista deve ser fluido

- [ ] **T38: Múltiplos campos não trava**
  - 10+ campos de funcionário
  - Adicionar/remover deve ser instantâneo
  - Formulário mantém responsividade

---

### 🟦 Testes de Dados

- [ ] **T39: Dados salvos corretamente**
  - Criar OS com [Maria, João]
  - Verificar Firebase Firestore
  - funcionarios: ["Maria Silva", "João Santos"] (lista)

- [ ] **T40: Edição preserva dados**
  - Editar OS, mudar um funcionário
  - Outros devem permanecer iguais
  - Apenas o editado muda

- [ ] **T41: Exclusão limpa dados**
  - Remover todos os funcionários
  - Salvar
  - OS tem funcionarios: [] (lista vazia)

- [ ] **T42: Busca funciona**
  - Procurar por OS com funcionário específico
  - Deve encontrar se funcionário está na lista

---

## 🎯 Ordem de Execução Recomendada

```
1. Preparação
   └─ Cadastrar 5+ funcionários em Configurações

2. Testes Básicos (T1-T5)
   └─ Validar funcionalidade principal

3. Novo Funcionário (T6-T10)
   └─ Validar fluxo de cadastro rápido

4. Validação (T11-T14)
   └─ Garantir que erros são captados

5. Múltiplos Campos (T15-T18)
   └─ Testar interface dinâmica

6. Edição (T19-T22)
   └─ Garantir persistência

7. Integração (T23-T26)
   └─ Validar com resto do sistema

8. Erros (T27-T30)
   └─ Comportamento em edge cases

9. UX (T31-T35)
   └─ Experiência do usuário

10. Performance (T36-T38)
    └─ Escalabilidade

11. Dados (T39-T42)
    └─ Integridade dos dados
```

---

## 📊 Resultado Esperado

### Após passar em TODOS os testes:

✅ Sistema está pronto para produção

**Funcionalidades Validadas:**
- Autocompletar de funcionários ✓
- Validação de dados ✓
- Cadastro rápido ✓
- Múltiplos funcionários ✓
- Integração com LogModel ✓
- Tratamento de erros ✓
- Performance aceitável ✓

---

## 🐛 Se encontrar bugs

| Symptoma | Possível Causa | Solução |
|----------|----------------|---------|
| Campo vazio ao abrir | Controllers não inicializado | Verificar initState() |
| Sugestões not appear | EmployeeRepository erro | Verificar Firestore |
| Cadastro não volta | Navigation stack | Verificar Navigator.pop() |
| Campo inválido sempre | Validação bug | Checar validador |
| Múltiplos campos buggado | Controle de estado | Verificar setState() |
| Slow performance | Query grande | Adicionar limite |

---

## 📞 Próximas Fases (Após Validação)

1. **Fase 1: Relatórios**
   - Mostrar OS por funcionário

2. **Fase 2: Filtros**
   - Filtrar OS por funcionário, período

3. **Fase 3: Dashboard**
   - Ver performance de cada funcionário

4. **Fase 4: Agendamento**
   - Agendar funcionários para OS específicas

---

**Boa sorte com os testes! 🎉**
