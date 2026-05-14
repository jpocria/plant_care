import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Logger _logger = Logger();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  bool get isAuthenticated => currentUser != null;
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  // ── Register ────────────────────────────────────────────────────────────

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _validatePasswordStrength(password);
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      await credential.user?.updateDisplayName(name.trim());
      await credential.user?.sendEmailVerification();
      _logger.i('Usuário cadastrado: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      _logger.e('Erro no cadastro', error: e);
      throw _handleAuthException(e);
    }
  }

  // ── Sign in ─────────────────────────────────────────────────────────────

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      _logger.i('Login realizado: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      _logger.e('Erro no login', error: e);
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      _logger.i('Login Google: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _logger.e('Erro login Google', error: e);
      throw _handleAuthException(e);
    }
  }

  // ── Sign out ────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
      _logger.i('Logout realizado');
    } catch (e) {
      _logger.e('Erro no logout', error: e);
      rethrow;
    }
  }

  // ── Profile update ──────────────────────────────────────────────────────

  /// Atualiza o displayName do usuário no Firebase Auth.
  Future<void> updateDisplayName(String name) async {
    try {
      await currentUser?.updateDisplayName(name.trim());
      _logger.i('DisplayName atualizado: $name');
    } catch (e) {
      _logger.e('Erro ao atualizar displayName', error: e);
      rethrow;
    }
  }

  // ── Password ────────────────────────────────────────────────────────────

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
      _logger.i('E-mail de redefinição enviado para $email');
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> reauthenticate(String password) async {
    final user = currentUser;
    if (user == null || user.email == null) {
      throw Exception('Usuário não logado');
    }
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    try {
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ── Delete account ──────────────────────────────────────────────────────

  /// Exclui a conta do Firebase Auth.
  /// [password] é obrigatório para re-autenticar antes da exclusão.
  Future<void> deleteAccount({String? password}) async {
    if (password != null && password.isNotEmpty) {
      await reauthenticate(password);
    }
    try {
      await currentUser?.delete();
      _logger.i('Conta excluída');
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ── Token ───────────────────────────────────────────────────────────────

  String generateSecureToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    // ignore: unused_import — dart:convert is imported at the top
    return sha256.convert(utf8.encode(bytes.toString())).toString();
  }

  // ── Validation ──────────────────────────────────────────────────────────

  void _validatePasswordStrength(String password) {
    if (password.length < 8) {
      throw Exception('A senha deve ter pelo menos 8 caracteres');
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      throw Exception('A senha deve conter pelo menos uma letra maiúscula');
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      throw Exception('A senha deve conter pelo menos um número');
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      throw Exception('A senha deve conter pelo menos um caractere especial');
    }
  }

  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('Nenhuma conta encontrada com este email');
      case 'wrong-password':
        return Exception('Senha incorreta');
      case 'email-already-in-use':
        return Exception('Este email já está em uso');
      case 'weak-password':
        return Exception('Senha muito fraca');
      case 'invalid-email':
        return Exception('Email inválido');
      case 'user-disabled':
        return Exception('Esta conta foi desativada');
      case 'too-many-requests':
        return Exception('Muitas tentativas. Aguarde alguns minutos');
      case 'network-request-failed':
        return Exception('Sem conexão com a internet');
      case 'requires-recent-login':
        return Exception('Por segurança, faça login novamente');
      default:
        return Exception('Erro de autenticação: ${e.message}');
    }
  }
}