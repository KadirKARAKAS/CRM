import 'package:crm/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;
  
  @override
  Widget build(BuildContext context) {
    String email = user?.email ?? 'Kullanıcı';
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Ana Sayfa'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => SignInPage())
              );
            },
          )
        ],
      ),
      body: Center(
        child: Text('Hoşgeldiniz, $email!'),
      ),
    );
  }
}
