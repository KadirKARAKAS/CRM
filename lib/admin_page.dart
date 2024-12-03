import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  Future<void> addUser() async {
    try {
      String email = _emailController.text;
      String role = _roleController.text;

      // Yeni kullanıcıyı Firestore'a ekleyelim
      await FirebaseFirestore.instance.collection('users').add({
        'email': email,
        'role': role,
        'createdAt': Timestamp.now(),
      });

      print("Kullanıcı başarıyla eklendi.");
    } catch (e) {
      print("Kullanıcı eklerken hata oluştu: $e");
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      // Kullanıcıyı Firestore'dan silelim
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      print("Kullanıcı başarıyla silindi.");
    } catch (e) {
      print("Kullanıcı silinirken hata oluştu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Sayfası'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Kullanıcı E-posta'),
            ),
            TextField(
              controller: _roleController,
              decoration: InputDecoration(labelText: 'Kullanıcı Rolü (admin/personel/user)'),
            ),
            ElevatedButton(
              onPressed: addUser,
              child: Text('Kullanıcı Ekle'),
            ),
            // Kullanıcıları listeleme ve silme işlemi
            ElevatedButton(
              onPressed: () {
                // Burada kullanıcıları listeleyebilir ve silebilirsiniz
              },
              child: Text('Kullanıcıları Listele/Sil'),
            ),
          ],
        ),
      ),
    );
  }
}
