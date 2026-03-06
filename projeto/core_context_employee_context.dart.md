# employee_context.dart
(c:/Projetos/checkos/lib/core/context/employee_context.dart)

# Descrição Geral
Contexto global (ChangeNotifier) para gerenciar o funcionário atual logado no sistema.

# Responsabilidade no Sistema
Rastrear qual funcionário está logado, permitindo auditoria e acesso aos dados do usuário atual em qualquer lugar da aplicação.

# Dependências
- flutter/foundation.dart
- checkos/data/models/employee/employee_model.dart

# Classes
- **EmployeeContext** (extends ChangeNotifier)
  - Gerencia estado do funcionário atual

# Propriedades
- _currentEmployee: EmployeeModel?
- _currentCompanyId: String?
- _isLoading: bool
- _errorMessage: String?

# Getters
- currentEmployee: EmployeeModel?
- currentEmployeeId: String?
- currentEmployeeName: String?
- currentEmployeeRole: String?
- currentCompanyId: String?
- hasCurrentEmployee: bool
- isLoading: bool
- errorMessage: String?

# Métodos / Funções
- **setCurrentEmployee(EmployeeModel? employee)** (void)
  - Finalidade: Definir funcionário atual
  - Atualiza companyId automaticamente

- **setCurrentEmployeeByData({required String id, required String name, String? role})** (void)
  - Finalidade: Definir funcionário por dados básicos

- **clearCurrentEmployee()** (void)
  - Finalidade: Limpar funcionário (logout)

- **setError(String message)** (void)
  - Finalidade: Definir mensagem de erro

- **clearError()** (void)
  - Finalidade: Limpar mensagem de erro

# Fluxo de Execução
1. App inicia → EmployeeContextProvider disponível
2. Login bem-sucedido → setCurrentEmployee()
3. Qualquer lugar da app → access via Provider
4. Logout → clearCurrentEmployee()

# Integração com o Sistema
- Provider: Gerenciamento de estado
- EmployeeModel: Dados do funcionário

# Estrutura de Dados
- ChangeNotifier para reactive updates
- companyId sincronizado automaticamente

# Regras de Negócio
- companyId derivdo do employee.companyId
- Mantém sincronização via notifyListeners()

# Pontos Críticos
- Única fonte de verdade para funcionário atual
- companyId disponível globalmente

# Melhorias Possíveis
- Adicionar cache local
