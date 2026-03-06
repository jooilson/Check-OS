# Mapa de Telas Flutter - CheckOS

## Visão Geral

Este documento lista todas as telas (pages) do projeto CheckOS, com suas responsabilidades, componentes e dados consumidos.

---

## 1. TELAS DE AUTENTICAÇÃO

### 1.1 AuthWrapper

**Arquivo**: `lib/presentation/pages/auth/auth_wrapper.dart`

**Responsabilidade**: 
- Verificar estado de autenticação
- Redirecionar para página correta (login, cadastro empresa ou home)
- Escutar stream de autenticação do Firebase

**Componentes utilizados**:
- StreamBuilder (Firebase Auth)
- Navigator

**Dados que consome**:
- AuthService.authStateChanges
- EmployeeRepository (buscar employee por UID)
- CompanyRepository (verificar se tem empresa)

**Fluxo**:
```
Usuário logado + tem empresa → HomePage
Usuário logado + sem empresa → CadastroEmpresaPage
Usuário não logado → AuthPage (Login)
```

---

### 1.2 AuthPage (Página de Login)

**Arquivo**: `lib/presentation/pages/auth/auth_page.dart`

**Responsabilidade**: 
- Interface de login por email/senha
- Link para registro de novo usuário
- Link para recuperação de senha

**Componentes utilizados**:
- TextFormField (email)
- TextFormField (senha)
- ElevatedButton (entrar)
- TextButton (cadastrar, esqueci senha)
- Form (validação)

**Dados que consome**:
- AuthService.signInWithEmailAndPassword()

---

### 1.3 RegisterPage (Página de Registro)

**Arquivo**: `lib/presentation/pages/register/register_page.dart`

**Responsabilidade**: 
- Criar nova conta + empresa
- Primeiro acesso do sistema

**Componentes utilizados**:
- TextFormField (nome)
- TextFormField (email)
- TextFormField (senha)
- TextFormField (confirmar senha)
- TextFormField (nome empresa)
- TextFormField (CNPJ) - opcional
- ElevatedButton (cadastrar)

**Dados que consome**:
- AuthService.createAccountWithCompany()

---

## 2. TELAS PRINCIPAIS

### 2.1 HomePage

**Arquivo**: `lib/presentation/pages/home/home_page.dart`

**Responsabilidade**: 
- Dashboard principal
- Menu de navegação
- Estatísticas rápidas
- Acesso rápido às功能 principais

**Componentes utilizados**:
- AppBar
- Drawer (menu lateral)
- Card (estatísticas)
- FloatingActionButton (nova OS)
- BottomNavigationBar (navegação inferior)

**Dados que consome**:
- EmployeeContext (dados do funcionário)
- OsRepository (contagem de OS)
- CompanyRepository (dados da empresa)

**Navegação para**:
- ListaPage (ver OS)
- NovaOsPage (criar OS)
- EmployeeManagementPage (gerenciar funcionários)
- ConfigPage (configurações)
- LogsPage (visualizar logs)

---

### 2.2 CadastroEmpresaPage

**Arquivo**: `lib/presentation/pages/cadastro_empresa/cadastro_empresa_page.dart`

**Responsabilidade**: 
- Completar cadastro da empresa (onboarding)
- Usuário já autenticado mas sem empresa

**Componentes utilizados**:
- TextFormField (nome empresa)
- TextFormField (CNPJ)
- TextFormField (telefone)
- TextFormField (endereço)
- ElevatedButton (cadastrar)

**Dados que consome**:
- AuthService (atualizar empresa do usuário)
- CompanyRepository.createCompany()

---

## 3. TELAS DE OS (ORDENS DE SERVIÇO)

### 3.1 ListaPage

**Arquivo**: `lib/presentation/pages/lista_page.dart`

**Responsabilidade**: 
- Listar todas as OS da empresa
- Busca e filtragem
- Ordenação

**Componentes utilizados**:
- ListView.builder
- Card (item de OS)
- SearchBar (busca)
- Dropdown (filtro status)
- FloatingActionButton

**Dados que consome**:
- OsRepository.getOsList()
- OsRepository.getOs() (stream)

**Navegação para**:
- DetalhesOsPage (ao clicar em OS)
- NovaOsPage (botão adicionar)

---

### 3.2 NovaOsPage

**Arquivo**: `lib/presentation/pages/novaos_page.dart`

**Responsabilidade**: 
- Criar nova Ordem de Serviço
- Editar OS existente (quando passado como argumento)

**Componentes utilizados**:
- Form
- TextFormField (vários campos)
- DateTimePicker (data)
- Autocomplete (funcionários)
- TextField (assinatura)
- ImagePicker (fotos)
- DropdownButton (status)

**Campos do formulário**:
- Número OS (auto)
- Nome Cliente
- Serviço
- Relato do Cliente
- Responsável
- Tem pedido? (checkbox)
- Número do pedido
- Funcionários (multi-select)
- KM Inicial
- KM Final
- Hora Início
- Intervalo
- Hora Término
- Garantia (checkbox)
- Pendente (checkbox)
- Descrição pendente
- Relatório Técnico
- Assinatura (digital)
- Imagens

**Dados que consome**:
- OsRepository.addOs()
- OsRepository.updateOs()
- EmployeeRepository.getActiveEmployeesList()
- EmployeeContext (para auditoria)

---

### 3.3 DetalhesOsPage

**Arquivo**: `lib/presentation/pages/detalhes_os_page.dart`

**Responsabilidade**: 
- Visualizar detalhes de uma OS
- Ações sobre a OS (editar, finalizar, excluir)
- Gerar PDF
- Criar diário vinculado

**Componentes utilizados**:
- AppBar (ações)
- Card (informações)
- Image (imagens)
- ButtonBar (ações)
- Dialog (confirmação)

**Dados que consome**:
- OsModel (recebido como argumento)
- OsRepository.updateOs()
- DiarioRepository.getDiarios()

**Navegação para**:
- NovaOsPage (editar)
- NovoDiarioPage (criar diário)
- ListaPage (voltar)

---

## 4. TELAS DE DIÁRIOS

### 4.1 NovoDiarioPage

**Arquivo**: `lib/presentation/pages/novo_diario_page.dart`

**Responsabilidade**: 
- Criar novo diário de bordo
- Vinculado a uma OS existente

**Componentes utilizados**:
- Form
- TextFormField
- DatePicker
- ImagePicker
- DropdownButton

**Dados que consome**:
- DiarioRepository.addDiario()
- OsModel (recebido como argumento)

---

### 4.2 EditarDiarioPage

**Arquivo**: `lib/presentation/pages/editar_diario_page.dart`

**Responsabilidade**: 
- Editar diário existente

**Componentes utilizados**:
- Form
- TextFormField
- DatePicker

**Dados que consome**:
- DiarioModel (recebido como argumento)
- DiarioRepository.updateDiario()

---

## 5. TELAS DE FUNCIONÁRIOS

### 5.1 EmployeeManagementPage

**Arquivo**: `lib/presentation/pages/employee_management/employee_management_page.dart`

**Responsabilidade**: 
- Listar todos os funcionários da empresa
- Gerenciar funcionários (ativar/desativar)

**Componentes utilizados**:
- ListView.builder
- Card (funcionário)
- Switch (ativar/desativar)
- FloatingActionButton

**Dados que consome**:
- EmployeeRepository.getEmployeesList()
- EmployeeRepository.updateEmployee()

**Navegação para**:
- EmployeeAddPage (adicionar)

---

### 5.2 EmployeeAddPage

**Arquivo**: `lib/presentation/pages/employee_management/employee_add_page.dart`

**Responsabilidade**: 
- Adicionar novo funcionário
- Editar funcionário existente

**Componentes utilizados**:
- Form
- TextFormField (nome, email, telefone, CPF)
- DropdownButton (role)
- ElevatedButton

**Dados que consome**:
- EmployeeRepository.addEmployee()
- EmployeeRepository.updateEmployee()
- AuthService.registerEmployee()

---

## 6. TELAS DE CONFIGURAÇÃO

### 6.1 ConfigPage

**Arquivo**: `lib/presentation/pages/config_page.dart`

**Responsabilidade**: 
- Configurações gerais do app
- Mudar tema (light/dark)
- Dados da empresa
- logout

**Componentes utilizados**:
- ListTile
- Switch (tema)
- Card (empresa)
- Dialog

**Dados que consome**:
- ThemeProvider
- CompanyRepository
- AuthService.signOut()

---

### 6.2 ImportExportPage

**Arquivo**: `lib/presentation/pages/import_export_page.dart`

**Responsabilidade**: 
- Importar dados (CSV)
- Exportar dados (CSV/PDF)

**Componentes utilizados**:
- FilePicker
- ElevatedButton
- ProgressIndicator

**Dados que consome**:
- ImportExportService

---

### 6.3 LogsPage

**Arquivo**: `lib/presentation/pages/logs_page.dart`

**Responsabilidade**: 
- Visualizar logs de auditoria
- Histórico de ações

**Componentes utilizados**:
- ListView.builder
- Card (log)

**Dados que consome**:
- LogRepository.getLogs()

---

## 7. TELAS ADICIONAIS

### 7.1 LoginPage (Alternativo)

**Arquivo**: `lib/presentation/pages/login/login_page.dart`

**Responsabilidade**: 
- Página de login alternativa
- Parece ser duplicata de AuthPage

**Nota**: Verificar se é realmente necessária ou pode ser removida

---

## 8. RESUMO DE NAVEGAÇÃO

```
AuthWrapper
    │
    ├── AuthPage (não logado)
    │       └── RegisterPage
    │
    └── HomePage (logado)
            │
            ├── ListaPage
            │       ├── NovaOsPage
            │       └── DetalhesOsPage
            │               ├── NovoDiarioPage
            │               └── EditarDiarioPage
            │
            ├── CadastroEmpresaPage (se não tem empresa)
            │
            ├── EmployeeManagementPage
            │       └── EmployeeAddPage
            │
            ├── ConfigPage
            │       ├── ImportExportPage
            │       └── LogsPage
            │
            └── (logout) → AuthPage
```

---

## 9. COMPONENTES REUTILIZÁVEIS

### 9.1 Widgets de Formulário

| Widget | Arquivo | Função |
|--------|---------|--------|
| DiarioFormWidget | diario_form_widget.dart | Formulário de diário |
| DiarioListWidget | diario_list_widget.dart | Lista de diários |
| FuncionarioAutocompleteField | funcionario_autocomplete_field.dart | Selecionar funcionário |
| OsFormSections | os_form_sections.dart | Seções do formulário OS |

### 9.2 Campos do Formulário OS

O formulário de OS está dividido em seções:
- **Dados do Cliente**: nome, serviço, relato
- **Pedido**: tem pedido, número
- **Equipe**: responsáveis, funcionários
- **KM e Tempo**: km inicial/final, hora início/fim
- **Status**: finalizado, garantia, pendente
- **Relatório**: técnico, assinatura
- **Imagens**: upload de fotos

---

## 10. DADOS PASSADOS ENTRE TELAS

### 10.1 Via Navigator

```dart
// Enviar dados
Navigator.pushNamed(
  context,
  AppRouteNames.detalhesOs,
  arguments: osModel,
);

// Receber dados
final os = settings.arguments as OsModel;
```

### 10.2 Via Provider

```dart
// Fornecer dados
Provider.of<EmployeeContext>(context).setEmployee(employee);

// Acessar dados
final employee = context.watch<EmployeeContext>().currentEmployee;
```

---

## 11. PONTOS CRÍTICOS

### 11.1 Dados Nuslos

- `osParaEditar` pode ser null em NovaOsPage
- `employee` pode ser null em EmployeeAddPage

### 11.2 Duplicação de Telas

- AuthPage e LoginPage parecem fazer a mesma coisa
- Verificar necessidade de manter ambas

### 11.3 Navegação

- Não há guarda de rotas (route guard)
- Qualquer tela pode ser acessada diretamente via URL
- Recomendado implementar autenticação em nível de rota

