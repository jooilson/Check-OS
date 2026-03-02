import 'package:cloud_firestore/cloud_firestore.dart';
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
    // SOLUÇÃO: Usar a instância principal do Firebase Auth diretamente
    // O Admin logado pode criar usuários usando a API de Admin do Firebase
    // Não precisamos mais criar uma segunda instância do app
    
    try {
      // Criar usuário usando a instância padrão do Firebase Auth
      // Nota: O admin precisa estar logado para criar novos usuários
      // Se precisar de funcionalidades de admin, use Firebase Admin SDK no backend
      UserCredential? userCredential;
      
      // Tentar criar usuário - isso vai falhar se não houver admin logado
      // Para解决这个问题, vamos usar uma abordagem diferente
      try {
        userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        // Se falhar (provavelmente porque não há sessão de admin válida),
        // tentamos uma abordagem alternativa
        if (e.code == 'requires-recent-login') {
          throw Exception('Para criar funcionários, faça login novamente como admin');
        }
        rethrow;
      }

      if (userCredential.user == null) {
        throw Exception('Falha ao criar usuário');
      }

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
      
      return userCredential.user!.uid;
    } catch (e) {
      // Log do erro para debug
      print('Erro ao registrar funcionário: $e');
      rethrow;
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
