import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';  // UserModel sınıfını import ediyoruz

class UserProvider with ChangeNotifier {
  List<UserModel> _users = [];

  List<UserModel> get users => _users;

  // Firestore'dan kullanıcıları çekme
  Future<void> fetchUsers() async {
    try {
      // Firestore'dan veriyi çekme
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();

      // Verileri alıp listeye dönüştürme
      _users = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // UI'ı güncellemek için notifyListeners() çağırıyoruz
      notifyListeners();
    } catch (e) {
      print("Kullanıcılar çekilirken hata: $e");
    }
  }

  // Kullanıcı silme
  Future<void> deleteUser(String userId) async {
    try {
      // Firestore'dan kullanıcıyı silme
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      
      // Silinen kullanıcıyı liste üzerinden çıkarma
      _users.removeWhere((user) => user.uid == userId);

      // UI'ı güncellemek için notifyListeners() çağırıyoruz
      notifyListeners();
    } catch (e) {
      print("Kullanıcı silinirken hata: $e");
    }
  }

  // Kullanıcı rolünü güncelleme
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      // Firestore'da rol güncelleme
      await FirebaseFirestore.instance.collection('users').doc(userId).update({'role': newRole});

      // Listeyi güncelleyip UI'ı yeniliyoruz
      int userIndex = _users.indexWhere((user) => user.uid == userId);
      if (userIndex >= 0) {
        _users[userIndex].role = newRole;
        notifyListeners();
      }
    } catch (e) {
      print("Rol güncellenirken hata: $e");
    }
  }

  // Kullanıcı ekleme (isteğe bağlı)
  Future<void> addUser(UserModel user) async {
    try {
      // Firestore'a yeni kullanıcı ekleme
      await FirebaseFirestore.instance.collection('users').add(user.toMap());

      // Listeyi güncelleme
      _users.add(user);
      notifyListeners();
    } catch (e) {
      print("Kullanıcı eklenirken hata: $e");
    }
  }
}
