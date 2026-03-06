# Mapa Completo do Projeto CheckOS

## Estrutura de Pastas

```
lib/
├── app.dart                          # Widget raiz da aplicacao Flutter
├── main.dart                         # Ponto de entrada (entry point)
├── firebase_options.dart             # Configuracoes do Firebase por plataforma
├── routes.dart                       # Definicoes alternativas de rotas
│
├── core/                            # CONFIGURACOES GLOBAIS
│   ├── constants/                    # Constantes globais do app
│   │   ├── app_colors.dart           # Cores do tema
│   │   ├── app_route_names.dart      # Nomes das rotas (strings)
│   │   ├── app_strings.dart         # Strings gerais
│   │   ├── dialog_strings.dart      # Strings de dialogos
│   │   ├── error_strings.dart       # Mensagens de erro
│   │   ├── login_strings.dart       # Strings de login
│   │   └── os_strings.dart          # Strings de OS
│   │
│   ├── context/                     # Gerenciadores de estado globais
│   │   ├── auth_context.dart        # Contexto de autenticacao
│   │   └── employee_context.dart    # Contexto de funcionario atual
│   │
│   ├── routes/                      # Gerenciamento de navegacao
│   │   └── app_router.dart          # Gerador de rotas centralizado
│   │
│   ├── theme/                       # Definicoes de tema
│   │   └── app_theme.dart           # Tema light e dark
│   │
│   └── utils/                       # Utilitarios globais
│       └── logger.dart              # Sistema de logs
│
├── data/                            # CAMADA DE DADOS
│   ├── models/                      # Modelos (Mapeamento Firestore)
│   │   ├── company/
│   │   │   └── company_model.dart   # Modelo de Empresa
│   │   ├── employee/
│   │   │   └── employee_model.dart # Modelo de Funcionario
│   │   ├── user/
│   │   │   └── user_model.dart     # Modelo de Usuario
│   │   ├── diario_model.dart        # Modelo de Diario de Bordo
│   │   ├── log_model.dart           # Modelo de Log/Auditoria
│   │   ├── os_model.dart            # Modelo de Ordem de Servico
│   │   └── os_model_bkp.dart       # Backup do modelo OS
│   │
│   ├── repositories/               # Implementacoes dos repositories
│   │   ├── company_repository.dart  # Persistencia de empresas
│   │   ├── employee_repository.dart # Persistencia de funcionarios
│   │   ├── user/
│   │   │   └── user_repository_impl.dart # Persistencia de usuarios
│   │   ├── diario_repository.dart  # Persistencia de diarios
│   │   ├── log_repository.dart     # Persistencia de logs
│   │   └── os_repository.dart      # Persistencia de OS
│   │
│   └── datasources/                # Fontes de dados (abstratos)
│       ├── local/                   # Dados locais (cache)
│       └── remote/                  # Dados remotos (API)
│
├── domain/                          # CAMADA DE DOMINIO
│   ├── entities/                   # Entidades de negocio
│   │   ├── company/
│   │   │   └── company_entity.dart # Entidade Empresa
│   │   ├── employee/
│   │   │   └── employee_entity.dart # Entidade Funcionario
│   │   └── user/
│   │       └── user_entity.dart    # Entidade Usuario
│   │
│   ├── repositories/               # Interfaces dos repositories
│   │   └── user/
│   │       └── user_repository.dart # Interface UsuarioRepository
│   │
│   └── usecases/                  # Casos de uso (nao implementado)
│       └── user/
│           └── get_user_details.dart
│
├── presentation/                   # CAMADA DE APRESENTACAO
│   ├── pages/                     # Telas/Screens
│   │   ├── auth/
│   │   │   ├── auth_page.dart     # Pagina de login
│   │   │   └── auth_wrapper.dart  # Wrapper de autenticacao
│   │   ├── cadastro_empresa/
│   │   │   └── cadastro_empresa_page.dart # Cadastro de empresa
│   │   ├── employee_management/
│   │   │   ├── employee_add_page.dart     # Adicionar/editar funcionario
│   │   │   └── employee_management_page.dart # Listagem de funcionarios
│   │   ├── home/
│   │   │   └── home_page.dart     # Pagina principal
│   │   ├── login/
│   │   │   └── login_page.dart    # Pagina de login (alternativo)
│   │   ├── register/
│   │   │   └── register_page.dart # Pagina de registro
│   │   ├── config_page.dart       # Configuracoes
│   │   ├── detalhes_os_page.dart  # Detalhes da OS
│   │   ├── editar_diario_page.dart # Edicao de diario
│   │   ├── import_export_page.dart # Importacao/Exportacao
│   │   ├── lista_page.dart        # Lista geral
│   │   ├── logs_page.dart         # Visualizacao de logs
│   │   ├── novaos_page.dart       # Criar nova OS
│   │   └── novo_diario_page.dart  # Criar novo diario
│   │
│   └── widgets/                   # Widgets reutilizaveis
│       ├── diario_form_widget.dart # Formulario de diario
│       ├── diario_list_widget.dart # Lista de diarios
│       ├── funcionario_autocomplete_field.dart # Campo autocomplete
│       └── os_form_sections.dart  # Secoes do formulario OS
│
├── services/                       # SERVICOS EXTERNOS
│   ├── firebase/
│   │   └── auth_service.dart      # Servico de autenticacao
│   ├── import_export_service.dart # Importacao/Exportacao
│   ├── logo_service.dart          # Gerenciamento de logos
│   ├── permission_service.dart    # Permissoes de usuario
│   └── push_notification_service.dart # Notificacoes push
│
├── theme/                          # GERENCIAMENTO DE TEMAS
│   └── theme_provider.dart         # Provider de tema
│
└── utils/                          # UTILITARIOS
    ├── debouncer.dart              # Debounce para buscas
    ├── formatters.dart             # Formatadores de dados
    └── gerarpdf.dart               # Geracao de PDF
```

---

## Responsabilidade Arquitetural de Cada Camada

### 1. CAMADA CORE
**Responsabilidade**: Configuracoes globais, constantes, temas e utilitarios compartilhados.

- **constants/**: Strings, cores, nomes de rotas - evita duplicacao de texto no codigo
- **context/**: Gerencia estado global (autenticacao, usuario atual) usando Provider
- **routes/**: Centraliza navegacao - facilita manutencao de rotas
- **theme/**: Define visual padrao (cores, fontes, estilos)
- **utils/**: Logger para diagnostico

### 2. CAMADA DATA
**Responsabilidade**: Acesso a dados, conversao entre formato Firestore e objetos Dart.

- **models/**: Mapeamento de documentos Firestore para classes Dart
- **repositories/**: Implementacao de persistencia - abstrai detalhes do Firestore
- **datasources/**: Abstracao de fontes de dados (futuro: API REST, cache local)

### 3. CAMADA DOMAIN
**Responsabilidade**: Regras de negocio puras, sem dependencias externas.

- **entities/**: Classes de negocio核心 - representando conceitos do sistema
- **repositories/**: Contratos/interfaces - definem o que repositories devem fazer
- **usecases/**: Casos de uso - orquestram logica de negocio

### 4. CAMADA PRESENTATION
**Responsabilidade**: Interface com o usuario, UI e interacao.

- **pages/**: Telas completas - combinam widgets e logica de visualizacao
- **widgets/**: Componentes reutilizaveis -_botoes, formularios, listas

### 5. SERVICOS
**Responsabilidade**: Integracao com sistemas externos.

- **firebase/auth**: Autenticacao Firebase
- **push_notification**: Firebase Cloud Messaging
- **import_export**: Manuseio de arquivos
- **permission**: Controle de acesso

---

## Resumo de Responsabilidades

| Pasta | Responsabilidade |
|-------|------------------|
| core/ | Configuracoes globais |
| data/ | Persistencia e conversao de dados |
| domain/ | Logica de negocio e entidades |
| presentation/ | Interface com usuario |
| services/ | Integracao externa |
| theme/ | Aparencia visual |
| utils/ | Funcoes auxiliares |

---

## Padroes Arquiteturais Usados

1. **Clean Architecture**: Separacao em camadas (Data/Domain/Presentation)
2. **Repository Pattern**: Abstracao de acesso a dados
3. **Provider Pattern**: Gerenciamento de estado
4. **Model-Entity**: Separacao entre modelo Firestore e entidade de negocio
5. **Service Layer**: Lógica de integracao externa

---

## Observacoes

- Pasta `domain/usecases/` existe mas nao esta em uso
- Arquivos em `routes/` parecem duplicados (alternativos)
- Arquivo `os_model_bkp.dart` e um backup
- pastas `data/datasources/` existem mas estao vazias

