class UserModel {
  final String uid;
 // String name;
  String email;
  String? role;  // 'late' yerine 'String?' kullanalım

  UserModel({
    required this.uid,
  //  required this.name,
    required this.email,
    this.role,
  });

  // Firestore'dan gelen veriyi modelimize dönüştürme
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
  //    name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'], // Null değerleri kabul edebiliriz
    );
  }

  // Modeli Map'e çevirme
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
//      'name': name,
      'email': email,
      'role': role,  // null olabilir
    };
  }
}
