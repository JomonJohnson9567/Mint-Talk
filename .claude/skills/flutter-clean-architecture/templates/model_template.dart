import '../../domain/entities/user.dart';

/// DTO — knows how to (de)serialize and how to become a domain entity.
/// Lives in data/models, never imported by presentation.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  User toEntity() => User(id: id, name: name, email: email);
}
