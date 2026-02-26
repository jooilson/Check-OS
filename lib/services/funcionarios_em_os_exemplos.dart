/// 📋 EXEMPLOS DE USO - Sistema de Funcionários em OS
/// 
/// Este arquivo demonstra como o sistema de funcionários se integra
/// com a criação e edição de OrdenS de Serviço (OS)

// ============================================================================
// EXEMPLO 1: Campo de Funcionário com Autocompletar
// ============================================================================

example_1_autocomplete_basico() {
  // Quando o usuário abre a página de criar nova OS:
  // 1. O campo de funcionário fica vazio
  // 2. Quando o usuário clica, mostra lista de TODOS os funcionários cadastrados
  // 3. Conforme digita, filtra automaticamente
  
  // Exemplo de lista mostrada:
  // ┌─────────────────────────────────┐
  // │ Maria Silva (Técnico)           │
  // │ João Santos (Encanador)         │
  // │ Pedro Costa (Eletricista)       │
  // └─────────────────────────────────┘
  
  // Se digitar "Maria":
  // ┌─────────────────────────────────┐
  // │ Maria Silva (Técnico)           │
  // └─────────────────────────────────┘
}

// ============================================================================
// EXEMPLO 2: Cadastro Rápido de Novo Funcionário
// ============================================================================

example_2_cadastro_rapido() {
  // Situação: Técnico novo chega e precisa estar na OS
  
  // Passo 1: Usuário abre campo de funcionário
  // Passo 2: Digita "Carlos Silva"
  // Passo 3: Sistema não encontra, mostra:
  //         [Cadastrar "Carlos Silva"] button
  // Passo 4: Usuário clica
  // Passo 5: Aparece diálogo:
  //         ┌────────────────────────────────┐
  //         │ Cadastrar Novo Funcionário     │
  //         │                                │
  //         │ O funcionário "Carlos Silva"   │
  //         │ não está cadastrado.           │
  //         │ Deseja cadastrá-lo agora?      │
  //         │                                │
  //         │ [Cancelar] [Cadastrar]         │
  //         └────────────────────────────────┘
  // Passo 6: Clica "Cadastrar"
  // Passo 7: Abre EmployeeRegistrationPage com:
  //         - Nome pré-preenchido: "Carlos Silva"
  //         - Foco no campo de Email
  // Passo 8: Usuário preenche:
  //         - Email: carlos@empresa.com
  //         - Cargo: Assistente Técnico
  //         - Telefone: (11) 99999-9999
  // Passo 9: Confirma "Adicionar Funcionário"
  // Passo 10: Retorna para a OS
  // Passo 11: Campo automaticamente preenchido com "Carlos Silva"
  // Passo 12: Mensagem: "Funcionário cadastrado com sucesso!"
}

// ============================================================================
// EXEMPLO 3: Múltiplos Funcionários em Uma OS
// ============================================================================

example_3_multiplos_funcionarios() {
  // Estrutura de campo:
  // 
  // ┌─────────────────────────────────────────────────────────┐
  // │ Funcionários                                            │
  // ├─────────────────────────────────────────────────────────┤
  // │                                                         │
  // │ [Maria Silva▼] [+] [-]                                 │
  // │                                                         │
  // │ [João Santos▼] [+] [-]                                 │
  // │                                                         │
  // │ [Pedro Costa▼] [+] [-]                                 │
  // │                                                         │
  // └─────────────────────────────────────────────────────────┘
  //
  // Comportamento:
  // - Primeiro campo: sempre tem [+], sem [-]
  // - Próximos campos: têm [+] e [-]
  // - [-] remove o campo
  // - [+] adiciona novo campo abaixo
  
  // Fluxo:
  // 1. Cria OS
  // 2. Seleciona Maria Silva no campo 1
  // 3. Clica [+] para adicionar campo 2
  // 4. Digita "João" no campo 2 → Filtra
  // 5. Seleciona João Santos
  // 6. Clica [+] para adicionar campo 3
  // 7. Digita "Pedro" no campo 3 → Filtra
  // 8. Seleciona Pedro Costa
  // 9. Poderia remover com [-] qualquer campo após o primeiro
}

// ============================================================================
// EXEMPLO 4: Validação de Funcionário
// ============================================================================

example_4_validacao() {
  // Quando usuário tenta salvar a OS com funcionário inválido:
  
  // Cenário A: Campo vazio
  // Erro: "Campo obrigatório"
  // Comportamento: Impede salvar, foco no campo
  
  // Cenário B: Nome digitado que não existe
  // Campo: [Roberto Silva          ] [+] [-]
  // Erro: "Funcionário não cadastrado. Pressione Enter para cadastrar."
  // Comportamento: 
  //   - Impede salvar a OS
  //   - Oferece cadastrar pelo Enter
  //   - Ou usuário apaga e seleciona da lista
  
  // Cenário C: Funcionário selecionado da lista
  // Campo: [Maria Silva            ] [+] [-]
  // Validação: ✓ Aceito (existe na lista)
  // Comportamento: Permite salvar
}

// ============================================================================
// EXEMPLO 5: Fluxo Completo de Criação de OS
// ============================================================================

example_5_fluxo_completo() {
  // PRÉ-REQUISITO: Usuário já tem funcionários cadastrados
  // Passo 1: Abrir "Nova OS"
  // Passo 2: Preencher:
  //         - Número OS: OS-001
  //         - Cliente: João Cliente
  //         - Serviço: Reparo Hidrálico
  //         - Relato: Vazamento na pia
  //         - Responsável: João (campo do app, não funcionário)
  //         - [✓] Tem Pedido? Sim → Número: PED-001
  // 
  // Passo 3: SEÇÃO FUNCIONÁRIOS ← NOVO
  //         Campo 1: [Maria Silva▼] [+]
  //         └─ Clicou na lista, selecionou Maria
  //         
  //         Clicou [+], aparece campo 2:
  //         Campo 2: [            ] [+] [-]
  //         └─ Digita "Jo"
  //         └─ Mostra sugestões:
  //            - João Santos (Encanador)
  //            - João Pereira (Técnico)
  //         └─ Clica em "João Santos"
  //         
  //         Clicou [+], aparece campo 3:
  //         Campo 3: [            ] [+] [-]
  //         └─ Digita "Pedro"
  //         └─ Mostra sugestão:
  //            - Pedro Costa (Eletricista)
  //         └─ Clica em "Pedro Costa"
  //
  // Passo 4: Continuar preenchendo horários, KM, etc...
  // Passo 5: Clicar "Salvar OS"
  // 
  // Resultado em OsModel:
  // {
  //   numeroOs: "OS-001",
  //   nomeCliente: "João Cliente",
  //   servico: "Reparo Hidrálico",
  //   relatoCliente: "Vazamento na pia",
  //   responsavel: "João",
  //   temPedido: true,
  //   numeroPedido: "PED-001",
  //   funcionarios: [
  //     "Maria Silva",
  //     "João Santos",
  //     "Pedro Costa"
  //   ],
  //   ... outros campos
  // }
  //
  // Log de Auditoria (se Maria fez a OS):
  // {
  //   userId: "user-123",
  //   userEmail: "joao@empresa.com",
  //   userName: "João Silva",
  //   employeeId: "maria-id",
  //   employeeName: "Maria Silva",
  //   action: "CREATE_OS",
  //   osNumero: "OS-001",
  //   funcionarios: ["Maria Silva", "João Santos", "Pedro Costa"],
  //   timestamp: "2026-02-02T14:30:00Z",
  //   description: "OS-001 criada em 02/02/2026"
  // }
}

// ============================================================================
// EXEMPLO 6: Edição de OS Existente
// ============================================================================

example_6_edicao() {
  // Quando usuário abre uma OS existente para editar:
  //
  // Situação: OS-001 tem [Maria Silva, João Santos, Pedro Costa]
  //
  // Passo 1: Abrir "Editar OS"
  // Passo 2: Campos carregam com dados anteriores:
  //         Campo 1: [Maria Silva     ] [+] [-]
  //         Campo 2: [João Santos     ] [+] [-]
  //         Campo 3: [Pedro Costa     ] [+] [-]
  //
  // Passo 3: Usuário quer remover João
  //         Clica [-] no campo 2
  //         Resultado:
  //         Campo 1: [Maria Silva     ] [+]
  //         Campo 2: [Pedro Costa     ] [+] [-]
  //
  // Passo 4: Quer adicionar Carlos (novo)
  //         Clica [+]
  //         Novo campo 3: [            ] [+] [-]
  //         Digita "Carlos"
  //         Oferece cadastro pois não existe
  //         Cadastra Carlos Silva
  //         Resultado:
  //         Campo 1: [Maria Silva     ] [+]
  //         Campo 2: [Pedro Costa     ] [+] [-]
  //         Campo 3: [Carlos Silva    ] [+] [-]
  //
  // Passo 5: Salvar
  // Resultado: OS-001 atualizado com [Maria Silva, Pedro Costa, Carlos Silva]
}

// ============================================================================
// EXEMPLO 7: Integração com LogModel (Auditoria)
// ============================================================================

example_7_auditoria() {
  // LogModel foi atualizado para rastrear funcionário
  
  // Quando Maria cria OS-001:
  // 
  // Log criado:
  // {
  //   userId: "user-joao",           // Quem criou a conta (João)
  //   userEmail: "joao@empresa.com",
  //   userName: "João Silva",
  //   
  //   employeeId: "emp-maria",       // Qual funcionário fez (Maria)
  //   employeeName: "Maria Silva",   // ✨ NOVO - Nome do funcionário
  //   
  //   timestamp: DateTime.now(),
  //   action: "CREATE_OS",
  //   osId: "os-001-id",
  //   osNumero: "OS-001",
  //   description: "OS-001 criada com funcionários: Maria Silva, João Santos"
  // }
  //
  // Benefício: Saber exatamente qual funcionário fez cada ação na OS
  // - João criou a conta
  // - Maria criou a OS
  // - Rastrear quem fez alterações
  // - Auditoria completa por funcionário
}

// ============================================================================
// EXEMPLO 8: Filtragem de Funcionários por Status
// ============================================================================

example_8_filtragem_status() {
  // Sistema só mostra funcionários ATIVOS
  
  // Funcionários cadastrados:
  // - Maria Silva (ativo) ✓ Mostra
  // - João Santos (ativo) ✓ Mostra
  // - Pedro Costa (inativo) ✗ NÃO mostra
  //
  // Quando usuário edita OS com Pedro:
  // - Campo mostra: [Pedro Costa] (já estave no campo)
  // - Ao abrir sugestões: Pedro NÃO aparece
  // - Mas campo mantém o nome se estava antes
  //
  // Motivo: Soft delete preserva histórico
  // - Se Pedro foi desativado, OS anterior não se quebra
  // - Mas novos campos não podem adicionar Pedro
  // - Força cadastro de funcionário novo se necessário
}

// ============================================================================
// EXEMPLO 9: Tratamento de Erros
// ============================================================================

example_9_erros() {
  // Erro 1: Sem funcionários cadastrados
  // Campo: [            ]
  // Ao clicar: "Nenhum funcionário cadastrado"
  // Solução: Ir para Configurações → Gerenciar Funcionários → Criar um
  //
  // Erro 2: Erro ao carregar funcionários
  // Campo: [            ]
  // Ao clicar: Toast com "Erro ao carregar funcionários: [erro]"
  // Solução: Verificar conexão internet, tentar novamente
  //
  // Erro 3: Email já existe (ao cadastrar novo)
  // Usuario: "maria.silva@empresa.com" já existe
  // Mensagem: "Erro ao adicionar funcionário: Email já existe"
  // Solução: Usar email diferente
  //
  // Erro 4: Campo de OS não preenchido
  // Mensagem ao salvar: "Campo obrigatório" em vermelho
  // Solução: Selecionar funcionário da lista ou cadastrar novo
}

// ============================================================================
// EXEMPLO 10: Atalhos Teclado
// ============================================================================

example_10_teclado() {
  // Enter no campo de funcionário:
  //   Se tem sugestões:
  //     - Seleciona a primeira sugestão
  //   Se não tem sugestões:
  //     - Abre diálogo para cadastrar novo funcionário
  //
  // Tab:
  //   - Sai do campo
  //   - Foca no próximo campo
  //
  // Exemplo:
  // Campo 1: [Maria|] ← Cursor aqui
  //   ↓ Digita "a"
  // Campo 1: [Maria a|]
  //   ↓ Deleta com Backspace
  // Campo 1: [Maria |] → Mostra sugestões
  //   ↓ Digita nova letra
  // Campo 1: [Maria Silva|]
  //   ↓ Tab ou Clica fora
  // Campo 1: [Maria Silva] ✓ Validado
}

// ============================================================================
// RESUMO VISUAL - COMO FUNCIONA
// ============================================================================

/*

1. FLUXO DE CRIAR OS
┌─────────────────────────────────────────────────────────────┐
│                      NOVA OS PAGE                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [Dados Básicos]                                            │
│  - Número OS: OS-001                                        │
│  - Cliente: João Cliente                                    │
│  - Serviço: Reparo                                          │
│                                                             │
│  [FUNCIONÁRIOS] ← NOVO                                      │
│  ┌───────────────────────────────────────────────────────┐ │
│  │ [Maria Silva        ] [+] [-] ← Selecionado        │ │
│  │ [João Santos        ] [+] [-] ← Selecionado        │ │
│  │ [            ] [+]           ← Campo vazio         │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                             │
│  [Horários, KM, etc...]                                     │
│                                                             │
│  [SALVAR]                                                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘

2. FLUXO DE NOVO FUNCIONÁRIO
┌──────────────────────────┐
│ Digita nome não exists   │
│ "Carlos Silva"           │
└──────────────────────────┘
            ↓
┌──────────────────────────┐
│ [Cadastrar "Carlos"]     │ ← Botão ElevatedButton
└──────────────────────────┘
            ↓
┌──────────────────────────┐
│ Confirma em AlertDialog  │
└──────────────────────────┘
            ↓
┌──────────────────────────┐
│ EmployeeRegistrationPage │
│ - Nome: Carlos Silva     │
│ - Email: [campo vazio]   │
│ - Cargo: [campo vazio]   │
│ - Telefone: [v vazio]    │
└──────────────────────────┘
            ↓
┌──────────────────────────┐
│ Salva funcionário        │
└──────────────────────────┘
            ↓
┌──────────────────────────┐
│ Volta para NovaOsPage    │
│ Campo preenchido:        │
│ [Carlos Silva    ] [+]   │
└──────────────────────────┘

*/

// ============================================================================
// DICAS E BOAS PRÁTICAS
// ============================================================================

tips_praticas() {
  // TIP 1: Cadastre funcionários com nomes completos
  // Bom: "Maria Silva Santos"
  // Ruim: "Maria" (pode ter outras Marias)
  //
  // TIP 2: Use emails corporativos únicos
  // Formato: nome.sobrenome@empresa.com
  // Evita duplicação
  //
  // TIP 3: Preencha cargo corretamente
  // Permite filtrar e gerar relatórios
  //
  // TIP 4: Telefone para contato emergencial
  // Formato: (XX) XXXXX-XXXX
  //
  // TIP 5: Para desativar, vá em Configurações
  // Soft delete preserva histórico de OS
  //
  // TIP 6: Múltiplos funcionários na OS
  // Importante para rastrear quem trabalhou
  // Facilita relatórios e métricas
}
