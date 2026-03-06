# employee_repository.dart
(c:/Projetos/checkos/lib/data/repositories/employee_repository.dart)

# Descrição Geral
Repositório de Funcionários que gerencia operações CRUD no Firestore. Mantém sincronização entre as coleções 'employees' e 'users'.

# Responsabilidade no Sistema
Centraliza operações de persistência de funcionários. Inclui sincronização com Firebase Auth e Firestore.

# Dependências
- flutter/foundation.dart
- checkos/core/utils/logger.dart
- checkos/data/models/employee/employee_model.dart
- checkos/services/firebase/auth_service.dart
- cloud_firestore

# Classes
- **EmployeeRepository**
  - Repositório de funcionários

# Métodos / Funções
- **getEmployeesStream({String? companyId})** (Stream<List<EmployeeModel>>)
  - Finalidade: Stream de funcionários em tempo real
  - Ordenado por nome

- **getEmployeesList({String? companyId})** (Future<List<EmployeeModel>>)
  - Finalidade: Lista de funcionários
  - Ordenado por nome

- **getActiveEmployeesList({String? companyId})** (Future<List<EmployeeModel>>)
  - Finalidade: Lista de funcionários ativos

- **getEmployeeById(String id)** (Future<EmployeeModel?>)
  - Finalidade: Buscar funcionário por ID

- **getCompanyIdByUid(String uid)** (Future<String?>)
  - Finalidade: Buscar companyId do usuário
  - Fonte principal: coleção 'employees'
  - Fallback: coleção 'users'

- **deleteEmployee(String id)** (Future<void>)
  - Finalidade: Soft delete (isActive = false)
  - Atualiza ambas as coleções

- **emailExists(String email)** (Future<bool>)
  - Finalidade: Verificar se email existe

- **addEmployee(EmployeeModel employee, {required String password, required String companyId})** (Future<void>)
  - Finalidade: Criar novo funcionário
  - Valida companyId e existência da empresa
  - Cria usuário no Firebase Auth via AuthService

- **updateEmployee(EmployeeModel employee)** (Future<void>)
  - Finalidade: Atualizar funcionário
  - Sincroniza ambas as coleções

# Fluxo de Execução
1. addEmployee → AuthService.registerEmployee → cria no Auth + users
2.employeeRepository atualiza com phone, cpf, companyId
3.companyId filtragem implementada

# Integração com Sistema
- Firestore: Coleções 'employees' e 'users'
- Firebase Auth: Criação de usuários
- AuthService: Registro de funcionários

# Estrutura de Dados
- Coleções: 'employees', 'users'
- companyId: Filtro multi-tenant

# Regras de Negócio
- companyId é obrigatório
- Sincronização entre coleções
- Soft delete implementado

# Pontos Críticos
-companyId évalidado antes de salvar
-companyDoc verificado antes de criar

# Melhorias Possíveis
-Adicionar cache local
-Consolidar em uma única coleção
