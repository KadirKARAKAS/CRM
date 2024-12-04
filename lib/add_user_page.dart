import 'package:crm/admin_home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:crm/model/user_provider.dart';
import 'package:crm/model/user_model.dart';

class AddUserPage extends StatefulWidget {
  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
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
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: "123456",
    );

   String userId = userCredential.user!.uid;

    Provider.of<UserProvider>(context, listen: false).addUser(UserModel(
      uid: userId,
      email: email,
      role: _selectedRole,
    //  name: email.split('@')[0],
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Kullanıcı başarıyla eklendi.')),
    );

    _emailController.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AdminHomePage()),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Kullanıcı eklerken hata oluştu: $e')),
    );

  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        title: Text(
          'Yeni Kullanıcı Ekle',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.blueAccent, // Ana renk mavi tonları
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('E-posta adresi:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'E-posta adresini girin',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.blue[50],
                contentPadding: EdgeInsets.all(14),
              ),
            ),
            SizedBox(height: 16),

            Text('Rol Seç:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),

            Container(
              width: double.infinity, 
              padding: EdgeInsets.symmetric(horizontal: 8), 
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent, width: 1),
              ),
              child: DropdownButton<String>(
                value: _selectedRole,
                items: ['admin', 'personel', 'uye']
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              role.toUpperCase(),
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
                isExpanded: true, 
                underline: SizedBox(),
                icon: Icon(Icons.arrow_drop_down_circle, color: Colors.blueAccent),
                iconSize: 30,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blueAccent),
              ),
            ),
            SizedBox(height: 16),

            Center(
              child: ElevatedButton(
                onPressed: _addUser,
                child: Text(
                  'Kullanıcı Ekle',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40), backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
