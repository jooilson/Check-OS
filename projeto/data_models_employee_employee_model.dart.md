# employee_model.dart
(c:/Projetos/checkos/lib/data/models/employee/employee_model.dart)

# Descrição Geral
Modelo de dados do funcionário que estende EmployeeEntity e implementa conversão Firestore.

# Responsabilidade no Sistema
Representa dados do funcionário para persistência no Firestore.

# Dependências
- checkos/domain/entities/employee/employee_entity.dart
- cloud_firestore

# Classes
- **EmployeeModel** (estende EmployeeEntity)
  - Implementa serialização para/de Firestore

# Métodos / Funções
- **EmployeeModel()** (construtor)
  - Parâmetros: id, name, email, role, phone, cpf, companyId, isActive, createdAt, updatedAt

- **fromFirestore(DocumentSnapshot doc)** (factory)
  - Finalidade: Criar EmployeeModel a partir de DocumentSnapshot

- **toFirestore()** (Map<String, dynamic>)
  - Finalidade: Converter para formato Firestore

- **toMap()** (Map<String, dynamic>)
  - Finalidade: Converter para Map genérico

- **fromMap(String id, Map<String, dynamic> map)** (factory)
  - Finalidade: Criar EmployeeModel a partir de Map

- **copyWith({...})** (EmployeeModel)
  - Finalidade: Criar cópia com campos atualizados

# Fluxo de Execução
1. Dados chegam do Firestore
2. fromFirestore converte para EmployeeModel
3. Dados são usados na UI
4. toFirestore converte de volta para persistência

# Integração com o Sistema
- EmployeeEntity: Herda propriedades
- Firestore: Persistência
- EmployeeRepository: Usa este modelo

# Estrutura de Dados
- Timestamps: Convertidos de/para DateTime

# Regras de Negócio
- role é String ('owner', 'admin', 'user')
- isActive permite soft delete

# Pontos Críticos
- companyId vincula funcionário à empresa

# Melhorias Possíveis
- Adicionar validação de CPF

