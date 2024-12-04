import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';  // UserModel sınıfını import ediyoruz

class UserProvider with ChangeNotifier {
  List<UserModel> _users = [];

  List<UserModel> get users => _users;

  // Kullanıcıları Firestore'dan çekme
  Future<void> fetchUsers() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();
      print('Veriler başarıyla çekildi');
      
      _users = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      notifyListeners();  // Veriler güncellenince dinleyicilere bildirim yap
    } catch (e) {
      print("Kullanıcılar çekilirken hata: $e");
    }
  }

  // Kullanıcıyı silme
  Future<void> deleteUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      
      _users.removeWhere((user) => user.uid == userId);  // Kullanıcıyı listeden silme

      notifyListeners();  // Listeyi güncelleyip dinleyicilere bildirim yap
    } catch (e) {
      print("Kullanıcı silinirken hata: $e");
    }
  }

  // Kullanıcı rolünü güncelleme
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({'role': newRole});

      int userIndex = _users.indexWhere((user) => user.uid == userId);
      if (userIndex >= 0) {
        _users[userIndex].role = newRole;  // Listede rol güncelleme
        notifyListeners();  // Listeyi güncelleyip dinleyicilere bildirim yap
      }
    } catch (e) {
      print("Rol güncellenirken hata: $e");
    }
  }

  // Yeni kullanıcı ekleme
  Future<void> addUser(UserModel user) async {
    try {
      // Firestore'a kullanıcı ekleme
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(user.toMap());

      _users.add(user);  // Kullanıcıyı listeye ekleme

      notifyListeners();  // Listeyi güncelleyip dinleyicilere bildirim yap
    } catch (e) {
      print("Kullanıcı eklenirken hata: $e");
    }
  }

  // Kullanıcı bilgilerini güncelleme
  Future<void> updateUser(UserModel updatedUser) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(updatedUser.uid)
          .update(updatedUser.toMap());

      int userIndex = _users.indexWhere((user) => user.uid == updatedUser.uid);
      if (userIndex >= 0) {
        _users[userIndex] = updatedUser;  // Listede kullanıcıyı güncelleme
        notifyListeners();  // Listeyi güncelleyip dinleyicilere bildirim yap
      }
    } catch (e) {
      print("Kullanıcı güncellenirken hata: $e");
    }
  }
}
