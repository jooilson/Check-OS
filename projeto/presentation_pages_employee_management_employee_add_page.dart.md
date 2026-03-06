# employee_add_page.dart
(c:/Projetos/checkos/lib/presentation/pages/employee_management/employee_add_page.dart)

# Descrição Geral
Página para adicionar ou editar funcionário.

# Responsabilidade no Sistema
Formulário para criar ou editar dados de funcionário.

# Dependências
- flutter/material.dart
- checkos/data/models/employee/employee_model.dart
- checkos/data/repositories/employee_repository.dart

# Campos do Formulário
- Nome (obrigatório)
- Email (obrigatório, único)
- Telefone
- CPF
- Role (usuário/admin)

# Fluxo
1.Modo edição: carrega dados existentes
2.Modo criação: formulário vazio
3.Validações
4.EmployeeRepository.addEmployee() ou updateEmployee()
5.Redireciona para lista

# Integração
- EmployeeRepository: addEmployee(), updateEmployee()
- EmployeeModel: dados do formulário

