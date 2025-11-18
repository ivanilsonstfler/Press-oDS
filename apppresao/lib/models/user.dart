class User {
  final int? id;
  final String username;
  final String email;
  final String passwordHash;
  final String? fullName;
  final DateTime? dateOfBirth;
  final double? weight;
  final double? height;
  final String? bloodType;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
    this.fullName,
    this.dateOfBirth,
    this.weight,
    this.height,
    this.bloodType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password_hash': passwordHash,
      'full_name': fullName,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'weight': weight,
      'height': height,
      'blood_type': bloodType,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String,
      fullName: map['full_name'] as String?,
      dateOfBirth: map['date_of_birth'] != null
          ? DateTime.parse(map['date_of_birth'] as String)
          : null,
      weight: map['weight'] != null ? (map['weight'] as num).toDouble() : null,
      height: map['height'] != null ? (map['height'] as num).toDouble() : null,
      bloodType: map['blood_type'] as String?,
    );
  }
}
