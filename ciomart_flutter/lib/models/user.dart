abstract class User {
  int? id;
  String username;
  String role;
  String fullName;

  User({
    this.id,
    required this.username,
    required this.role,
    required this.fullName,
  });

  // Factory constructor to instantiate concrete classes based on role
  factory User.fromJson(Map<String, dynamic> json) {
    if (json['role'] == 'ADMIN') {
      return Admin.fromJson(json);
    } else {
      return Cashier.fromJson(json);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role,
      'full_name': fullName,
    };
  }
}

class Admin extends User {
  Admin({
    super.id,
    required super.username,
    required super.fullName,
  }) : super(role: 'ADMIN');

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      username: json['username'],
      fullName: json['full_name'],
    );
  }
}

class Cashier extends User {
  Cashier({
    super.id,
    required super.username,
    required super.fullName,
  }) : super(role: 'CASHIER');

  factory Cashier.fromJson(Map<String, dynamic> json) {
    return Cashier(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      username: json['username'],
      fullName: json['full_name'],
    );
  }
}
