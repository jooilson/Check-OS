# 📋 AUDITORIA COMPLETA DO PROJETO CHECKOS

## Visão Geral do Sistema

O **CheckOS** é um sistema de gerenciamento de Ordens de Serviço (OS) construído com Flutter e Firebase. O sistema permite criar, editar e gerenciar Ordens de Serviço, acompanhar diários de atendimento, gerenciar funcionários, e gerar relatórios em PDF.

### Arquitetura Identificada

```
lib/
├── core/                    # Configurações centrais
│   ├── constants/          # Constantes (nomes de rotas)
│   ├── routes/             # Gerenciador de rotas
│   ├── theme/              # Temas (claro/escuro)
│   └── utils/              # Utilitários (logger)
├── data/                    # Camada de dados
│   ├── datasources/        # Fontes de dados
│   ├── models/             # Modelos de dados
│   │   ├── employee/       # EmployeeModel
│   │   ├── os_model.dart   # Modelo de OS
│   │   ├── diario_model.dart # Modelo de Diário
│   │   └── log_model.dart  # Modelo de Log
│   └── repositories/        # Repositórios
│       ├── employee_repository.dart
│       ├── os_repository.dart
│       ├── diario_repository.dart
│       └── log_repository.dart
├── domain/                  # Camada de domínio
│   └── entities/           # Entidades
│       └── employee/       # EmployeeEntity
├── presentation/           # Camada de apresentação
│   ├── pages/             # Páginas
│   │   ├── employee_management/
│   │   ├── register/
│   │   ├── novaos_page.dart
│   │   └── ...
│   └── widgets/           # Widgets reutilizáveis
├── services/               # Serviços
│   ├── firebase/          # AuthService
│   └── import_export_service.dart
└── utils/                 # Utilitários
    └── gerarpdf.dart      # Geração de PDF
```

---

## 1. 🔴 FALHAS CRÍTICAS IDENTIFICADAS

### 1.1 Sistema de Auditoria Incompleto

**Problema:** O `LogModel` possui campos para rastrear funcionários (`employeeId` e `employeeName`), mas **NUNCA são populados** nas operações de CRUD.

**Localização:** 
- `lib/presentation/pages/novaos_page.dart` (linhas ~360-390)
- `lib/presentation/pages/detalhes_os_page.dart` (linhas ~60-80)

**Código Problemático:**
```dart
// Em novaos_page.dart - Método _salvar()
await _logRepository.addLog(LogModel(
  id: '',
  userId: FirebaseAuth.instance.currentUser?.uid ?? 'unknown',
  userEmail: FirebaseAuth.instance.currentUser?.email ?? 'unknown',
  // ❌ FALTANDO: employeeId e employeeName
  timestamp: DateTime.now(),
  action: 'UPDATE_OS',
  osId: os.id,
  osNumero: os.numeroOs,
  description: 'OS atualizada',
))
```

**Impacto:** 
- Não é possível rastrear QUAL funcionário realizou determinada ação
- A auditoria fica incompleta, apenas com dados do usuário Auth
- O sistema de funcionários não cumpre seu propósito de rastreabilidade

**Correção Sugerida:**
```dart
// Implementar um serviço de contexto de funcionário
// que mantém o funcionário atualmente selecionado/em uso

await _logRepository.addLog(LogModel(
  id: '',
  userId: FirebaseAuth.instance.currentUser?.uid ?? 'unknown',
  userEmail: FirebaseAuth.instance.currentUser?.email ?? 'unknown',
  employeeId: _currentEmployeeId, // ✓ Adicionar
  employeeName: _currentEmployeeName, // ✓ Adicionar
  timestamp: DateTime.now(),
  action: actionType,
  osId: os.id,
  osNumero: os.numeroOs,
  description: description,
));
```

---

### 1.2 Divergência na Estrutura de Dados de Funcionários

**Problema:** Funcionários são armazenados em **duas coleções diferentes** no Firestore, causando inconsistência de dados.

**Estrutura Atual (Problemática):**
```
Firestore:
├── users/{userId}/
│   └── employees/{employeeId}  ← Sub-coleção (inacessível)
├── employees/{employeeId}       ← Coleção raiz (principal?)
```

**Análise do Código:**

Em `AuthService.registerEmployee()`:
```dart
// Grava no Firestore usando a instância principal
await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
  'email': email,
  'name': name,
  'role': role,
  'isActive': true,
  'createdAt': FieldValue.serverTimestamp(),
});

// Salvar também na coleção 'employees'
await FirebaseFirestore.instance.collection('employees').doc(userCredential.user!.uid).set({
  'name': name,
  'email': email,
  'role': role,
  'isActive': true,
  'createdAt': FieldValue.serverTimestamp(),
});
```

**Problemas Identificados:**
1. **Duplicação de dados** - Mesmo funcionário em duas coleções
2. **Campos diferentes** - `users` tem `isActive`, `employees` também
3. **Sincronização** - Se um for atualizado, o outro fica desatualizado
4. **Complexidade** - Dificulta consultas e manutenção

**Correção Sugerida:**
- Manter apenas uma coleção (`employees`) como fonte principal
- Usar `users` apenas para autenticação (role)
- Implementar sincronização automática ou usar apenas uma coleção

---

### 1.3 Modelo OS Armazena Apenas Nomes de Funcionários

**Problema:** O campo `funcionarios` em `OsModel` é uma lista de strings (`List<String>`), armazenando apenas os **nomes** dos funcionários, não seus **IDs**.

**Localização:** `lib/data/models/os_model.dart`

```dart
class OsModel {
  // ...
  final List<String> funcionarios;  // ❌ Apenas nomes!
  // ...
}
```

**Problemas Decorrentes:**
1. **Não há referência aos IDs dos funcionários** - Não é possível vincular à entidade Employee
2. **Auditoria comprometida** - Não é possível saber quais funcionários específicos estavam na OS
3. **Dados redundantes** - Se o nome mudar, precisa atualizar em todas as OS
4. **Inconsistência** - Funcionários podem ser excluídos mas ainda aparecem nas OS

**Correção Sugerida:**
```dart
class OsModel {
  // ... existing fields
  final List<String> funcionarios;      // Nomes (para exibição)
  final List<String> funcionariosIds;   // ✓ IDs (para referência)
  // ...
}
```

O mesmo aplica-se ao `DiarioModel`.

---

### 1.4 EmployeeRegistrationPage - Inconsistência na Criação

**Problema:** A página de registro de funcionários (`EmployeeRegistrationPage`) cria funcionários sem associar ao usuário logado, e usa `AuthService.registerEmployee()` que cria uma nova autenticação para cada funcionário.

**Análise do Fluxo:**

1. **Registro de Admin:** `RegisterPage` → `EmployeeRegistrationPage`
2. **Cadastro de Funcionário:** `EmployeeManagementPage` → `EmployeeAddPage`

**Problema Identificado:**
- `EmployeeRegistrationPage` é usada para adicionar funcionários com senha
- `EmployeeAddPage` é usada em EmployeeManagement (provavelmente para editar)
- Existe duplicação de funcionalidade

**Verificação em EmployeeRepository:**
```dart
Future<void> addEmployee(EmployeeModel employee, {required String password}) async {
  String uid = await _authService.registerEmployee(
    email: employee.email,
    password: password,
    name: employee.name,
    role: employee.role,
  );
  // ...
}
```

**Impacto:** Cada funcionário criado tem sua própria conta Firebase Auth, o que pode não ser desejado para todos os casos de uso (ex: funcionários temporários).

---

## 2. 🟡 PONTOS DE DIVERGÊNCIA

### 2.1 Rotas Cadastradas vs. Utilizadas

**Divergência Encontrada:**

| Rota Definida | Rota Usada | Página |
|---------------|------------|--------|
| `/employee-management` | ✅ Correto | EmployeeManagementPage |
| `/add-employee` | ✅ Correto | EmployeeAddPage |
| `/edit-employee` | ❌ NÃO USADA | - |

**Observação:** A rota `editEmployee` está definida em `AppRouteNames` mas nunca é utilizada. A edição é feita através de `/add-employee` com argumento.

---

### 2.2 Campos em Diferentes Modelos

| Campo | OsModel | DiarioModel | EmployeeModel | Observação |
|-------|---------|-------------|---------------|------------|
| id | ✅ | ✅ | ✅ | ID único |
| createdAt | ✅ (DateTime?) | ✅ | ✅ | Timestamp |
| updatedAt | ✅ (DateTime?) | ✅ | ✅ | Timestamp |
| funcionarios | ✅ | ✅ | N/A | List<String> |
| signature/assinatura | ✅ | ✅ | N/A | String serializada |

**Divergência:**
- `createdAt` e `updatedAt` são opcionais (`DateTime?`) em `OsModel`
- São obrigatórios em `EmployeeModel`

---

### 2.3 Estrutura de Nomeação de Arquivos

**Inconsistência encontrada:**
- `employee_model.dart` → pasta `employee/`
- `os_model.dart` → pasta raiz de `models/`
- `diario_model.dart` → pasta raiz de `models/`
- `log_model.dart` → pasta raiz de `models/`

**Recomendação:** Padronizar estrutura de pastas.

---

## 3. 🟠 POSSÍVEIS CORREÇÕES E MELHORIAS

### 3.1 Implementar Contexto de Funcionário Atual

**Problema:** Sistema não sabe "quem está usando" após login.

**Solução Proposta:**
```dart
// Criar um EmployeeContext ou EmployeeProvider
class EmployeeContext extends ChangeNotifier {
  EmployeeModel? _currentEmployee;
  
  void setCurrentEmployee(EmployeeModel employee) {
    _currentEmployee = employee;
    notifyListeners();
  }
  
  EmployeeModel? get currentEmployee => _currentEmployee;
  String? get currentEmployeeId => _currentEmployee?.id;
  String? get currentEmployeeName => _currentEmployee?.name;
}
```

**Uso:**
```dart
// No momento do login, definir o funcionário atual
// (pode haver seleção de funcionário após login, se houver múltiplos)
```

---

### 3.2 Adicionar Campo de Selection ao Modelo de OS

**Melhoria:** Adicionar campo para vincular diretamente funcionários via ID.

```dart
// Em os_model.dart
class OsModel {
  // ... existing fields
  List<String> get funcionariosIds;  // IDs dos funcionários
  
  // Factory para buscar funcionários vinculados
  Future<List<EmployeeModel>> getFuncionarios() async {
    // Buscar funcionários pelo ID
  }
}
```

---

### 3.3 Padronizar Tratamento de Erros

**Observação:** Vários métodos usam `print()` para erros em vez de logging estruturado.

**Recomendação:**
```dart
// Substituir
print("Error fetching employees: $e");

// Por
AppLogger.error('Erro ao buscar funcionários', e);
```

---

### 3.4 Adicionar Validações nos Modelos

**Problema:** Modelos não possuem validações de entrada.

**Exemplo de Melhoria:**
```dart
class EmployeeModel extends EmployeeEntity {
  // ... existing code
  
  // Validação de email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  // Validação de CPF (opcional)
  static bool isValidCpf(String? cpf) {
    if (cpf == null || cpf.isEmpty) return true; // CPF é opcional
    // Implementar validação de CPF
    return cpf.length == 11;
  }
}
```

---

### 3.5 Adicionar Índices Firestore

**Recomendação:** Criar arquivo `firestore.indexes.json` com índices necessários:

```json
{
  "indexes": [
    {
      "collectionGroup": "os",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "updatedAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "diarios",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "osId", "order": "ASCENDING" },
        { "fieldPath": "data", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "logs",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "osId", "order": "ASCENDING" },
        { "fieldPath": "timestamp", "order": "DESCENDING" }
      ]
    }
  ]
}
```

---

### 3.6 Regras de Segurança Firestore

**Recomendação:** Implementar regras de segurança adequadas.

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Usuários podem ler suas próprias informações
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Funcionários - apenas admins podem gerenciar
    match /employees/{employeeId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.token.role == 'admin';
    }
    
    // OS - usuários autenticados leem, apenas responsáveis escrevem
    match /os/{osId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Diários
    match /diarios/{diarioId} {
      allow read, write: if request.auth != null;
    }
    
    // Logs - apenas leitura
    match /logs/{logId} {
      allow read: if request.auth != null;
      allow write: if false; // Apenas sistema
    }
  }
}
```

---

## 4. 📊 RESUMO EXECUTIVO

| # | Tipo | Problema | Severidade | Status |
|---|------|----------|------------|--------|
| 1 | Lógica | Auditoria não populada em Logs | 🔴 Crítica | Pendente |
| 2 | Dados | Duplicação de coleções de funcionários | 🟡 Alta | Pendente |
| 3 | Modelos | OS armazena apenas nomes, não IDs | 🟡 Alta | Pendente |
| 4 | Fluxo | Rotas duplicadas para edição | 🟠 Média | Pendente |
| 5 | Dados | Modelos com tipos inconsistentes | 🟠 Média | Pendente |
| 6 | Validação | Falta validação nos modelos | 🟠 Média | Pendente |
| 7 | Logging | Uso de print() em vez de logger | 🟢 Baixa | Pendente |

---

## 5. 🔧 PRÓXIMOS PASSOS RECOMENDADOS

### Fase 1: Correções Críticas
1. ✅ Implementar EmployeeContext/Provider
2. ✅ Popular employeeId/employeeName nos Logs
3. ✅ Unificar coleção de funcionários

### Fase 2: Melhorias de Estrutura
1. Adicionar IDs aos funcionários em OS/Diário
2. Padronizar validações nos modelos
3. Criar regras de segurança Firestore

### Fase 3: Refinamentos
1. Adicionar índices Firestore
2. Melhorar tratamento de erros
3. Documentar APIs e fluxos

---

**Documento criado em:** Fevereiro 2026  
**Versão:** 1.0  
**Analista:** Auditoria Automatizada

