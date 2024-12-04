class UserModel {
  final String uid;
  String? name;
  String? email;
  String? role;
  int? age;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.role,
    this.age,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'],
      age: map['age'] != null ? int.tryParse(map['age'].toString()) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'age': age,
    };
  }
}
