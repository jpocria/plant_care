import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';

class AuthRepository extends ChangeNotifier {
  final AuthService _authService;
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _currentUserModel;
  bool _isLoading = false;
  String? _error;

  AuthRepository(this._authService) {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  UserModel? get currentUser => _currentUserModel;
  bool get isAuthenticated => _authService.isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmailVerified => _authService.isEmailVerified;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user != null) {
      await _loadUserData(user.uid);
    } else {
      _currentUserModel = null;
    }
    notifyListeners();
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestoreService.getDocument(
        collection: 'users',
        docId: uid,
      );
      if (doc != null && doc.exists) {
        _currentUserModel = UserModel.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados do usuário: $e');
    }
  }

  // ── CRUD ────────────────────────────────────────────────────────────────

  /// Busca um usuário pelo UID no Firestore.
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestoreService.getDocument(
        collection: 'users',
        docId: uid,
      );
      if (doc == null || !doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('Erro ao buscar usuário $uid: $e');
      rethrow;
    }
  }

  /// Atualiza os dados do usuário no Firestore.
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestoreService.updateDocument(
        collection: 'users',
        docId: user.id,
        data: user.toFirestore(),
      );
      // Mantém o cache local sincronizado
      if (_currentUserModel?.id == user.id) {
        _currentUserModel = user;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao atualizar usuário ${user.id}: $e');
      rethrow;
    }
  }

  /// Remove o documento do usuário no Firestore.
  /// A exclusão da conta no Firebase Auth é feita por [AuthService.deleteAccount].
  Future<void> deleteUser(String uid) async {
    try {
      await _firestoreService.deleteDocument(
        collection: 'users',
        docId: uid,
      );
      if (_currentUserModel?.id == uid) {
        _currentUserModel = null;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao deletar usuário $uid: $e');
      rethrow;
    }
  }

  // ── Auth flows ───────────────────────────────────────────────────────────

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final credential = await _authService.registerWithEmail(
        name: name,
        email: email,
        password: password,
      );

      final userModel = UserModel(
        id: credential.user!.uid,
        name: name.trim(),
        email: email.trim().toLowerCase(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestoreService.setDocument(
        collection: 'users',
        docId: credential.user!.uid,
        data: userModel.toFirestore(),
        merge: false,
      );

      _currentUserModel = userModel;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      await _authService.signInWithEmail(email: email, password: password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _setError(null);

    try {
      final credential = await _authService.signInWithGoogle();
      if (credential == null) {
        _setLoading(false);
        return false;
      }

      final user = credential.user!;
      final existingDoc = await _firestoreService.getDocument(
        collection: 'users',
        docId: user.uid,
      );

      if (existingDoc == null || !existingDoc.exists) {
        final userModel = UserModel(
          id: user.uid,
          name: user.displayName ?? 'Usuário',
          email: user.email ?? '',
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestoreService.setDocument(
          collection: 'users',
          docId: user.uid,
          data: userModel.toFirestore(),
          merge: false,
        );
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUserModel = null;
    notifyListeners();
  }

  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    _setError(null);

    try {
      await _authService.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateName(String newName) async {
    if (_currentUserModel == null) return false;
    _setLoading(true);

    try {
      await _firestoreService.updateDocument(
        collection: 'users',
        docId: _currentUserModel!.id,
        data: {'name': newName.trim()},
      );
      _currentUserModel = _currentUserModel!.copyWith(name: newName.trim());
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
}