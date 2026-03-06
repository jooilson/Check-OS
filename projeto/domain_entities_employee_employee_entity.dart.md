# employee_entity.dart
(c:/Projetos/checkos/lib/domain/entities/employee/employee_entity.dart)

# Descrição Geral
Entidade base do funcionário que define a estrutura de dados básica.

# Responsabilidade no Sistema
Define a estrutura de dados do funcionário sem regras de negócio específicas.

# Dependências
- equatable

# Classes
- **EmployeeEntity** (extends Equatable)
  - Entidade base do funcionário

# Propriedades
- id: String - ID único
- name: String - Nome
- email: String - Email
- role: String - Cargo ('owner', 'admin', 'user')
- phone: String - Telefone
- cpf: String? - CPF (opcional)
- companyId: String? - ID da empresa
- isActive: bool - Se está ativo
- createdAt: DateTime - Data de criação
- updatedAt: DateTime - Data de atualização

# Fluxo de Execução
Usada como base para EmployeeModel.

# Integração com o Sistema
- EmployeeModel: Estende esta entidade

# Estrutura de Dados
- Equatable para comparação

# Regras de Negócio
- isActive permite soft delete

# Pontos Críticos
- companyId é opcional (pode ser null)

