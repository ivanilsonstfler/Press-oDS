import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';

class AuthProvider extends ChangeNotifier {
  final UserRepository _userRepo;
  User? _currentUser;

  AuthProvider(this._userRepo);

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<String?> register(String username, String email, String password) async {
    // Retorna mensagem de erro, se houver; null se OK
    final existing = await _userRepo.getByEmail(email);
    if (existing != null) {
      return 'Email já está em uso';
    }
    try {
      _currentUser = await _userRepo.createUser(
        username: username,
        email: email,
        password: password,
      );
      notifyListeners();
      return null;
    } catch (e) {
      return 'Erro ao cadastrar: $e';
    }
  }

  Future<String?> login(String email, String password) async {
    final user = await _userRepo.login(email: email, password: password);
    if (user == null) {
      return 'Email ou senha inválidos';
    }
    _currentUser = user;
    notifyListeners();
    return null;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateProfile(User user) async {
    await _userRepo.updateProfile(user);
    _currentUser = user;
    notifyListeners();
  }
}
