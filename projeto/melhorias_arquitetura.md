# Sugestões Profissionais de Melhoria - CheckOS

## Visão Geral

Este documento apresenta recomendações profissionais para melhorar a arquitetura, performance, segurança e manutenibilidade do projeto CheckOS.

---

## 1. CLEAN ARCHITECTURE

### 1.1 Implementar Completa Separação de Camadas

**Situação Atual**:
```
Presentation → Services → Repositories → Firestore
```

**Problema**: Lógica de negócio mezclada com presentation.

**Melhoria**:
```
Presentation (Pages/Widgets)
        ↓
Use Cases (domain/usecases/)
        ↓
Repositories (domain/repositories/)
        ↓
Data Sources (data/datasources/)
        ↓
Firestore / API / Cache
```

### 1.2 Implementar Use Cases

Criar use cases para todas as operações:

```dart
// Exemplo: Criar OS
class CreateOsUseCase {
  final OsRepository _repository;
  final LogRepository _logRepository;
  
  Future<void> call(OsEntity os, String userId) async {
    // 1. Validar
    _validate(os);
    
    // 2. Criar
    await _repository.addOs(os);
    
    // 3. Log
    await _logRepository.addLog(...);
  }
}
```

### 1.3 Separar Entities de Models

**Recomendação**: entities devem ser puros, sem dependências:

```dart
// domain/entities/user_entity.dart (puro)
class UserEntity {
  final String id;
  final String email;
  // Sem Firestore, sem Timestamp
}

// data/models/user_model.dart (conversão)
class UserModel extends UserEntity {
  factory UserModel.fromFirestore(DocumentSnapshot doc) { ... }
  Map<String, dynamic> toFirestore() { ... }
}
```

---

## 2. INJEÇÃO DE DEPENDÊNCIA

### 2.1 Usar get_it

O pacote já está nas dependências. Implementar:

```dart
// lib/di/injection_container.dart
final getIt = GetIt.instance;

Future<void> init() async {
  // Services
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<PermissionService>(() => PermissionService());
  
  // Repositories
  getIt.registerLazySingleton<UserRepository>(() => UserRepositoryImpl());
  getIt.registerLazySingleton<CompanyRepository>(() => CompanyRepository());
  getIt.registerLazySingleton<EmployeeRepository>(() => EmployeeRepository());
  
  // Use Cases
  getIt.registerFactory(() => CreateOsUseCase(getIt()));
  getIt.registerFactory(() => GetEmployeesUseCase(getIt()));
}
```

### 2.2 Usar injeção nos widgets

```dart
// Ao invés de:
class Page extends StatelessWidget {
  final AuthService _authService = AuthService();
}

// Fazer:
class Page extends StatelessWidget {
  final AuthService _authService = getIt<AuthService>();
}
```

---

## 3. OTIMIZAÇÃO FIRESTORE

### 3.1 Implementar Cache Local

Adicionar cache para減少 leituras:

```dart
// Usar Hive ou SharedPreferences
class OsRepositoryCache {
  static const String _cacheKey = 'os_cache';
  
  Future<List<OsModel>> getCached(String companyId) async {
    final data = await SharedPreferences.getInstance();
    final json = data.getString('${_cacheKey}_$companyId');
    if (json != null) {
      return (jsonDecode(json) as List)
          .map((e) => OsModel.fromMap(e))
          .toList();
    }
    return null;
  }
  
  Future<void> cache(List<OsModel> osList, String companyId) async {
    final data = await SharedPreferences.getInstance();
    await data.setString(
      '${_cacheKey}_$companyId',
      jsonEncode(osList.map((e) => e.toMap()).toList()),
    );
  }
}
```

### 3.2 Paginação Universal

Aplicar paginação em todas as listas:

```dart
// Usar comando:
.limit(20)
.startAfterDocument(lastDoc)

// Implementar scroll infinito:
ScrollController _scrollController = ScrollController();
@override
void initState() {
  _scrollController.addListener(_onScroll);
}
```

### 3.3 Batch Writes para Importação

```dart
Future<void> importOs(List<OsModel> osList) async {
  final batch = FirebaseFirestore.instance.batch();
  
  for (final os in osList) {
    final ref = FirebaseFirestore.instance.collection('os').doc();
    batch.set(ref, os.toFirestore());
  }
  
  await batch.commit();
}
```

### 3.4 Índices Compostos

Criar índices no Firebase Console:

| Coleção | Campos | Ordem |
|---------|--------|-------|
| os | companyId, createdAt | desc |
| os | companyId, status | asc |
| diarios | osId, data | desc |
| employees | companyId, name | asc |

---

## 4. MELHORIAS DE SEGURANÇA

### 4.1 Regras Firestore Robustas

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function
    function isOwnerOrAdmin(companyId) {
      let user = get(/databases/$(database)/documents/users/$(request.auth.uid));
      return user != null && 
             user.data.companyId == companyId &&
             user.data.role in ['owner', 'admin'];
    }
    
    // Companies
    match /companies/{companyId} {
      allow read: if request.auth != null;
      allow write: if isOwnerOrAdmin(companyId);
    }
    
    // OS - apenas da mesma empresa
    match /os/{osId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null;
    }
    
    // Usuários - próprio documento
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 4.2 App Check em Produção

```dart
// Em main.dart - ativar para produção
await FirebaseAppCheck.instance.activate(
  androidProvider: AndroidProvider.playIntegrity,
  // ou safetyNet para debug
);
```

### 4.3 Validação Server-Side

Usar Firebase Functions para validações:

```javascript
// functions/index.js
exports.validateOs = functions.firestore
  .document('os/{osId}')
  .onCreate((snap, context) => {
    const data = snap.data();
    
    if (!data.companyId) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'OS deve ter companyId'
      );
    }
    
    return true;
  });
```

---

## 5. MELHORIAS DE PERFORMANCE FLUTTER

### 5.1 Evitar rebuilds desnecessários

```dart
// Usar const construtors
const Text('Hello')

// Usar Selector para dados específicos
Selector<AuthService, User?>(
  selector: (_, service) => service.currentUser,
  builder: (_, user, __) => Text(user?.name ?? ''),
)
```

### 5.2 Lazy Loading de Imagens

```dart
// Usar cache para imagens
CachedNetworkImage(
  imageUrl: url,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

### 5.3 Debounce em TextFields

O debouncer já existe. Aplicar em todas as buscas:

```dart
final _debouncer = Debouncer(milliseconds: 500);

TextField(
  onChanged: (value) {
    _debouncer.run(() => _search(value));
  },
)
```

### 5.4 ListView.builder

Sempre usar para listas grandes:

```dart
// Bom
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)

// Ruim
ListView(
  children: items.map((e) => ItemWidget(e)).toList(),
)
```

---

## 6. TRATAMENTO DE ERROS

### 6.1 try-catch Universal

```dart
Future<void> _executeWithErrorHandling(
  Future<void> Function() action,
) async {
  try {
    await action();
  } on FirebaseAuthException catch (e) {
    _showError(_getAuthErrorMessage(e.code));
  } on FirebaseException catch (e) {
    _showError('Erro no banco de dados: ${e.message}');
  } catch (e) {
    _showError('Erro inesperado: $e');
    // Log para debug
    Logger.error(e);
  }
}
```

### 6.2 Feedback ao Usuário

```dart
// Snackbar de sucesso
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('OS salva com sucesso!'),
    backgroundColor: Colors.green,
  ),
);

// Snackbar de erro
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Erro ao salvar'),
    backgroundColor: Colors.red,
  ),
);
```

---

## 7. TESTES

### 7.1 Testes Unitários

Testar use cases e repositories:

```dart
// test/create_os_test.dart
void main() {
  test('Deve criar OS com dados válidos', () async {
    // Arrange
    final mockRepository = MockOsRepository();
    final useCase = CreateOsUseCase(mockRepository);
    
    // Act
    await useCase(OsEntity(...), 'userId');
    
    // Assert
    verify(mockRepository.addOs(any)).called(1);
  });
}
```

### 7.2 Testes de Widget

```dart
// test/login_page_test.dart
void main() {
  testWidgets('Deve mostrar erro com email inválido', (tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginPage()));
    
    await tester.enterText(emailField, 'email-invalido');
    await tester.tap(loginButton);
    
    expect(find.text('Email inválido'), findsOneWidget);
  });
}
```

---

## 8. OBSERVABILIDADE

### 8.1 Firebase Analytics

```dart
// Adicionar tracking
FirebaseAnalytics.instance.logEvent(
  name: 'create_os',
  params: {
    'os_number': os.numeroOs,
    'company_id': os.companyId,
  },
);
```

### 8.2 Firebase Crashlytics

```dart
// Reportar erros
FirebaseCrashlytics.instance.recordError(
  exception,
  stackTrace,
);
```

### 8.3 Logging Estruturado

Melhorar o logger:

```dart
class AppLogger {
  static void debug(String message, {Map<String, dynamic>? data}) {
    _log('DEBUG', message, data);
  }
  
  static void info(String message, {Map<String, dynamic>? data}) {
    _log('INFO', message, data);
  }
  
  static void error(String message, {Map<String, dynamic>? data, Object? error}) {
    _log('ERROR', message, data);
    FirebaseCrashlytics.instance.recordError(error, null);
  }
}
```

---

## 9. UNIFICAÇÃO DE DADOS

### 9.1 Unificar Users e Employees

**Proposta**: Uma única coleção `users` com campos extras:

```dart
// Novo UserModel
class UserModel {
  // Dados de auth
  String id;
  String email;
  
  // Dados funcionais
  String? phone;
  String? cpf;
  String? role;  // user/admin/owner
  
  // Dados de empresa
  String companyId;
  String? companyName;
}
```

### 9.2 Remover Duplicação

```dart
// Remover collection employees
// Manter apenas users com campos extras
```

---

## 10. MELHORIAS DE UI/UX

### 10.1 Loading States

```dart
// Sempre mostrar feedback
if (isLoading) {
  return Center(child: CircularProgressIndicator());
}
```

### 10.2 Empty States

```dart
// Mostrar quando não há dados
if (osList.isEmpty) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.inbox, size: 64),
        Text('Nenhuma OS encontrada'),
      ],
    ),
  );
}
```

### 10.3 Pull to Refresh

```dart
RefreshIndicator(
  onRefresh: _loadData,
  child: ListView(...),
)
```

---

## 11. ESTRUTURA DE PASTAS PROPOSTA

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   ├── theme/
│   └── utils/
├── di/                           # NOVO: Injeção de dependência
│   └── injection_container.dart
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   └── remote/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/              # Interfaces
│   └── usecases/                 # Implementar!
├── presentation/
│   ├── pages/
│   ├── widgets/
│   └── providers/                # NOVO: Providers
└── services/
```

---

## 12. ROADMAP DE IMPLEMENTAÇÃO

### Fase 1: Fundamentos (Semana 1-2)
- [ ] Implementar get_it
- [ ] Criar interfaces para repositories
- [ ] Refatorar injeção em pages

### Fase 2: Arquitetura (Semana 3-4)
- [ ] Criar use cases básicos
- [ ] Implementar tratamento de erros
- [ ] Adicionar logging estruturado

### Fase 3: Performance (Semana 5-6)
- [ ] Implementar cache local
- [ ] Adicionar paginação universal
- [ ] Otimizar rebuilds

### Fase 4: Segurança (Semana 7-8)
- [ ] Fortalecer regras Firestore
- [ ] Ativar App Check
- [ ] Implementar validações server-side

### Fase 5: Observabilidade (Semana 9-10)
- [ ] Adicionar Analytics
- [ ] Configurar Crashlytics
- [ ] Criar dashboard

### Fase 6: Qualidade (Semana 11-12)
- [ ] Escrever testes unitários
- [ ] Escrever testes de widget
- [ ] Documentar código

---

## 13. RESUMO

| Categoria | Melhoria | Impacto |
|-----------|----------|---------|
| Arquitetura | Clean Architecture completa | Manutenibilidade |
| DI | get_it | Testabilidade |
| Firestore | Cache + Paginação | Performance |
| Segurança | Regras + App Check | Confiabilidade |
| Erros | try-catch estruturado | Estabilidade |
| Testes | Unit + Widget | Qualidade |
| Observabilidade | Analytics + Crashlytics | Debugging |
| Dados | Unificar coleções | Integridade |

---

## 14. PRIORIDADES

### Alta Prioridade
1. Injeção de dependência
2. Tratamento de erros
3. Cache local
4. Regras de segurança

### Média Prioridade
5. Use cases
6. Testes
7. Analytics

### Baixa Prioridade
8. Refatoração completa
9. Documentação adicional
10. Novas features

