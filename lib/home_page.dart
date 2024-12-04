import 'package:crm/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ana Sayfa'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); // Firebase çıkış işlemi
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignUpPage()), // Login sayfasına yönlendir
              );
            },
          )
        ],
      ),
      body: Center(
        child: user == null
            ? CircularProgressIndicator() // Kullanıcı girişi yapılmamışsa yükleme animasyonu göster
            : Text('Hoşgeldiniz, ${user?.email ?? 'Kullanıcı'}!'),
      ),
    );
  }
}
