class UserModel {
  final String uid;
 String ?name;
  String?email;
  String? role;  

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'], 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role, 
    };
  }
}
