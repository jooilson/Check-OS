import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // stream for auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Re-throw the exception to be handled by the UI
      throw e;
    }
  }

  // create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String name = '',
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Criar uma nova empresa (assinatura) para o admin
      final companyRef = await FirebaseFirestore.instance.collection('companies').add({
        'name': name.isNotEmpty ? '$name\'s Empresa' : 'Minha Empresa',
        'email': email,
        'plan': 'free',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final companyId = companyRef.id;

      // Salvar dados iniciais do Admin no Firestore com o companyId
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'name': name,
        'role': 'admin', // O primeiro usuário criado via registro comum é Admin
        'companyId': companyId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Também salvar na coleção employees para manter consistência
      await FirebaseFirestore.instance.collection('employees').doc(userCredential.user!.uid).set({
        'email': email,
        'name': name,
        'role': 'admin',
        'companyId': companyId,
        'phone': '',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Re-throw the exception to be handled by the UI
      throw e;
    }
  }

  // Cadastrar funcionário (sem deslogar o admin atual)
  Future<String> registerEmployee({
    required String email,
    required String password,
    required String name,
    String role = 'employee', // Padrão é funcionário
    String? companyId, // ID da empresa/assinatura
  }) async {
    // Cria uma instância secundária do App para não interferir na sessão atual do Admin
    FirebaseApp tempApp = await Firebase.initializeApp(
      name: 'tempEmployeeRegister',
      options: Firebase.app().options,
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instanceFor(app: tempApp)
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Grava os dados do funcionário APENAS na coleção 'employees'
      // Esta é a fonte principal de dados de funcionários
      await FirebaseFirestore.instance.collection('employees').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'role': role,
        'companyId': companyId,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Também salva em 'users' para compatibilidade com getUserRole
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'name': name,
        'role': role,
        'companyId': companyId,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Limpa a instância temporária
      await tempApp.delete();
      
      return userCredential.user!.uid;
    } catch (e) {
      await tempApp.delete();
      throw e;
    }
  }

  // sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Obter função do usuário (Role)
  Future<String> getUserRole(String uid) async {
    try {
      // Primeiro tenta buscar na coleção 'employees' (fonte principal)
      final employeeDoc = await FirebaseFirestore.instance.collection('employees').doc(uid).get();
      if (employeeDoc.exists && employeeDoc.data() != null) {
        return employeeDoc.data()!['role'] ?? 'employee';
      }
      
      // Fallback para coleção 'users' (para compatibilidade com admins antigos)
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        return userDoc.data()!['role'] ?? 'employee';
      }
      
      return 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }
}
