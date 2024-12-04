import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'user_model.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kullanıcı listesi
  List<UserModel> _users = [];

  // Kullanıcı listesini döndürür
  List<UserModel> get users => _users;

  // Kullanıcıları Firestore'dan çeker
  Future<void> fetchUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      _users = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (e) {
      print("Kullanıcılar alınırken hata oluştu: $e");
    }
  }

  // Kullanıcıyı siler
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      _users.removeWhere((user) => user.id == userId);
      notifyListeners();
    } catch (e) {
      print("Kullanıcı silinirken hata oluştu: $e");
    }
  }

  // Kullanıcı rolünü günceller
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({'role': newRole});
      int index = _users.indexWhere((user) => user.id == userId);
      if (index != -1) {
        _users[index] = UserModel(
          id: _users[index].id,
          name: _users[index].name,
          email: _users[index].email,
          role: newRole,
        );
        notifyListeners();
      }
    } catch (e) {
      print("Rol güncellenirken hata oluştu: $e");
    }
  }
}
