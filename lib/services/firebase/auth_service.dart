import 'package:checkos/data/models/user/user_model.dart';
import 'package:checkos/data/models/company/company_model.dart';
import 'package:checkos/data/repositories/company_repository.dart';
import 'package:checkos/data/repositories/user/user_repository_impl.dart';
import 'package:checkos/domain/entities/user/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final UserRepositoryImpl _userRepository = UserRepositoryImpl();
  final CompanyRepository _companyRepository = CompanyRepository();

  // Stream para mudanças de estado de autenticação
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Usuário atual
  User? get currentUser => _firebaseAuth.currentUser;

  /// Realiza login com email e senha
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Cria nova conta e empresa (para primeiro acesso)
  Future<UserCredential> createAccountWithCompany({
    required String email,
    required String password,
    required String name,
    required String companyName,
    String? cnpj,
    String? phone,
    String? address,
  }) async {
    // 1. Cria usuário no Firebase Auth
    UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = userCredential.user!.uid;
    final now = DateTime.now();

    // 2. Cria empresa no Firestore
    final companyId = await _companyRepository.createCompany(
      name: companyName,
      ownerId: uid,
      cnpj: cnpj,
      phone: phone,
      address: address,
      email: email,
    );

    // 3. Cria documento do usuário como OWNER
    final user = UserModel(
      id: uid,
      email: email,
      name: name,
      companyId: companyId,
      role: UserRole.owner,
      isOwner: true,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    await _userRepository.createUser(user);

    return userCredential;
  }

  /// Cadastra novo usuário (funcionário) na empresa existente
  Future<String> registerEmployee({
    required String email,
    required String password,
    required String name,
    required String companyId,
    String role = 'user',
  }) async {
    // Verifica se o usuário atual pode criar funcionários
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      throw Exception('Usuário não autenticado');
    }

    // Busca dados do usuário atual para verificar permissões
    final currentUserData = await _userRepository.getUserById(currentUser.uid);
    if (currentUserData == null) {
      throw Exception('Dados do usuário não encontrados');
    }

    // Verifica se pode criar usuários
    if (!currentUserData.isAdmin) {
      throw Exception('Você não tem permissão para criar funcionários');
    }

    // Cria o novo usuário no Firebase Auth
    UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = userCredential.user!.uid;
    final now = DateTime.now();

    // Converte role string para enum
    final userRole = role == 'admin' ? UserRole.admin : UserRole.user;

    // Cria documento do usuário
    final newUser = UserModel(
      id: uid,
      email: email,
      name: name,
      companyId: companyId,
      role: userRole,
      isOwner: false,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    await _userRepository.createUser(newUser);

    return uid;
  }

  /// Busca dados completos do usuário logado (incluindo empresa)
  Future<UserWithCompany> getFullUserData(String uid) async {
    // Busca dados do usuário
    final userEntity = await _userRepository.getUserById(uid);
    if (userEntity == null) {
      throw Exception('Usuário não encontrado');
    }

    // Converte para UserModel
    final user = UserModel(
      id: userEntity.id,
      email: userEntity.email,
      name: userEntity.name,
      companyId: userEntity.companyId,
      role: userEntity.role,
      isOwner: userEntity.isOwner,
      isActive: userEntity.isActive,
      createdAt: userEntity.createdAt,
      updatedAt: userEntity.updatedAt,
    );

    // Busca dados da empresa
    CompanyModel? company;
    if (user.companyId != null) {
      company = await _companyRepository.getCompanyById(user.companyId!);
    }

    return UserWithCompany(user: user, company: company);
  }

  /// Verifica se usuário precisa completar cadastro da empresa
  Future<bool> needsCompanyRegistration(String uid) async {
    final user = await _userRepository.getUserById(uid);
    if (user == null) return true;
    return user.companyId == null || user.companyId!.isEmpty;
  }

  /// Atualiza empresa do usuário (após criar)
  Future<void> linkUserToCompany(String userId, String companyId, UserRole role) async {
    await _userRepository.updateUserCompany(userId, companyId);
    
    // Se for o primeiro usuário, define como owner
    if (role == UserRole.owner) {
      await _userRepository.updateUserRole(userId, UserRole.owner);
    }
  }

  /// Busca role do usuário
  Future<String> getUserRole(String uid) async {
    try {
      final user = await _userRepository.getUserById(uid);
      return user?.role.value ?? 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }

  /// Realiza logout
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Envia email de redefinição de senha
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// Atualiza senha do usuário atual
  Future<void> updatePassword(String newPassword) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    }
  }

  /// Atualiza perfil do usuário
  Future<void> updateProfile({String? name}) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      if (name != null) {
        await user.updateDisplayName(name);
      }
    }
  }
}

/// Classe para retornar usuário com empresa
class UserWithCompany {
  final UserModel user;
  final CompanyModel? company;

  UserWithCompany({required this.user, this.company});
}

