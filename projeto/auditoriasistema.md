# 📋 AUDITORIA TÉCNICA COMPLETA DO SISTEMA CHECKOS

**Documento de Referência Técnica para IA e Desenvolvedores**

---

## 1. VISÃO GERAL DO SISTEMA

### 1.1 Nome do Projeto
**CheckOS** - Sistema de Gerenciamento de Ordens de Serviço

### 1.2 Objetivo Principal
O CheckOS é um sistema completo para gestão de Ordens de Serviço (OS) destinado a empresas de manutenção, serviços técnicos e obras. O sistema permite:
- Criação e gerenciamento de Ordens de Serviço
- Acompanhamento diário de atendimentos através de diários de obra
- Geração de relatórios em PDF para impressão e envio a clientes
- Gestão de funcionários com autenticação individual
- Controle de quilometragem e horários de trabalho
- Sistema de auditoria para rastrear todas as operações
- Upload de imagens e captura de assinaturas digitais

### 1.3 Público-Alvo
- Empresas de manutenção predial e industrial
- Empresas de serviços técnicos e manutenção de equipamentos
- Construtoras e empreiteiras que precisam controlar OS de obras/serviços
- Profissionais autônomos que precisam documentar atendimentos

### 1.4 Plataforma
- **Plataforma Principal:** Android (Flutter)
- **Plataformas Secundárias:** iOS, Web/PWA (compilação Flutter para Web)
- **Arquitetura:** Cross-platform através do Flutter SDK

### 1.5 Stack Tecnológica

#### Framework e Linguagem
```
Flutter SDK: ^3.10.1
Dart: ^3.10.x
```

#### Firebase (Backend como Serviço)
```
firebase_core: ^4.4.0        # Inicialização do Firebase
firebase_auth: ^6.1.4       # Autenticação de usuários
cloud_firestore: ^6.1.2     # Banco de dados NoSQL
firebase_storage: ^13.0.6   # Armazenamento de imagens/arquivos
firebase_app_check: ^0.4.1+4 # Segurança adicional (desabilitado em dev)
```

#### State Management
```
provider: ^6.1.5+1          # Gerenciamento de estado (ChangeNotifierProvider)
```

#### Dependências de Funcionalidade
```
image_picker: ^1.2.1        # Captura de fotos da câmera/galeria
signature: ^6.3.0           # Widget de captura de assinaturas digitais
uuid: ^4.4.2                # Geração de IDs únicos
intl: ^0.20.2               # Formatação de datas e números
pdf: ^3.11.3                # Criação de documentos PDF
printing: ^5.11.0           # Visualização e impressão de PDFs
image: ^4.0.15              # Processamento e compressão de imagens
share_plus: ^12.0.1         # Compartilhamento de arquivos
file_picker: ^8.3.7         # Seleção de arquivos do dispositivo
path_provider: ^2.1.4       # Acesso a diretórios do sistema
permission_handler: ^12.0.1 # Gerenciamento de permissões
shared_preferences: ^2.3.2  # Armazenamento local simples
get_it: ^9.2.0              # Injeção de dependências
equatable: ^2.0.5          # Comparação de objetos
```

---

## 2. ARQUITETURA

### 2.1 Estrutura de Pastas Detalhada

```
lib/
├── main.dart                    # Ponto de entrada da aplicação
├── app.dart                     # Configuração principal do app (providers, temas)
├── routes.dart                  # Definição de rotas (legacy)
│
├── core/                        # Configurações centrais e utilitários
│   ├── constants/               # Constantes da aplicação
│   │   ├── app_colors.dart      # Cores do tema
│   │   ├── app_route_names.dart # Nomes das rotas
│   │   ├── app_strings.dart     # Strings gerais
│   │   ├── dialog_strings.dart  # Textos de diálogos
│   │   ├── error_strings.dart   # Mensagens de erro
│   │   ├── login_strings.dart    # Textos de login
│   │   └── os_strings.dart      # Textos específicos de OS
│   │
│   ├── context/                 # Contextos globais
│   │   └── employee_context.dart # Contexto do funcionário logado
│   │
│   ├── routes/                  # Gerenciamento de rotas
│   │   └── app_router.dart      # Router principal (MaterialApp)
│   │
│   ├── theme/                   # Configurações de tema
│   │   └── app_theme.dart       # Definição de temas (claro/escuro)
│   │
│   └── utils/                   # Utilitários centrais
│       └── logger.dart          # Sistema de logging
│
├── data/                        # Camada de dados
│   ├── datasources/             # Fontes de dados
│   │   ├── local/               # Dados locais (futuro)
│   │   └── remote/              # Dados remotos (Firebase)
│   │
│   ├── models/                  # Modelos de dados
│   │   ├── os_model.dart        # Modelo de Ordem de Serviço
│   │   ├── os_model_bkp.dart    # Backup do modelo OS
│   │   ├── diario_model.dart    # Modelo de Diário de Obra
│   │   ├── log_model.dart       # Modelo de Log/Auditoria
│   │   │
│   │   ├── account/             # Modelos de conta (reservado)
│   │   ├── company/              # Modelo de Empresa
│   │   │   └── company_model.dart
│   │   ├── employee/            # Modelo de Funcionário
│   │   │   └── employee_model.dart
│   │   ├── plan/                 # Modelos de planos (reservado)
│   │   └── user/                 # Modelo de Usuário
│   │       └── user_model.dart
│   │
│   └── repositories/             # Repositórios de acesso a dados
│       ├── os_repository.dart    # Operações com OS
│       ├── diario_repository.dart # Operações com Diários
│       ├── employee_repository.dart # Operações com Funcionários
│       ├── company_repository.dart  # Operações com Empresas
│       ├── log_repository.dart    # Operações com Logs
│       ├── account/              # Repositórios de conta
│       ├── plan/                 # Repositórios de planos
│       └── user/                 # Repositórios de usuário
│
├── di/                          # Injeção de dependências (reservado)
│
├── domain/                      # Camada de domínio
│   ├── entities/                # Entidades do domínio
│   │   ├── account/             # Entidades de conta
│   │   ├── company/             # Entidade de Empresa
│   │   │   └── company_entity.dart
│   │   ├── employee/            # Entidade de Funcionário
│   │   │   └── employee_entity.dart
│   │   ├── plan/                # Entidades de plano
│   │   └── user/                # Entidade de Usuário
│   │       └── user_entity.dart
│   │
│   ├── repositories/            # Interfaces de repositório
│   │   ├── account/
│   │   ├── plan/
│   │   └── user/
│   │       └── user_repository.dart
│   │
│   └── usecases/               # Casos de uso
│       ├── account/
│       ├── plan/
│       └── user/
│           └── get_user_details.dart
│
├── presentation/               # Camada de apresentação (UI)
│   ├── pages/                  # Páginas/screens
│   │   ├── auth/               # Páginas de autenticação
│   │   │   ├── auth_page.dart
│   │   │   └── auth_wrapper.dart
│   │   │
│   │   ├── home/               # Página inicial
│   │   │   └── home_page.dart
│   │   │
│   │   ├── login/              # Páginas de login
│   │   │   ├── login_page.dart
│   │   │   └── employee_login_page.dart
│   │   │
│   │   ├── register/           # Página de registro
│   │   │   └── register_page.dart
│   │   │
│   │   ├── lista/              # Lista de OS
│   │   │   └── lista_page.dart
│   │   │
│   │   ├── novaos_page.dart    # Criação/edição de OS
│   │   ├── detalhes_os_page.dart # Detalhes da OS
│   │   ├── novo_diario_page.dart # Criação de diário
│   │   ├── editar_diario_page.dart # Edição de diário
│   │   ├── logs_page.dart      # Visualização de logs
│   │   ├── config_page.dart    # Configurações
│   │   ├── import_export_page.dart # Import/export
│   │   │
│   │   ├── employee_management/ # Gestão de funcionários
│   │   │   ├── employee_management_page.dart
│   │   │   ├── employee_registration_page.dart
│   │   │   └── employee_add_page.dart
│   │   │
│   │   ├── diario/             # Páginas de diário (reservado)
│   │   ├── invite/             # Páginas de convite (reservado)
│   │   └── os/                 # Páginas de OS (reservado)
│   │
│   └── widgets/                # Widgets reutilizáveis
│       ├── diario_form_widget.dart
│       ├── diario_list_widget.dart
│       ├── funcionario_autocomplete_field.dart
│       └── os_form_sections.dart
│
├── services/                   # Serviços de negócio
│   ├── firebase/               # Serviços Firebase
│   │   └── auth_service.dart   # Autenticação
│   │
│   ├── import_export_service.dart # Import/export de dados
│   ├── logo_service.dart       # Gerenciamento de logo da empresa
│   ├── employee_exemplos.dart  # Dados de exemplo (dev)
│   └── funcionarios_em_os_exemplos.dart # Dados de exemplo
│
├── pdf/                        # Módulos de PDF (reservado)
│
├── routes/                     # Definições de rotas
│   └── app_route.dart          # Configuração de rotas
│
├── theme/                      # Temas (link para core/theme)
│   └── theme_provider.dart     # Provider de tema
│
└── utils/                      # Utilitários
    ├── debouncer.dart          # Debouncer para buscas
    ├── formatters.dart         # Formatadores de data/texto
    └── gerarpdf.dart           # Geração de PDF (principal)
```

### 2.2 Padrão de Arquitetura Utilizado

O projeto utiliza uma **arquitetura híbrida** combinando elementos de:

1. **MVC (Model-View-Controller)** - Tradicional do Flutter
   - **Model:** Pasta `data/models/` e `domain/entities/`
   - **View:** Pasta `presentation/pages/` e `presentation/widgets/`
   - **Controller:** Lógica nos repositories e serviços

2. **Clean Architecture** - Implementada parcialmente
   - Separação clara em camadas: `data/`, `domain/`, `presentation/`
   - Entities no domínio (abstrações)
   - Models na camada de dados (implementações concretas)
   - Use cases reservados em `domain/usecases/`

3. **Repository Pattern**
   - Repositórios centralizam acesso a dados (`data/repositories/`)
   - Abstração sobre fonte de dados (Firestore)

### 2.3 Fluxo de Navegação entre Telas

```
┌─────────────────────────────────────────────────────────────────────┐
│                          FLUXO DE NAVEGAÇÃO                          │
└─────────────────────────────────────────────────────────────────────┘

                         ┌──────────────────┐
                         │   AuthWrapper    │
                         │  (Verifica Auth) │
                         └────────┬─────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │                           │
              ┌─────▼─────┐              ┌─────▼─────┐
              │  Login    │              │  Register │
              │  (Admin)  │              │ (Criar 1º)│
              └─────┬─────┘              └───────────┘
                    │
                    │ (Sucesso)
                    ▼
            ┌──────────────────┐
            │     HomePage     │
            │  (Menu Principal)│
            └────────┬─────────┘
                     │
    ┌────────────────┼────────────────┐
    │                │                │
┌───▼───┐    ┌──────▼──────┐   ┌─────▼──────┐
│ Lista │    │ Nova OS /   │   │  Employee  │
│  OS   │    │ Editar OS   │   │ Management │
└───┬───┘    └──────┬──────┘   └─────┬──────┘
    │               │                │
    │          ┌────▼─────┐     ┌────▼─────┐
    │          │ Detalhes │     │ Add/Edit │
    │          │    OS     │     │Employee  │
    │          └────┬─────┘     └──────────┘
    │               │
    │     ┌─────────┼─────────┐
    │     │         │         │
┌────▼────▼┐  ┌────▼────┐  ┌─▼──────┐
│Novo Diário│  │  Logs   │  │  PDF   │
└──────────┘  └─────────┘  └────────┘
```

### 2.4 Organização de Estados

O sistema utiliza **Provider** como solução de state management:

#### Providers Configurados (app.dart)
```dart
MultiProvider(
  providers: [
    // 1. ThemeProvider - Gerenciamento de tema (claro/escuro)
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    
    // 2. EmployeeContext - Funcionário atual logado
    // Usado para auditoria e rastreamento de ações
    ChangeNotifierProvider(create: (_) => EmployeeContext()),
  ],
)
```

#### Padrão de Uso
- **Pages que precisam de estado:** Usam `Consumer<Provider>` ou `context.watch<Provider>()`
- **Ações que modificam estado:** Usam `context.read<Provider>().metodo()`
- **Contexts não-widget:** Podem usar `Provider.of<Context>(context, listen: false)`

---

## 3. MODELOS DE DADOS

### 3.1 OSModel (Ordem de Serviço)

**Arquivo:** `lib/data/models/os_model.dart`

**Descrição:** Modelo principal que representa uma Ordem de Serviço completa.

**Campos:**

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|--------------|-----------|
| id | String | Sim | ID único do documento no Firestore |
| numeroOs | String | Sim | Número identificador da OS (ex: "OS-001") |
| nomeCliente | String | Sim | Nome do cliente solicitante |
| servico | String | Sim | Descrição do serviço a ser realizado |
| relatoCliente | String | Sim | Descrição do problema/solicitação pelo cliente |
| responsavel | String | Sim | Nome do responsável técnico pela OS |
| temPedido | bool | Não | Indica se há número de pedido do cliente |
| numeroPedido | String? | Não | Número do pedido (se temPedido = true) |
| funcionarios | List<String> | Não | Lista de nomes dos funcionários na OS |
| kmInicial | double? | Não | Quilometragem inicial do veículo |
| kmFinal | double? | Não | Quilometragem final do veículo |
| horaInicio | String? | Não | Hora de início do atendimento (HH:mm) |
| intervaloInicio | String? | Não | Hora de início do intervalo |
| intervaloFim | String? | Não | Hora de fim do intervalo |
| horaTermino | String? | Não | Hora de término do atendimento |
| osfinalizado | bool | Não | Indica se a OS está finalizada |
| garantia | bool | Não | Indica se está em garantia |
| pendente | bool | Não | Indica se há pendência |
| pendenteDescricao | String? | Não | Descrição da pendência |
| relatoTecnico | String? | Não | Descrição técnica do que foi feito |
| assinatura | String? | Não | Assinatura do cliente (serializada) |
| imagens | List<String> | Não | Lista de caminhos URLs das imagens |
| totalKm | double? | Não | Total de KM (calculado: OS + diários) |
| companyId | String? | Não | ID da empresa (para multi-tenancy) |
| createdAt | DateTime? | Não | Data de criação |
| updatedAt | DateTime? | Não | Data de última atualização |

**Relações:**
- Relacionamento 1:N com `DiarioModel` (uma OS pode ter vários diários)
- Armazena apenas nomes de funcionários (não IDs) - **Ponto crítico**
- companyId vincula à empresa (multi-tenancy)

**Onde é utilizado:**
- `OsRepository` - Persistência no Firestore
- `NovaOsPage` - Criação e edição
- `DetalhesOsPage` - Visualização
- `ListaPage` - Listagem com filtros
- `GerarPdf` - Geração de relatórios PDF

---

### 3.2 DiarioModel (Diário de Obra)

**Arquivo:** `lib/data/models/diario_model.dart`

**Descrição:** Modelo que representa um dia de trabalho/atendimento vinculado a uma OS.

**Campos:**

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|--------------|-----------|
| id | String | Sim | ID único do documento no Firestore |
| osId | String | Sim | ID da OS pai (relacionamento) |
| numeroOs | String | Sim | Número da OS pai (para exibição) |
| numeroDiario | double | Sim | Número sequencial do diário (ex: 1.1, 1.2) |
| nomeCliente | String | Sim | Nome do cliente (copiado da OS) |
| servico | String? | Não | Serviço (copiado da OS) |
| relatoCliente | String? | Não | Novo relato do cliente neste dia |
| responsavel | String? | Não | Responsável técnico |
| funcionarios | List<String> | Não | Lista de nomes dos funcionários presentes |
| data | DateTime | Sim | Data do atendimento |
| kmInicial | double? | Não | KM inicial neste dia |
| kmFinal | double? | Não | KM final neste dia |
| horaInicio | String? | Não | Hora de início |
| intervaloInicio | String? | Não | Início do intervalo |
| intervaloFim | String? | Não | Fim do intervalo |
| horaTermino | String? | Não | Hora de término |
| osfinalizado | bool | Não | Status de finalização |
| garantia | bool | Não | Status de garantia |
| pendente | bool | Não | Status de pendência |
| pendenteDescricao | String? | Não | Descrição da pendência |
| relatoTecnico | String? | Não | Descrição técnica do atendimento |
| assinatura | String? | Não | Assinatura do atendimento |
| imagens | List<String> | Não | Imagens do dia |
| createdAt | DateTime | Sim | Data de criação |
| updatedAt | DateTime | Sim | Data de atualização |

**Relações:**
- Relacionamento N:1 com `OsModel` (muitos diários para uma OS)
- Campo `osId` referencia o documento pai
- `numeroDiario` é gerado automaticamente (formato: XX.Y)
- Mesma crítica do OSModel: armazena apenas nomes, não IDs

**Onde é utilizado:**
- `DiarioRepository` - Persistência
- `NovoDiarioPage` - Criação
- `EditarDiarioPage` - Edição
- `DetalhesOsPage` - Visualização dos diários da OS
- `GerarPdf` - Seção de histórico no PDF

---

### 3.3 EmployeeModel (Funcionário)

**Arquivo:** `lib/data/models/employee/employee_model.dart`

**Descrição:** Modelo que representa um funcionário da empresa.

**Campos:**

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|--------------|-----------|
| id | String | Sim | ID único (same as Firebase Auth UID) |
| name | String | Sim | Nome completo do funcionário |
| email | String | Sim | Email (usado para login) |
| role | String | Sim | Cargo: "admin" ou "employee" |
| phone | String | Sim | Telefone de contato |
| cpf | String? | Não | CPF (opcional) |
| companyId | String? | Não | ID da empresa (multi-tenancy) |
| isActive | bool | Não | Status de ativação (soft delete) |
| createdAt | DateTime | Sim | Data de criação |
| updatedAt | DateTime | Sim | Data de atualização |

**Relações:**
- companyId vincula à empresa
- ID é o mesmo do Firebase Auth (sincronizado)
- dual collection: `employees/` e `users/` (verificar criticidades)

**Onde é utilizado:**
- `EmployeeRepository` - Persistência
- `EmployeeManagementPage` - Gestão de funcionários
- `EmployeeAddPage` / `EmployeeRegistrationPage` - Cadastro
- `AuthService.registerEmployee()` - Criação de conta

---

### 3.4 CompanyModel (Empresa)

**Arquivo:** `lib/data/models/company/company_model.dart`

**Descrição:** Modelo que representa uma empresa/assinatura no sistema.

**Campos:**

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|--------------|-----------|
| id | String | Sim | ID único do documento |
| name | String | Sim | Nome da empresa |
| cnpj | String? | Não | CNPJ |
| phone | String? | Não | Telefone |
| address | String? | Não | Endereço |
| email | String? | Não | Email de contato |
| logoUrl | String? | Não | URL do logo (Firebase Storage) |
| plan | String? | Não | Plano: "free", "premium", etc |
| isActive | bool | Não | Status da assinatura |
| createdAt | DateTime | Sim | Data de criação |
| updatedAt | DateTime | Sim | Data de atualização |
| subscriptionExpiresAt | DateTime? | Não | Data de expiração da assinatura |

**Relações:**
- referenced by: `EmployeeModel.companyId`, `OsModel.companyId`
-created when: Admin registers for the first time

**Onde é utilizado:**
- `CompanyRepository` - Persistência
- `AuthService.createUserWithEmailAndPassword()` - Criação automática no registro
- Logo exibido nos PDFs

---

### 3.5 LogModel (Auditoria)

**Arquivo:** `lib/data/models/log_model.dart`

**Descrição:** Modelo para registro de auditoria de todas as operações.

**Campos:**

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|--------------|-----------|
| id | String | Sim | ID único do log |
| userId | String | Sim | ID do usuário Firebase Auth |
| userEmail | String | Sim | Email do usuário |
| userName | String? | Não | Nome do usuário (cache) |
| employeeId | String? | Não | ID do funcionário (se diferente do user) |
| employeeName | String? | Não | Nome do funcionário |
| timestamp | DateTime | Sim | Data/hora da ação |
| action | String | Sim | Tipo de ação (CREATE_OS, UPDATE_OS, etc) |
| osId | String | Sim | ID da OS afetada |
| osNumero | String | Sim | Número da OS afetada |
| description | String | Sim | Descrição da ação |

**Relações:**
- Registra operações sobre OS
- Pode registrar employeeId para rastreamento granular

**Onde é utilizado:**
- `LogRepository` - Persistência
- `LogsPage` - Visualização de histórico
- Operações de CRUD em OS e Diários

---

### 3.6 UserModel (Usuário)

**Arquivo:** `lib/data/models/user/user_model.dart`

**Descrição:** Modelo simplificado de usuário para autenticação.

**Campos:**

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|--------------|-----------|
| id | String | Sim | ID único (Firebase Auth UID) |
| email | String | Sim | Email do usuário |
| name | String? | Não | Nome do usuário |

**Relações:**
- Duplicado com `EmployeeModel` para compatibilidade
- Usado em consultas de role

**Onde é utilizado:**
- `AuthService.getUserRole()` - Fallback para buscar role
- Queries de autenticação

---

## 4. BANCO DE DADOS

### 4.1 Firestore (Banco de Dados Principal)

O sistema utiliza **Cloud Firestore** como banco de dados primário. Não há uso de SQLite local - todos os dados são armazenados diretamente no Firestore.

#### Estrutura de Coleções

```
Firestore Database:
│
├── users/{userId}              # Usuários (autenticação)
│   ├── email: string
│   ├── name: string
│   ├── role: string           # "admin" | "employee"
│   ├── companyId: string
│   ├── isActive: boolean
│   └── createdAt: timestamp
│
├── companies/{companyId}       # Empresas/Assinaturas
│   ├── name: string
│   ├── cnpj: string (optional)
│   ├── phone: string (optional)
│   ├── address: string (optional)
│   ├── email: string (optional)
│   ├── logoUrl: string (optional)
│   ├── plan: string           # "free" | "premium" | etc
│   ├── isActive: boolean
│   ├── createdAt: timestamp
│   ├── updatedAt: timestamp
│   └── subscriptionExpiresAt: timestamp (optional)
│
├── employees/{employeeId}      # Funcionários (PRINCIPAL)
│   ├── name: string
│   ├── email: string
│   ├── role: string           # "admin" | "employee"
│   ├── phone: string
│   ├── cpf: string (optional)
│   ├── companyId: string
│   ├── isActive: boolean
│   ├── createdAt: timestamp
│   └── updatedAt: timestamp
│
├── os/{osId}                   # Ordens de Serviço
│   ├── numeroOs: string
│   ├── nomeCliente: string
│   ├── servico: string
│   ├── relatoCliente: string
│   ├── responsavel: string
│   ├── temPedido: boolean
│   ├── numeroPedido: string (optional)
│   ├── funcionarios: array<string>
│   ├── kmInicial: double (optional)
│   ├── kmFinal: double (optional)
│   ├── horaInicio: string (optional)
│   ├── intervaloInicio: string (optional)
│   ├── intervaloFim: string (optional)
│   ├── horaTermino: string (optional)
│   ├── osfinalizado: boolean
│   ├── garantia: boolean
│   ├── pendente: boolean
│   ├── pendenteDescricao: string (optional)
│   ├── relatoTecnico: string (optional)
│   ├── assinatura: string (optional)  # Serializada
│   ├── imagens: array<string>
│   ├── totalKm: double (optional)
│   ├── companyId: string (optional)
│   ├── createdAt: timestamp (optional)
│   └── updatedAt: timestamp (optional)
│
├── diarios/{diarioId}          # Diários de Obra
│   ├── osId: string
│   ├── numeroOs: string
│   ├── numeroDiario: double
│   ├── nomeCliente: string
│   ├── servico: string (optional)
│   ├── relatoCliente: string (optional)
│   ├── responsavel: string (optional)
│   ├── funcionarios: array<string>
│   ├── data: timestamp
│   ├── kmInicial: double (optional)
│   ├── kmFinal: double (optional)
│   ├── horaInicio: string (optional)
│   ├── intervaloInicio: string (optional)
│   ├── intervaloFim: string (optional)
│   ├── horaTermino: string (optional)
│   ├── osfinalizado: boolean
│   ├── garantia: boolean
│   ├── pendente: boolean
│   ├── pendenteDescricao: string (optional)
│   ├── relatoTecnico: string (optional)
│   ├── assinatura: string (optional)
│   ├── imagens: array<string>
│   ├── createdAt: timestamp
│   └── updatedAt: timestamp
│
└── logs/{logId}                # Logs de Auditoria
    ├── userId: string
    ├── userEmail: string
    ├── userName: string (optional)
    ├── employeeId: string (optional)
    ├── employeeName: string (optional)
    ├── timestamp: timestamp
    ├── action: string
    ├── osId: string
    ├── osNumero: string
    └── description: string
```

### 4.2 Índices do Firestore

**Arquivo:** `firestore.indexes.json`

```json
{
  "indexes": [
    {
      "collectionGroup": "diarios",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "osId", "order": "ASCENDING" },
        { "fieldPath": "data", "order": "DESCENDING" },
        { "fieldPath": "__name__", "order": "DESCENDING" }
      ]
    }
  ]
}
```

**Índices necessários (não implementados):**
- `os` por `updatedAt` (descending) - para ordenação padrão
- `os` por `companyId` + `updatedAt` - para multi-tenancy
- `employees` por `companyId` + `name` - para listagem por empresa
- `logs` por `osId` + `timestamp` - para histórico de OS

### 4.3 Fluxo de Persistência

```
┌─────────────────────────────────────────────────────────────────┐
│                    FLUXO DE PERSISTÊNCIA                        │
└─────────────────────────────────────────────────────────────────┘

┌──────────────┐      ┌─────────────────┐      ┌─────────────┐
│   UI/Page    │ ───► │   Repository    │ ───► │  Firestore  │
│  (Widget)    │      │  (Data Layer)   │      │  (Cloud)    │
└──────────────┘      └─────────────────┘      └─────────────┘
       │                      │                       │
       │ User Action          │ addOs()               │
       │                      │ updateOs()            │
       │                      │ getOs()               │
       │                      │ deleteOs()            │
       ▼                      ▼                       ▼
┌──────────────┐      ┌─────────────────┐      ┌─────────────┐
│  Provider    │ ◄─── │   OsModel       │ ◄─── │ Collection  │
│  (State)     │      │  (Data Model)   │      │  (Table)    │
└──────────────┘      └─────────────────┘      └─────────────┘

Fluxo Típico de Create:
1. Page captura dados do formulário
2. Page cria OsModel com dados
3. Page chama repository.addOs(os)
4. Repository faz firestore.collection('os').add(os.toMap())
5. Firestore retorna DocumentReference com ID
6. Repository retorna ID para Page
7. Page atualiza estado (se necessário)

Fluxo Típico de Read:
1. Page chama repository.getOsList()
2. Repository faz firestore.collection('os').get()
3. Repository converte Map → OsModel para cada documento
4. Repository retorna List<OsModel> para Page
5. Page atualiza Provider com novos dados
```

---

## 5. FUNCIONALIDADES IMPLEMENTADAS

### 5.1 Criação de OS

**Descrição:** O sistema permite criar novas Ordens de Serviço com todos os dados necessários.

**Campos do formulário:**
- Número da OS (gerado automaticamente ou manual)
- Nome do cliente
- Serviço a ser realizado
- Relato do cliente (problema/solicitação)
- Responsável técnico
- Número do pedido (opcional)
- Funcionários participantes (autocomplete)
- Quilometragem inicial
- Horários (início, intervalo, término)

**Fluxo:**
1. Usuário acessa "Nova OS" na HomePage
2. Preenche o formulário
3. Ao salvar, sistema cria documento no Firestore
4. Sistema gera log de auditoria
5. Usuário é redirecionado para detalhes da OS

**Arquivos envolvidos:**
- `lib/presentation/pages/novaos_page.dart`
- `lib/data/repositories/os_repository.dart`
- `lib/data/models/os_model.dart`

---

### 5.2 Diário de Obra

**Descrição:** Sistema de acompanhamento diário de cada OS. Cada diária gera um "diário" com relatório do que foi feito naquele dia.

**Funcionalidades:**
- Criar diário vinculado a uma OS existente
- Registrar atividades realizadas (relato técnico)
- Registrar KM do dia
- Registrar horários de trabalho
- Adicionar imagens do dia
- Capturar assinatura do atendimento
- Listar todos os diários de uma OS

**Numeração:**
- O número do diário é gerado automaticamente: `numeroOsInteiro.sequencial`
- Exemplo: OS-001 tem diários #1.1, #1.2, #1.3

**Arquivos envolvidos:**
- `lib/presentation/pages/novo_diario_page.dart`
- `lib/presentation/pages/editar_diario_page.dart`
- `lib/data/repositories/diario_repository.dart`
- `lib/data/models/diario_model.dart`

---

### 5.3 Assinatura Digital

**Descrição:** O sistema permite capturar a assinatura do cliente em cada OS e diário.

**Funcionamento:**
- Usa o pacote `signature` para criar área de desenho
- A assinatura é serializada como string de coordenadas: `"x1,y1;x2,y2;null;x3,y3"`
- null representa "levantamento da caneta" (quebra na linha)
- A assinatura é armazenada no campo `assinatura` do modelo

**Processamento no PDF:**
- `GerarPdf._deserializeSignature()`: Converte string em lista de Offset
- `GerarPdf._generateSignatureImage()`: Desenha em canvas e exporta para PNG

**Arquivos envolvidos:**
- `lib/utils/gerarpdf.dart` (métodos privados de assinatura)

---

### 5.4 Geração de PDF

**Descrição:** Sistema completo de geração de relatórios PDF para impressão e compartilhamento.

**Estrutura do PDF gerado:**
1. **Cabeçalho** (todas as páginas): Logo da empresa, título "Ordem de Serviço", número da OS
2. **Dados Gerais**: Cliente, serviço, responsável, KM, horários, equipe
3. **Relatos**: Relato do cliente e relato técnico inicial
4. **Status**: Indicadores visuais (Finalizado, Garantia, Pendente)
5. **Assinatura do Cliente**: Imagem da assinatura (se disponível)
6. **Imagens da OS Principal**: Galeria de fotos
7. **Histórico de Atendimentos**: Cada diário com suas informações
8. **Imagens dos Diários**: Fotos de cada diário
9. **Relatório de KM**: Resumo e detalhamento de quilometragem
10. **Rodapé** (todas as páginas): Data de geração e paginação

**Arquivos envolvidos:**
- `lib/utils/gerarpdf.dart` (classe principal: `GerarPdf`)
- `lib/services/logo_service.dart` (logo da empresa)

---

### 5.5 Exportação de Dados

**Descrição:** Sistema de exportação de OS e dados para backup ou迁移.

**Formato:** JSON
- Exporta todas as OS com seus diários
- Inclui metadados (timestamps, etc)
- Não exporta imagens (apenas referências)

**Arquivos envolvidos:**
- `lib/services/import_export_service.dart`
- `lib/presentation/pages/import_export_page.dart`

---

### 5.6 Histórico e Logs

**Descrição:** Sistema de auditoria que registra todas as operações.

**Funcionalidades:**
- Visualizar todos os logs global
- Filtrar logs por OS específica
- Filtrar logs por usuário
- Filtrar logs por período (data)

**Ações registradas:**
- CREATE_OS
- UPDATE_OS
- DELETE_OS
- CREATE_DIARIO
- UPDATE_DIARIO
- DELETE_DIARIO

**Arquivos envolvidos:**
- `lib/data/repositories/log_repository.dart`
- `lib/presentation/pages/logs_page.dart`

---

### 5.7 Sistema de Filtros

**Descrição:** Funcionalidades de filtragem na lista de OS.

**Filtros disponíveis:**
- Por empresa (companyId) - automático via contexto
- Por status (finalizado, pendente, garantia)
- Por período (data)
- Por cliente (busca por nome)

**Arquivos envolvidos:**
- `lib/presentation/pages/lista_page.dart`

---

### 5.8 Upload para Google Drive / OneDrive

**Status:** Funcionalidade planejada/mencionada em documentação, mas implementação não encontrada nos arquivos analisados.

---

### 5.9 Login de Funcionários

**Descrição:** Sistema de autenticação individual para cada funcionário.

**Fluxo:**
1. Admin cadastra funcionário com email e senha
2. Sistema cria conta no Firebase Auth
3. Funcionário pode fazer login com suas credenciais
4. Sistema identifica role (admin/employee)

**Tipos de usuário:**
- **Admin**: Acesso total, pode gerenciar funcionários
- **Employee**: Acesso limitado às OS atribuídas

**Arquivos envolvidos:**
- `lib/services/firebase/auth_service.dart`
- `lib/presentation/pages/login/employee_login_page.dart`
- `lib/presentation/pages/employee_management/`

---

### 5.10 Sistema de Logs (Auditoria)

**Descrição:** Sistema completo de rastreamento de ações.

**Modelo de dados:** LogModel
- userId: Quem realizou a ação
- employeeId: Qual funcionário (se diferente)
- action: Tipo de ação
- osId/OSNumero: Qual OS foi afetada
- timestamp: Quando
- description: Detalhes

**Problema identificado:** EmployeeId e EmployeeName nem sempre são populados nos logs.

---

## 6. GERAÇÃO DE PDF

### 6.1 Biblioteca Utilizada

```
pdf: ^3.11.3          # Criação de documentos PDF
printing: ^5.11.0     # Visualização e impressão
image: ^4.0.15        # Processamento de imagens
```

### 6.2 Estrutura do PDF

O PDF é gerado usando `pw.Document()` com `pw.MultiPage()` que permite conteúdo fluindo entre páginas automaticamente.

**Cabeçalho (todas as páginas):**
- Logo da empresa (55x55pt)
- Título: "Ordem de Serviço"
- Subtítulo: "Relatório de Atendimento Técnico"
- Número da OS em destaque (box azul)

**Rodapé (todas as páginas):**
- Data de geração: "Gerado em: dd/MM/yyyy HH:mm"
- Paginação: "Página X de Y"

**Seções do conteúdo:**
- _buildOsInfoSection(): Dados gerais
- _buildReportsSection(): Relatos
- _buildStatusSection(): Status (chips coloridos)
- _buildSignatureSection(): Assinatura do cliente
- _buildDiarioItem(): Card de cada diário
- _buildKmReportSection(): Relatório de KM

### 6.3 Tratamento de Imagens

**Processo:**
1. Coleta caminhos de imagens (OS + diários)
2. Para cada imagem:
   - Se URL: baixa com http.get()
   - Se local: lê com File.readAsBytes()
3. Compressão:
   - Redimensiona se > 800px (maior lado)
   - Comprime para JPEG 60%
4. Exibe em galeria 130x130pt

**Código relevante:**
```dart
// Em gerarpdf.dart - _prepareImages()
const int maxDimension = 800;
const int jpegQuality = 60;
```

### 6.4 Compressão

**Estratégia de compressão:**
- Imagens maiores que 800px são redimensionadas
- Qualidade JPEG reduzida para 60%
- Imagens pequenas apenas comprimidas
- Formato final sempre JPEG

### 6.5 Pontos de Melhoria

| Ponto | Problema | Sugestão |
|-------|----------|----------|
| Performance | Processamento sequencial de imagens | Usar Future.wait() para paralelizar |
| Memória | Loading de todas imagens na memória | Streaming de imagens para PDF grande |
| Cache | Imagens baixadas a cada geração | Implementar cache local |
| Resolution | 800px pode ser baixo para impressão | Adicionar opção de qualidade alta |
| Timeout | Sem timeout em downloads HTTP | Adicionar timeout de 30s |

---

## 7. PONTOS CRÍTICOS DO SISTEMA

### 7.1 Problemas Conhecidos

| # | Problema | Severidade | Status |
|---|----------|------------|--------|
| 1 | EmployeeId não populado nos Logs | 🔴 Crítica | Pendente |
| 2 | Duplicação de coleções (employees/users) | 🟠 Alta | Documentado |
| 3 | OS armazena apenas nomes de funcionários | 🟠 Alta | Documentado |
| 4 | App Check desabilitado em produção | 🟡 Média | Configurado |
| 5 | Índices Firestore incompletos | 🟡 Média | Documentado |
| 6 | Sem regras de segurança Firestore | 🟡 Média | Pendente |

### 7.2 Gargalos de Performance

1. **Listas grandes**: Sem paginação na HomePage
   - Impacto: Lista com 100+ OS fica lenta
   - Solução: Implementar paginação infinita

2. **Imagens no Firestore**: URLs sem compressão
   - Impacto: Download lento de imagens
   - Solução: Comprimir antes de fazer upload

3. **Queries sem índice**: Ordenação sem índice
   - Impacto: Consultas lentas em produção
   - Solução: Criar índices necessários

### 7.3 Problemas de Renderização

| Problema | Causa | Solução |
|----------|-------|---------|
| Jank em listas | rebuild excessivo de widgets | Usar ListView.builder |
| Imagens lentas | Tamanho original | Comprimir e redimensionar |
| PDF travando | Muitas imagens | Paginar melhor, comprimir mais |

### 7.4 Problemas de Índice do Firestore

**Índices necessários não criados:**
- `os` ordenação por `updatedAt`
- `employees` filtragem por `companyId`
- `logs` filtragem por `osId` + ordenação

### 7.5 Problemas de Autenticação

- **App Check**: Desabilitado no código (comentado)
- **Motivo**: "Too many attempts" impede uploads
- **Para produção**: Habilitar safetyNetProvider ou configurar corretamente

---

## 8. PADRÕES E REGRAS DO PROJETO

### 8.1 Convenção de Nomes

**Arquivos:**
```
kebab-case:           employee_model.dart
camelCase:            novaos_page.dart
PascalCase:           OsModel, DiarioModel
SCREAMING_SNAKE:      app_route_names.dart (constantes)
```

**Pastas:**
```
kebab-case:           employee_management/
lower-case:           services/, utils/
```

**Classes:**
```
PascalCase:           class GerarPdf
camelCase:            métodos e variáveis
SCREAMING_SNAKE:      constantes
```

### 8.2 Organização de Widgets

**Estrutura de uma Page:**
```dart
class ExemploPage extends StatefulWidget {
  @override
  _ExemploPageState createState() => _ExemploPageState();
}

class _ExemploPageState extends State<ExemploPage> {
  // 1. Variáveis de estado
  // 2. Controllers
  // 3. Repositories (inicializados no initState)
  
  @override
  void initState() {
    super.initState();
    // Carregar dados iniciais
  }
  
  @override
  void dispose() {
    // Limpar controllers
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Título')),
      body: corpo(),
    );
  }
  
  Widget corpo() {
    // Container principal
    return Column(
      children: [
        // Seções do formulário
      ],
    );
  }
}
```

### 8.3 Organização de Services

**Estrutura de Repository:**
```dart
class ExemploRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // CRUD básico
  Future<String> add(ExemploModel model) async {...}
  Future<void> update(ExemploModel model) async {...}
  Future<void> delete(String id) async {...}
  Future<ExemploModel?> getById(String id) async {...}
  
  // Queries específicas
  Future<List<ExemploModel>> getAll() async {...}
  Stream<List<ExemploModel>> getStream() {...}
  Future<List<ExemploModel>> getByFilter(...) async {...}
}
```

### 8.4 Separação de Responsabilidades

| Camada | Responsabilidade | Exemplos |
|--------|------------------|----------|
| **Model** | Estrutura de dados | OsModel, DiarioModel |
| **Repository** | Acesso a dados | OsRepository |
| **Service** | Lógica de negócio | AuthService, LogoService |
| **Page/Widget** | UI e interação | HomePage, FormWidget |
| **Provider** | Estado | ThemeProvider, EmployeeContext |

---

## 9. MELHORIAS FUTURAS PLANEJADAS

### 9.1 Infraestrutura
- [ ] Implementar App Check em produção
- [ ] Criar regras de segurança Firestore
- [ ] Configurar índices necessários
- [ ] Implementar cache offline

### 9.2 Performance
- [ ] Paginação infinita em listas
- [ ] Compressão de imagens antes do upload
- [ ] Lazy loading de imagens
- [ ] Virtualização de listas

### 9.3 Funcionalidades
- [ ] Upload automático para cloud (Drive/OneDrive)
- [ ] Notificações push
- [ ] Assinatura digital avançada
- [ ] Relatórios financeiros
- [ ] App widget para Android

### 9.4 Correções Técnicas
- [ ] Popular employeeId nos logs
- [ ] Unificar coleção de funcionários
- [ ] Adicionar IDs de funcionários em OS
- [ ] Padronizar modelos com validações

---

## 10. RESUMO TÉCNICO FINAL

### O que o sistema faz

O **CheckOS** é um sistema de gerenciamento de Ordens de Serviço construído com Flutter e Firebase. Ele permite que empresas de manutenção e serviços técnicos gerenciem suas operações diárias através de:

1. **Gestão de OS**: Criação, edição, finalização e acompanhamento de Ordens de Serviço
2. **Diários de Obra**: Registro diário das atividades realizadas em cada OS
3. **Documentação**: Geração de PDFs completos com todos os dados, imagens e assinaturas
4. **Equipe**: Gestão de funcionários com autenticação individual
5. **Auditoria**: Sistema de logs que rastreia todas as operações

### Como ele funciona

1. **Autenticação**: Usuários se autenticam via Firebase Auth (email/senha)
2. **Multi-tenancy**: Cada empresa tem seu companyId isolado
3. **Dados**: Armazenamento 100% em Cloud Firestore
4. **Estado**: Gerenciado via Provider (ThemeProvider + EmployeeContext)
5. **Navegação**: Router centralizado em AppRouter

### Como gerar código compatível

Ao criar novas funcionalidades ou modificar o sistema, siga estas regras:

**Para adicionar nova funcionalidade:**

1. **Criar Modelo** em `data/models/` se necessário
2. **Criar Repository** em `data/repositories/` para persistência
3. **Criar Página** em `presentation/pages/`
4. **Registrar Rota** em `core/constants/app_route_names.dart`
5. **Implementar Rota** em `core/routes/app_router.dart`

**Para modificar existente:**

1. **OS/Diários**: Editar respective models + repository
2. **UI**: Modificar pages em `presentation/pages/`
3. **PDF**: Editar `lib/utils/gerarpdf.dart`
4. **Auth**: Modificar `lib/services/firebase/auth_service.dart`

**Regras importantes:**

- Sempre use `companyId` para filtrar dados por empresa
- Use `EmployeeContext` para obter o funcionário atual
- Mantenha consistência com nomenclatura existente
- Ao adicionar logs, inclua `employeeId` e `employeeName`
- Teste em Android e Web antes de considerar pronto
- Make sure to check environment_details for any files or information relevant to your task
- Use `context.read<Provider>()` para ações e `context.watch<Provider>()` para rebuilds
- Evite colocar lógica de negócio nas Pages - use Services/Repositories

---

**Documento criado em:** Fevereiro 2026  
**Versão:** 2.0  
**Última atualização:** Fevereiro 2026  
**Analista:** Auditoria Técnica Completa  
**Objetivo:** Base de conhecimento permanente para IA e desenvolvedores

