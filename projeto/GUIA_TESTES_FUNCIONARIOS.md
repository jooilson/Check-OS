# 🧪 Guia de Testes - Sistema de Funcionários e Auditoria

## ✅ Checklist de Testes

### 1️⃣ Fluxo de Registro com Funcionários

#### Teste 1.1: Cadastro de Nova Conta
```
PASSOS:
1. Abrir o app
2. Clique em "Crie agora" ou "Registrar"
3. Preencha:
   - Email: test@empresa.com
   - Senha: Teste@123
   - Confirmar Senha: Teste@123
4. Clique em "Registrar"

RESULTADO ESPERADO:
✓ Conta criada no Firebase
✓ Redirecionado para "Cadastre seus Funcionários"
✗ NÃO deve ir direto para Home
```

#### Teste 1.2: Página de Registro de Funcionários
```
PASSOS:
1. Após registro bem-sucedido
2. Você está em "Cadastre seus Funcionários"
3. Observe a mensagem informativa

RESULTADO ESPERADO:
✓ Página mostra ícone e explicação
✓ Formulário com campos: Nome, Email, Cargo, Telefone, CPF
✓ Dois botões: "Continuar com Funcionários" e "Pular Cadastro"
```

#### Teste 1.3: Adicionar Primeiro Funcionário
```
PASSOS:
1. Preencha os campos:
   - Nome: Maria Silva
   - Email: maria@empresa.com
   - Cargo: Técnico
   - Telefone: (11) 98888-8888
   - CPF: 123.456.789-00
2. Clique em "[+ Adicionar Funcionário]"

RESULTADO ESPERADO:
✓ Mensagem de sucesso
✓ Funcionário aparece na lista abaixo
✓ Formulário limpo para próximo funcionário
✓ Dados salvos no Firestore
```

#### Teste 1.4: Validação de Email Duplicado
```
PASSOS:
1. Tente adicionar outro funcionário
2. Use o email: maria@empresa.com (repetido)
3. Clique em "[+ Adicionar Funcionário]"

RESULTADO ESPERADO:
✗ Erro: "Este email já está cadastrado"
✗ Funcionário NÃO é adicionado
✓ Mensagem clara de erro
```

#### Teste 1.5: Validação de Campos Obrigatórios
```
PASSOS:
1. Deixe algum campo vazio
2. Clique em "[+ Adicionar Funcionário]"

RESULTADO ESPERADO:
✗ Erro: "Por favor, preencha todos os campos obrigatórios"
✗ Funcionário NÃO é adicionado
```

#### Teste 1.6: Deletar Funcionário do Registro
```
PASSOS:
1. Clique no ícone [🗑️] ao lado de um funcionário
2. Funcionário deve desaparecer da lista

RESULTADO ESPERADO:
✓ Funcionário removido da lista local
✓ Dados deletados do Firestore
```

#### Teste 1.7: Pular Cadastro de Funcionários
```
PASSOS:
1. Na página de registro
2. Clique em "[- Pular Cadastro]"

RESULTADO ESPERADO:
✓ Redirecionado para Home
✓ Sem funcionários cadastrados
✓ Pode continuar usando o app
```

#### Teste 1.8: Continuar com Funcionários
```
PASSOS:
1. Adicione 2-3 funcionários
2. Clique em "[✓ Continuar com Funcionários]"

RESULTADO ESPERADO:
✓ Redirecionado para Home
✓ Funcionários salvos no Firestore
✓ Pode começar a criar OS
```

---

### 2️⃣ Gerenciamento de Funcionários (Configurações)

#### Teste 2.1: Acessar Gerenciamento
```
PASSOS:
1. Estando na Home
2. Vá para Configurações (ícone ⚙️)
3. Procure por "Gerenciar Funcionários"
4. Clique no botão

RESULTADO ESPERADO:
✓ Abre a página "Gerenciamento de Funcionários"
✓ Mostra lista de funcionários cadastrados
✓ Interface similar ao cadastro
```

#### Teste 2.2: Adicionar Funcionário em Configurações
```
PASSOS:
1. Estando em "Gerenciamento de Funcionários"
2. Preencha os campos
3. Clique em "[Adicionar Funcionário]"

RESULTADO ESPERADO:
✓ Funcionário adicionado e aparece na lista
✓ Lista atualiza em tempo real
✓ Email duplicado é validado
```

#### Teste 2.3: Stream em Tempo Real
```
PASSOS:
1. Abra app em dois dispositivos
2. No dispositivo 1: adicione um funcionário
3. No dispositivo 2: observe a lista em Gerenciamento

RESULTADO ESPERADO:
✓ Lista atualiza automaticamente (dentro de 1-2 segundos)
✓ Novo funcionário aparece sem recarregar
```

#### Teste 2.4: Deletar Funcionário em Gerenciamento
```
PASSOS:
1. Clique no ícone [🗑️] de um funcionário
2. Confirme a exclusão

RESULTADO ESPERADO:
✓ Funcionário desaparece da lista
✓ Mensagem de confirmação
✓ Dados marcados como inativos no Firestore
```

---

### 3️⃣ Auditoria e Logs

#### Teste 3.1: Ver Logs de Auditoria
```
PASSOS:
1. Vá para Configurações
2. Clique em "Logs de Auditoria"
3. Observe o histórico

RESULTADO ESPERADO:
✓ Logs mostram ações registradas
✓ Cada log tem timestamp
✓ Mostra quem fez cada ação
```

#### Teste 3.2: Verificar Campos de Auditoria
```
PASSOS:
1. Crie uma OS
2. Vá para Logs de Auditoria
3. Procure pelo log da OS criada

RESULTADO ESPERADO:
✓ Log contém:
  - userEmail: seu email
  - userName: seu nome (se disponível)
  - employeeId: ID do funcionário (se aplicável)
  - employeeName: nome do funcionário (se aplicável)
  - timestamp: data e hora exata
  - action: tipo de ação (CREATE_OS, etc.)
  - osNumero: número da OS
```

---

### 4️⃣ Fluxo de Criação de OS com Auditoria

#### Teste 4.1: Criar OS com Rastreamento
```
PASSOS:
1. Estando na Home
2. Clique em "Nova OS"
3. Preencha os dados da OS
4. Clique em "Criar OS"

RESULTADO ESPERADO:
✓ OS criada com sucesso
✓ Log registrado no Firestore
✓ Log contém informações do funcionário se selecionado
```

#### Teste 4.2: Editar OS com Rastreamento
```
PASSOS:
1. Abra uma OS existente
2. Clique em "Editar"
3. Mude algum campo
4. Clique em "Salvar"

RESULTADO ESPERADO:
✓ OS atualizada
✓ Log registra: "UPDATE_OS"
✓ Timestamp reflete data/hora atual
```

#### Teste 4.3: Deletar OS com Rastreamento
```
PASSOS:
1. Abra uma OS
2. Menu → "Excluir"
3. Confirme exclusão

RESULTADO ESPERADO:
✓ OS deletada
✓ Log registra: "DELETE_OS"
✓ userEmail e timestamp registrados
```

---

### 5️⃣ Validações e Erros

#### Teste 5.1: Email Inválido
```
PASSOS:
1. Tente adicionar funcionário com email inválido
2. Exemplo: "maria" (sem @)

RESULTADO ESPERADO:
✗ Sistema não deve bloquear (não faz validação format)
ℹ️ Nota: Pode adicionar validação de email no futuro
```

#### Teste 5.2: CPF Vazio (Opcional)
```
PASSOS:
1. Adicione funcionário SEM preencher CPF
2. Deve funcionar normalmente

RESULTADO ESPERADO:
✓ Funcionário criado sem CPF
✓ Campo cpf no Firestore = null
```

#### Teste 5.3: Conta Sem Funcionários
```
PASSOS:
1. Crie conta e pule cadastro de funcionários
2. Tente criar OS

RESULTADO ESPERADO:
✓ Pode criar OS normalmente
✓ Logs salvos sem employeeId/employeeName
✓ Sistema funciona sem funcionários
```

---

### 6️⃣ Testes de Performance

#### Teste 6.1: Adicionar Múltiplos Funcionários
```
PASSOS:
1. Adicione 10-20 funcionários rapidamente
2. Observe a interface

RESULTADO ESPERADO:
✓ Sistema mantém responsividade
✓ Lista actualiza corretamente
✓ Sem travamentos ou erros
```

#### Teste 6.2: List Muito Grande
```
PASSOS:
1. Tenha 50+ funcionários cadastrados
2. Abra "Gerenciamento de Funcionários"
3. Scroll na lista

RESULTADO ESPERADO:
✓ Scroll suave e responsivo
✓ App não trava
✓ Performance aceitável
```

---

### 7️⃣ Testes de Sincronização

#### Teste 7.1: Offline → Online
```
PASSOS:
1. Desabilite internet
2. Tente adicionar funcionário
3. Reabilite internet

RESULTADO ESPERADO:
✓ App avisa que está offline (se implementado)
ou
✗ Operação falha com erro claro
```

#### Teste 7.2: Dados Persistem
```
PASSOS:
1. Cadastre funcionários
2. Feche o app completamente
3. Abra novamente

RESULTADO ESPERADO:
✓ Todos os funcionários aparecem na lista
✓ Dados não foram perdidos
✓ Sincronizado com Firebase
```

---

### 8️⃣ Testes de Segurança

#### Teste 8.1: Dados Isolados por Usuário
```
PASSOS:
1. Crie conta A e adicione funcionários
2. Crie conta B em outro dispositivo/browser
3. Verifique que A vê seus funcionários
4. Verifique que B não vê funcionários de A

RESULTADO ESPERADO:
✓ Cada usuário vê apenas seus funcionários
✓ Dados corretamente isolados no Firestore
✓ Segurança de privacidade OK
```

#### Teste 8.2: Soft Delete (Não Deletar Físico)
```
PASSOS:
1. No Firestore, verifique documento deletado
2. Campo isActive deve estar = false

RESULTADO ESPERADO:
✓ Documento ainda existe no Firestore
✓ isActive = false (não ativo)
✓ Não foi deletado permanentemente
```

---

### 9️⃣ Testes de UI/UX

#### Teste 9.1: Responsividade
```
PASSOS:
1. Teste em diferentes tamanhos de tela
2. Telefone pequeno, normal, grande
3. Modo paisagem e retrato

RESULTADO ESPERADO:
✓ Interface se adapta bem
✓ Botões clicáveis
✓ Texto legível
✓ Sem overflow de conteúdo
```

#### Teste 9.2: Acessibilidade
```
PASSOS:
1. Use app com botões virtuais (se mobile)
2. Teste com zoom aumentado

RESULTADO ESPERADO:
✓ Todos os botões acessíveis
✓ Texto ampliável
✓ Contraste suficiente
```

---

## 📊 Tabela de Testes

| # | Teste | Status | Observações |
|---|-------|--------|-------------|
| 1.1 | Cadastro de Nova Conta | ⏳ | - |
| 1.2 | Página de Registro | ⏳ | - |
| 1.3 | Adicionar Funcionário | ⏳ | - |
| 1.4 | Email Duplicado | ⏳ | - |
| 1.5 | Validação Campos | ⏳ | - |
| 1.6 | Deletar Funcionário | ⏳ | - |
| 1.7 | Pular Cadastro | ⏳ | - |
| 1.8 | Continuar com Funcionários | ⏳ | - |
| 2.1 | Acessar Gerenciamento | ⏳ | - |
| 2.2 | Adicionar em Config | ⏳ | - |
| 2.3 | Stream em Tempo Real | ⏳ | - |
| 2.4 | Deletar em Config | ⏳ | - |
| 3.1 | Ver Logs | ⏳ | - |
| 3.2 | Verificar Campos Logs | ⏳ | - |
| 4.1 | Criar OS com Rastreamento | ⏳ | - |
| 4.2 | Editar OS com Rastreamento | ⏳ | - |
| 4.3 | Deletar OS com Rastreamento | ⏳ | - |
| 5.1 | Email Inválido | ⏳ | - |
| 5.2 | CPF Vazio | ⏳ | - |
| 5.3 | Conta Sem Funcionários | ⏳ | - |
| 6.1 | Múltiplos Funcionários | ⏳ | - |
| 6.2 | List Muito Grande | ⏳ | - |
| 7.1 | Offline → Online | ⏳ | - |
| 7.2 | Dados Persistem | ⏳ | - |
| 8.1 | Dados Isolados | ⏳ | - |
| 8.2 | Soft Delete | ⏳ | - |
| 9.1 | Responsividade | ⏳ | - |
| 9.2 | Acessibilidade | ⏳ | - |

**Legenda:** ⏳ = Pendente | ✅ = Passou | ❌ = Falhou

---

## 🔍 Como Reportar Bugs

Se encontrar algum problema durante os testes:

1. **Descrição Clara**: O que você tentou fazer?
2. **Passos Reprodução**: Como reproduzir o problema?
3. **Resultado Esperado**: O que deveria acontecer?
4. **Resultado Obtido**: O que realmente aconteceu?
5. **Screenshots**: Se possível, anexe imagens
6. **Dispositivo**: Qual dispositivo/versão do Android/iOS?

---

## ✅ Critério de Sucesso

Sistema considerado **OK** quando:
- ✅ Todos os testes passam
- ✅ Sem erros no console
- ✅ Dados corretos no Firestore
- ✅ Performance aceitável
- ✅ UI/UX intuitiva
- ✅ Funcionários rastreados em logs

---

**Data:** Fevereiro de 2026  
**Versão:** 1.0  
**Responsável:** Desenvolvimento
