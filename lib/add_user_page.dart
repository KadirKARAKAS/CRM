import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddUserPage extends StatefulWidget {
  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  String _selectedRole = 'uye';
Future<void> _addUser() async {
  String email = _emailController.text.trim();

  if (email.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('E-posta adresi boş olamaz.')),
    );
    return;
  }

  try {
    // Firebase Authentication'da kullanıcı oluşturma
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: "defaultPassword123", // Varsayılan bir şifre belirleniyor
    );

    String userId = userCredential.user!.uid;

    // Firestore'da kullanıcıyı kaydetme
    await _firestore.collection('users').doc(userId).set({
      'uid': userId,
      'email': email,
      'created_at': FieldValue.serverTimestamp(),
      'role': _selectedRole,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Kullanıcı başarıyla eklendi.')),
    );

    _emailController.clear();
    setState(() {
          Navigator.pop(context, true); 

    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Kullanıcı eklerken hata oluştu: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yeni Kullanıcı Ekle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('E-posta adresi:', style: TextStyle(fontSize: 16)),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(hintText: 'E-posta adresini girin'),
            ),
            SizedBox(height: 16),
            Text('Rol Seç:', style: TextStyle(fontSize: 16)),
            DropdownButton<String>(
              value: _selectedRole,
              items: ['admin', 'personel', 'uye']
                  .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addUser,
              child: Text('Kullanıcı Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}
