# employee_management_page.dart
(c:/Projetos/checkos/lib/presentation/pages/employee_management/employee_management_page.dart)

# Descrição Geral
Página de gerenciamento de funcionários.

# Responsabilidade no Sistema
Lista, adiciona, edita e remove funcionários da empresa.

# Dependências
- flutter/material.dart
- provider
- checkos/data/repositories/employee_repository.dart

# Funcionalidades
- Lista todos os funcionários da empresa
- Busca por nome ou email
- Filtro por status (ativo/inativo)
- Botão para adicionar novo funcionário
- Ações: editar, ativar/desativar

# Integração
- EmployeeRepository: CRUD de funcionários
- EmployeeContext: funcionário atual

# Permissões
- owner: pode gerenciar todos
- admin: pode gerenciar usuários
- user: acesso restrito

