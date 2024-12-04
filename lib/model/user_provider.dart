import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';  // UserModel sınıfını import ediyoruz

class UserProvider with ChangeNotifier {
  List<UserModel> _users = [];

  List<UserModel> get users => _users;

  Future<void> fetchUsers() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();

      _users = [];
      _users = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      notifyListeners();
    } catch (e) {
      print("Kullanıcılar çekilirken hata: $e");
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      
      _users.removeWhere((user) => user.uid == userId);  

      notifyListeners();
    } catch (e) {
      print("Kullanıcı silinirken hata: $e");
    }
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({'role': newRole});

      int userIndex = _users.indexWhere((user) => user.uid == userId);
      if (userIndex >= 0) {
        _users[userIndex].role = newRole;
        notifyListeners();
      }
    } catch (e) {
      print("Rol güncellenirken hata: $e");
    }
  }

  Future<void> addUser(UserModel user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(user.toMap());

      _users.add(user);
      notifyListeners();
    } catch (e) {
      print("Kullanıcı eklenirken hata: $e");
    }
  }
}
