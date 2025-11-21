import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/user.dart';

class UserRepository {
  Box<Map> get _box => Hive.box<Map>('users');

  String _hashPassword(String plain) {
    final bytes = utf8.encode(plain);
    return sha256.convert(bytes).toString();
  }

  Future<User> createUser({
    required String username,
    required String email,
    required String password,
  }) async {
    final user = User(
      username: username,
      email: email,
      passwordHash: _hashPassword(password),
    );

    final map = user.toMap();
    // primeiro salva sem id
    final key = await _box.add(map);
    // depois atualiza o map com o id gerado
    map['id'] = key;
    await _box.put(key, map);

    return User.fromMap(Map<String, dynamic>.from(map));
  }

  Future<User?> getByEmail(String email) async {
    for (final raw in _box.values) {
      final map = Map<String, dynamic>.from(raw as Map);
      if (map['email'] == email) {
        return User.fromMap(map);
      }
    }
    return null;
  }

  Future<User?> login({
    required String email,
    required String password,
  }) async {
    final user = await getByEmail(email);
    if (user == null) return null;

    final hash = _hashPassword(password);
    if (user.passwordHash == hash) {
      return user;
    }
    return null;
  }

  Future<void> updateProfile(User user) async {
    final id = user.id;
    if (id == null) return;

    final map = user.toMap();
    await _box.put(id, map);
  }
}
