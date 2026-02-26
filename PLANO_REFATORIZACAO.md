# Plano de Refatoração - CheckOS

## 1. ANÁLISE DO PROJETO

### 1.1 Estado Atual
- **Estrutura de pastas**: Boa base (core/, data/, presentation/, routes/, services/, theme/, utils/)
- **Strings**: Parcialmente organizadas em `android_strings.dart` (~194 ocorrências de Text com strings hardcoded)
- **Rotas**: Duplicadas (`lib/routes.dart` e `lib/routes/app_routes.dart`)
- **Cores**: Não padronizadas (usadas inline em vários lugares)
- **Theme**: Inline em `app.dart`
- **Performance**: Algumas otimizações já aplicadas (debouncer, ListView.builder, const)
- **DI**: get_it já adicionado mas não utilizado plenamente

### 1.2 Objetivos da Refatoração
1. ✅ Organizar a arquitetura do projeto
2. ✅ Melhorar performance
3. ✅ Reduzir peso do app
4. ✅ Padronizar código
5. ✅ Remover más práticas
6. ✅ Preparar o projeto para crescer

---

## 2. PLANOS DE AÇÃO

### 2.1 ORGANIZAÇÃO DE STRINGS
**Arquivo**: `lib/core/constants/app_strings.dart`
- Substituir `android_strings.dart` por `app_strings.dart` mais completo
- Criar módulos por funcionalidade:
  - `login_strings.dart` - Strings de autenticação
  - `os_strings.dart` - Strings de Ordens de Serviço  
  - `diario_strings.dart` - Strings de Diários
  - `dialog_strings.dart` - Strings de diálogos
  - `error_strings.dart` - Mensagens de erro
  - `common_strings.dart` - Strings comuns (botões, labels genéricas)

**Estratégia**:
```dart
// Estrutura proposta
class AppStrings {
  // Auth
  static const login = 'Entrar';
  static const register = 'Criar Conta';
  
  // OS
  static const novaOs = 'Nova OS';
  static const editarOs = 'Editar OS';
  
  // Common
  static const save = 'Salvar';
  static const cancel = 'Cancelar';
  static const delete = 'Excluir';
  static const confirm = 'Confirmar';
  // ... etc
}
```

### 2.2 ORGANIZAÇÃO DE CORES
**Arquivo**: `lib/core/constants/app_colors.dart`
- Criar classe AppColors com cores padronizadas
- Cores do tema (primária, secundária, erros, etc)
- Cores de status (osfinalizado, pendente, andamento)

### 2.3 ORGANIZAÇÃO DE ROTAS
**Arquivos**: `lib/core/routes/app_routes.dart` e `lib/core/routes/app_route_names.dart`
- Consolidar todas as rotas em um único local
- Criar classe estática com constantes de nomes de rotas
- Remover duplicação entre `routes.dart` e `routes/app_routes.dart`

### 2.4 THEME ORGANIZATION
**Arquivo**: `lib/core/theme/app_theme.dart`
- Extrair tema de `app.dart` para classe AppTheme
- Criar método factory para light e dark theme
- Manter ThemeProvider existente

### 2.5 PERFORMANCE
- ✅ Verificar uso consistente de `const` widgets
- ✅ Verificar uso de `ListView.builder` (já aplicado em lista_page.dart)
- ✅ Verificar debouncer em campos de texto (já aplicado)
- ✅ Adicionar `RepaintBoundary` onde necessário
- ✅ Verificar uso de `AutomaticKeepAliveClientMixin` (já aplicado)
- ⚠️ Avaliar uso de `const` constructors em modelos

### 2.6 ESTRUTURA DE ARQUIVOS A CRIAR/MODIFICAR

#### Novos arquivos:
```
lib/core/
├── constants/
│   ├── app_colors.dart        [NOVO]
│   ├── app_route_names.dart   [NOVO]
│   ├── app_strings.dart       [SUBSTITUIR android_strings.dart]
│   ├── login_strings.dart      [NOVO]
│   ├── os_strings.dart        [NOVO]
│   ├── dialog_strings.dart    [NOVO]
│   └── error_strings.dart     [NOVO]
├── theme/
│   └── app_theme.dart         [NOVO]
└── utils/
    └── app_logger.dart        [APRIMORAR logger.dart existente]

lib/core/routes/
├── app_routes.dart            [NOVO - consolidado]
└── app_route_names.dart       [NOVO]
```

#### Arquivos para refatorar:
- `lib/app.dart` - Usar AppTheme
- `lib/routes.dart` - Remover (usar app_routes.dart)
- `lib/routes/app_routes.dart` - Consolidar
- Todos os arquivos em `presentation/pages/` - Substituir strings hardcoded

### 2.7 IMPORTAÇÕES A ATUALIZAR
Após criar os arquivos de constantes, será necessário atualizar:
- ~20 arquivos que usam strings hardcoded
- Arquivos que usam cores inline
- Arquivos que usam nomes de rotas

---

## 3. EXECUÇÃO

### Fase 1: Estrutura Base (1-2 horas)
1. Criar `app_colors.dart`
2. Criar `app_route_names.dart`
3. Criar `app_strings.dart` (módulo principal)
4. Criar `login_strings.dart`
5. Criar `os_strings.dart`
6. Criar `dialog_strings.dart`
7. Criar `error_strings.dart`
8. Criar `app_theme.dart`
9. Consolidar rotas em `app_routes.dart`

### Fase 2: Atualização de Imports (1-2 horas)
1. Atualizar `app.dart` para usar AppTheme
2. Atualizar `main.dart` (se necessário)
3. Atualizar páginas de autenticação
4. Atualizar páginas de OS
5. Atualizar páginas de diários
6. Atualizar widgets

### Fase 3: Limpeza e Verificação (30 minutos)
1. Remover `lib/routes.dart` antigo
2. Verificar se não há strings hardcoded restantes
3. Testar compilação
4. Verificar funcionamento

---

## 4. REGRAS OBRIGATÓRIAS (NÃO QUEBRAR)
- ✅ Manter funcionamento atual
- ✅ Não remover funcionalidades
- ✅ Manter compatibilidade com banco existente
- ✅ Manter geração de PDF e imagens
- ✅ Manter integração com Firebase/SQLite

---

## 5. RESULTADO ESPERADO
- Projeto limpo e organizado
- Código profissional e padronizado
- Estrutura escalável
- Melhor performance
- Menos bugs
- Mais fácil de manter

