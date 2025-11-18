import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import '../db/app_database.dart';
import '../models/user.dart';

class UserRepository {
  Future<Database> get _db async => await AppDatabase.instance.database;

  String _hashPassword(String plain) {
    // Simples SHA-256 (não é igual ao Bcrypt do Flask, mas serve para o app local)
    final bytes = utf8.encode(plain);
    return sha256.convert(bytes).toString();
  }

  Future<User> createUser({
    required String username,
    required String email,
    required String password,
  }) async {
    final db = await _db;

    final user = User(
      username: username,
      email: email,
      passwordHash: _hashPassword(password),
    );

    final id = await db.insert('users', user.toMap());
    return user.copyWith(id: id);
  }

  Future<User?> getByEmail(String email) async {
    final db = await _db;
    final res = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (res.isEmpty) return null;
    return User.fromMap(res.first);
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
    final db = await _db;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
}

extension UserCopy on User {
  User copyWith({
    int? id,
    String? username,
    String? email,
    String? passwordHash,
    String? fullName,
    DateTime? dateOfBirth,
    double? weight,
    double? height,
    String? bloodType,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      bloodType: bloodType ?? this.bloodType,
    );
  }
}
