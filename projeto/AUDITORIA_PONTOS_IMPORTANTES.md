# 📌 PONTOS IMPORTANTES PARA AUDITORIA - CHECKOS

## Resumo Executivo

Este documento lista os pontos principais e críticos identificados durante a auditoria do sistema CheckOS. Use estas informações para entender a estrutura atual, identificar onde agir e planejar correções futuras.

---

## 1. 🔍 INFORMAÇÕES DO SISTEMA

### 1.1 Nome do Projeto
**CheckOS** - Sistema de Gerenciamento de Ordens de Serviço

### 1.2 Tecnologias Utilizadas
| Tecnologia | Versão | Uso |
|-----------|--------|-----|
| Flutter | - | Framework principal |
| Firebase Auth | - | Autenticação |
| Cloud Firestore | - | Banco de dados |
| Firebase Storage | - | Armazenamento de imagens |
| Firebase App Check | - | Segurança |
| PDF Package | - | Geração de PDFs |
| Provider | - | Gerenciamento de estado |

### 1.3 Estrutura de Dados Identificada

#### Coleções Firestore:
```
├── users/{uid}/
│   ├── email: string
│   ├── name: string
│   ├── role: string ("admin" | "employee")
│   └── createdAt: timestamp
│
├── employees/{uid}/
│   ├── name: string
│   ├── email: string
│   ├── role: string
│   ├── phone: string
│   ├── cpf: string? (opcional)
│   ├── isActive: boolean
│   ├── createdAt: timestamp
│   └── updatedAt: timestamp
│
├── os/{osId}/
│   ├── numeroOs: string
│   ├── nomeCliente: string
│   ├── servico: string
│   ├── relatoCliente: string
│   ├── responsavel: string
│   ├── temPedido: boolean
│   ├── numeroPedido: string?
│   ├── funcionarios: list<string> (apenas nomes!)
│   ├── kmInicial: double?
│   ├── kmFinal: double?
│   ├── horaInicio: string?
│   ├── intervaloInicio: string?
│   ├── intervaloFim: string?
│   ├── horaTermino: string?
│   ├── osfinalizado: boolean
│   ├── garantia: boolean
│   ├── pendente: boolean
│   ├── pendenteDescricao: string?
│   ├── relatoTecnico: string?
│   ├── assinatura: string? (serializada)
│   ├── imagens: list<string>
│   ├── totalKm: double?
│   ├── createdAt: timestamp?
│   └── updatedAt: timestamp?
│
├── diarios/{diarioId}/
│   ├── osId: string
│   ├── numeroOs: string
│   ├── numeroDiario: double (ex: 1.1, 1.2)
│   ├── nomeCliente: string
│   ├── servico: string?
│   ├── relatoCliente: string?
│   ├── responsavel: string?
│   ├── funcionarios: list<string>
│   ├── data: timestamp
│   ├── kmInicial: double?
│   ├── kmFinal: double?
│   ├── horaInicio: string?
│   ├── intervaloInicio: string?
│   ├── intervaloFim: string?
│   ├── horaTermino: string?
│   ├── osfinalizado: boolean
│   ├── garantia: boolean
│   ├── pendente: boolean
│   ├── pendenteDescricao: string?
│   ├── relatoTecnico: string?
│   ├── assinatura: string?
│   ├── imagens: list<string>
│   ├── createdAt: timestamp
│   └── updatedAt: timestamp
│
└── logs/{logId}/
    ├── userId: string
    ├── userEmail: string
    ├── userName: string?
    ├── employeeId: string? (NUNCA USADO!)
    ├── employeeName: string? (NUNCA USADO!)
    ├── timestamp: timestamp
    ├── action: string ("CREATE_OS", "UPDATE_OS", "DELETE_OS")
    ├── osId: string
    ├── osNumero: string
    └── description: string
```

---

## 2. 🎯 FLUXOS PRINCIPAIS DO SISTEMA

### 2.1 Fluxo de Cadastro de Usuário
```
[1] RegisterPage (register_page.dart)
    │
    ├── Input: email, password
    │
    └── _signUp() → AuthService.createUserWithEmailAndPassword()
              │
              └── Sucesso:
                  └── [2] EmployeeRegistrationPage
                       │
                       ├── Input: name, email, password, role, phone, cpf
                       │
                       ├── onComplete() → Navigator.popUntil(isFirst)
                       │
                       └── Result: Volta para AuthWrapper
```

### 2.2 Fluxo de Login
```
[1] LoginPage
    │
    ├── Input: email, password
    │
    └── FirebaseAuth.signInWithEmailAndPassword()
         │
         ├── Sucesso → AuthWrapper
         │              │
         │              └── HomePage (se primeiro acesso: EmployeeRegistrationPage)
         │
         └── Erro: Exibir mensagem
```

### 2.3 Fluxo de Criação de OS
```
[1] HomePage → Botão "Nova OS"
    │
    └── NovaOsPage
         │
         ├── Input: dados da OS
         │
         └── _salvar() → OsRepository.addOs(os)
                            │
                            └── LogRepository.addLog() ← PROBLEMA: não populado!
```

### 2.4 Fluxo de Gerenciamento de Funcionários
```
[1] ConfigPage → "Gerenciar Funcionários"
    │
    └── EmployeeManagementPage
         │
         ├── Lista: StreamBuilder → EmployeeRepository.getEmployeesStream()
         │
         ├── Adicionar: EmployeeAddPage
         │                │
         │                └── EmployeeRepository.addEmployee()
         │                     │
         │                     └── AuthService.registerEmployee()
         │                          │
         │                          └── Cria Auth + 2 coleções Firestore
         │
         └── Editar/Deletar: same page with arguments
```

---

## 3. ⚠️ PROBLEMAS CRÍTICOS DETALHADOS

### 3.1 Problema #1: Auditoria Incompleta (MAIS CRÍTICO)

**O que acontece:**
- Quando uma OS é criada, editada ou excluída, um log é salvo
- O log deveria conter o ID e nome do funcionário que fez a ação
- Esses campos existem no LogModel mas NUNCA são preenchidos
- Resultado: Não é possível rastrear ações por funcionário

**Onde ocorre:**
1. `lib/presentation/pages/novaos_page.dart` (linhas ~360-390)
2. `lib/presentation/pages/detalhes_os_page.dart` (linhas ~60-80)

**Como deveria ser:**
```dart
// CÓDIGO ATUAL (ERRADO):
await _logRepository.addLog(LogModel(
  userId: ...,
  userEmail: ...,
  // employeeId: null  ← FALTANDO
  // employeeName: null ← FALTANDO
  action: 'CREATE_OS',
  ...
));

// CÓDIGO CORRIGIDO:
await _logRepository.addLog(LogModel(
  userId: ...,
  userEmail: ...,
  employeeId: _currentEmployeeId,    // ← PREENCHER
  employeeName: _currentEmployeeName, // ← PREENCHER
  action: 'CREATE_OS',
  ...
));
```

---

### 3.2 Problema #2: Duplicação de Dados de Funcionários

**O que acontece:**
- Cada funcionário criado é salvo em DOIS lugares no Firestore:
  1. `users/{userId}/` (via AuthService.registerEmployee)
  2. `employees/{employeeId}/` (via AuthService.registerEmployee)

**Problemas causados:**
- Dados duplicados
- Se um for atualizado, o outro fica desatualizado
- Dificulta manutenção e consultas
- Possível inconsistência de dados

---

### 3.3 Problema #3: Funcionários em OS São Apenas Nomes

**O que acontece:**
- O modelo OS armazena `List<String> funcionarios` - apenas nomes
- Não há referência aos IDs dos funcionários
- Não é possível vincular a um EmployeeModel específico

**Consequências:**
- Não é possível saber quais funcionários (por ID) estavam na OS
- Se um funcionário for deletado, continua aparecendo nas OS antigas
- Auditoria comprometida

---

## 4. 📁 ESTRUTURA DE ARQUIVOS

### 4.1 Arquivos Principais

| Arquivo | Função | Linhas | Status |
|---------|--------|--------|--------|
| `lib/main.dart` | Entry point, Firebase init | ~25 | OK |
| `lib/app.dart` | Configuração do app, Provider | ~30 | OK |
| `lib/core/routes/app_router.dart` | Rotas | ~80 | OK |
| `lib/data/models/os_model.dart` | Modelo OS | ~180 | ⚠️ Incompleto |
| `lib/data/models/diario_model.dart` | Modelo Diário | ~160 | ⚠️ Incompleto |
| `lib/data/models/employee/employee_model.dart` | Modelo Employee | ~90 | OK |
| `lib/data/models/log_model.dart` | Modelo Log | ~60 | ⚠️ Campos não usados |
| `lib/data/repositories/os_repository.dart` | Repository OS | ~90 | OK |
| `lib/data/repositories/diario_repository.dart` | Repository Diário | ~130 | OK |
| `lib/data/repositories/employee_repository.dart` | Repository Employee | ~70 | ⚠️ Duplicação |
| `lib/data/repositories/log_repository.dart` | Repository Log | ~60 | ⚠️ Não populado |
| `lib/services/firebase/auth_service.dart` | Autenticação | ~90 | ⚠️ Duplica dados |
| `lib/presentation/pages/novaos_page.dart` | Criar/Editar OS | ~500 | ⚠️ Falta employeeId |
| `lib/presentation/pages/detalhes_os_page.dart` | Ver OS | ~150 | ⚠️ Falta employeeId |
| `lib/presentation/pages/employee_management/employee_management_page.dart` | Gerenciar | ~120 | OK |
| `lib/presentation/pages/employee_management/employee_registration_page.dart` | Registro | ~300 | ⚠️ Duplicado |
| `lib/presentation/pages/register/register_page.dart` | Cadastro | ~120 | OK |
| `lib/utils/gerarpdf.dart` | PDF | ~700 | OK |

---

## 5. 🔧 COMPONENTES CHAVE

### 5.1 Modelos de Dados

**EmployeeModel** (`lib/data/models/employee/employee_model.dart`)
- Herda de EmployeeEntity
- Integração com Firestore
- Campos: id, name, email, role, phone, cpf, isActive, createdAt, updatedAt

**OsModel** (`lib/data/models/os_model.dart`)
- Campos principais: numeroOs, nomeCliente, servico, relatoCliente
- Lista funcionários apenas por nomes (PROBLEMA)
- Suporte a KM, horários, imagens, assinatura

**DiarioModel** (`lib/data/models/diario_model.dart`)
- Similar a OsModel
- Vinculado a uma OS via osId
- Numeração automática (1.1, 1.2, etc.)

**LogModel** (`lib/data/models/log_model.dart`)
- Para auditoria
- Campos employeeId e employeeName existem mas não são usados

### 5.2 Repositórios

| Repositório | Responsabilidade | Métodos Principais |
|-------------|------------------|-------------------|
| OsRepository | Gerenciar OS | addOs, updateOs, getOs, deleteOs, getOsPaginated, calcularAtualizarTotalKm |
| DiarioRepository | Gerenciar Diários | addDiario, updateDiario, deleteDiario, getDiarios, getDiariosPaginated |
| EmployeeRepository | Gerenciar Funcionários | getEmployeesStream, getEmployeesList, addEmployee, updateEmployee, deleteEmployee |
| LogRepository | Gerenciar Logs | addLog, getLogs, getLogsByOs, getLogsByUser |

### 5.3 Serviços

**AuthService** (`lib/services/firebase/auth_service.dart`)
- signInWithEmailAndPassword
- createUserWithEmailAndPassword (para admin)
- registerEmployee (para funcionários - CRIA DUAS COLEÇÕES)
- getUserRole
- signOut

---

## 6. 📌 ITENS DE AÇÃO

### Prioridade Alta (Corrigir Imediatamente)

| # | Item | Arquivo | Tipo | Esforço |
|---|------|---------|------|---------|
| 1 | Implementar contexto de funcionário atual | Novo arquivo | Novo | Médio |
| 2 | Popular employeeId/employeeName nos logs | novaos_page.dart, detalhes_os_page.dart | Bug fix | Baixo |
| 3 | Corrigir duplicação de coleções | auth_service.dart | Refatoração | Alto |

### Prioridade Média (Corrigir em Breve)

| # | Item | Arquivo | Tipo | Esforço |
|---|------|---------|------|---------|
| 4 | Adicionar campo funcionariosIds aos modelos | os_model.dart, diario_model.dart | Melhoria | Médio |
| 5 | Padronizar validações nos modelos | models/*.dart | Melhoria | Baixo |
| 6 | Criar regras de segurança Firestore | firestore.rules | Segurança | Médio |

### Prioridade Baixa (Melhorias Futuras)

| # | Item | Arquivo | Tipo | Esforço |
|---|------|---------|------|---------|
| 7 | Adicionar índices Firestore | firestore.indexes.json | Performance | Baixo |
| 8 | Padronizar estrutura de pastas | pasta data/models | Refatoração | Baixo |
| 9 | Melhorar tratamento de erros | repositories/* | Melhoria | Baixo |

---

## 7. 📋 CHECKLIST DE AUDITORIA

Use esta lista para verificar o estado atual do sistema:

### Autenticação e Usuários
- [ ] Usuários podem se registrar corretamente
- [ ] Login funciona com Firebase Auth
- [ ] Roles (admin/employee) estão sendo definidas
- [ ] Funcionários são criados com autenticação

### Ordens de Serviço (OS)
- [ ] Criar nova OS funciona
- [ ] Editar OS funciona
- [ ] Excluir OS funciona
- [ ] Validação de número OS único funciona
- [ ] Imagens são salvas corretamente
- [ ] Assinatura digital funciona

### Diários
- [ ] Criar diário vinculado a OS
- [ ] Numeração automática funciona
- [ ] KM é calculado corretamente

### Funcionários
- [ ] Cadastro de funcionários funciona
- [ ] Listagem em tempo real funciona
- [ ] Soft delete (desativar) funciona
- [ ] Edição de funcionários funciona

### Auditoria
- [ ] Logs são criados em todas as operações
- [ ] employeeId está sendo populado nos logs
- [ ] employeeName está sendo populado nos logs

### Relatórios
- [ ] Geração de PDF funciona
- [ ] PDF inclui dados da OS corretamente
- [ ] PDF inclui diários corretamente
- [ ] Imagens aparecem no PDF

---

## 8. 💡 RECOMENDAÇÕES GERAIS

1. **Implementar EmployeeContext**: Crie um Provider para gerenciar o funcionário atual após o login.

2. **Unificar Coleção de Funcionários**: Escolha uma coleção principal (`employees`) e remova a duplicação.

3. **Adicionar Validações**: Implemente validações nos modelos antes de salvar no banco.

4. **Melhorar Logging**: Use o AppLogger existente em vez de print() para erros.

5. **Criar Testes**: Implemente testes unitários para as lógicas de negócio mais críticas.

---

**Documento de Referência para Auditoria - Versão 1.0**
**Data de Criação:** Fevereiro 2026

