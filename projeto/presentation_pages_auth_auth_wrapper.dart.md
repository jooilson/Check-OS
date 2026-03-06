# auth_wrapper.dart
(c:/Projetos/checkos/lib/presentation/pages/auth/auth_wrapper.dart)

# Descrição Geral
Wrapper de autenticação que gerencia o fluxo de autenticação e redirecionamento.

# Responsabilidade no Sistema
Verifica o estado de autenticação do usuário e redireciona para a página apropriada (login ou home).

# Dependências
- checkos/core/constants/app_route_names.dart
- checkos/core/context/employee_context.dart
- checkos/data/models/employee/employee_model.dart
- checkos/data/repositories/employee_repository.dart
- checkos/presentation/pages/auth/auth_page.dart
- checkos/routes.dart
- cloud_firestore
- firebase_auth
- flutter/material.dart
- provider

# Classes
- **AuthWrapper** (extends StatefulWidget)
  - Gerencia estado de autenticação

- **_AuthWrapperState** (State<AuthWrapper>)
  - Estado do AuthWrapper

# Métodos / Funções
- **initState()** - Inicializa e verifica autenticação

- **_checkAuthAndSetContext()** (Future<void>)
  - Finalidade: Verificar autenticação e definir contexto
  - Se usuário autenticado, busca dados do funcionário

- **_setEmployeeContext(String uid)** (Future<void>)
  - Finalidade: Buscar e definir dados do funcionário
  - Fallback: Se não encontrar em employees, busca em users
  - Redireciona para onboarding se companyId for null

- **build(BuildContext)** (Widget)
  - Finalidade: Construir UI
  - Usa StreamBuilder para observar authStateChanges

# Fluxo de Execução
1. App inicia → AuthWrapper renderiza
2. StreamBuilder observa FirebaseAuth.instance.authStateChanges()
3. Se autenticado → busca EmployeeModel → define EmployeeContext
4. Se companyId null → redireciona para CadastroEmpresa
5. Se não autenticado → mostra AuthPage (login)

# Integração com o Sistema
- FirebaseAuth: Observa estado de autenticação
- EmployeeRepository: Busca dados do funcionário
- EmployeeContext: Armazena funcionário atual
- Navigator: Redirecionamento

# Estrutura de Dados
- Stream<User?>: Stream de estado de autenticação
- EmployeeModel: Dados do funcionário

# Regras de Negócio
- companyId null = onboarding obrigatório
- Fallback busca em users se não encontrar em employees

# Pontos Críticos
- Verifica companyId para decidir fluxo
- Fallback entre coleções employees/users

# Melhorias Possíveis
- Adicionar cache local
- Reduzir chamadas Firestore

# Observações Técnicas
- debugPrint para logs
- Usa mounted para evitar erros de estado

