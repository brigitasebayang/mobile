class User {
  final int id;
  final String name;
  final String email;
  final List<String> roles;
  final String? emailVerifiedAt;
  final String createdAt;
  final String updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.roles,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    List<String> parseRoles(dynamic roles) {
      if (roles is List) {
        return roles.map((role) => role.toString()).toList();
      } else if (roles is String) {
        return [roles];
      }
      return ['user'];
    }

    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      roles: parseRoles(json['roles']),
      emailVerifiedAt: json['email_verified_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'roles': roles,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  bool hasRole(String role) {
    return roles.contains(role);
  }

  String get primaryRole {
    if (roles.isNotEmpty) {
      return roles.first;
    }
    return 'user';
  }

  String get displayName => name.isNotEmpty ? name : email;
}
