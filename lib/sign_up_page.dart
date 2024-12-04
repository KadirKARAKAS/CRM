import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crm/password_reset_page.dart';
import 'package:crm/sign_in_page.dart';
import 'package:crm/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crm/admin_home_page.dart';
import 'package:crm/personel_page.dart'; // Personel sayfası
import 'package:crm/home_page.dart'; // HomePage'e yönlendirme

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  // Giriş işlemi
  Future<void> _signIn() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Giriş başarılıysa
      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;

        // Kullanıcı rolünü Firestore'dan al
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        String role = userDoc['role'];

        print("Kullanıcı rolü: $role"); // Hata ayıklamak için log ekleyin

        // Rolüne göre doğru sayfaya yönlendir
        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminHomePage()), // Admin sayfasına yönlendir
          );
        } else if (role == 'personnel') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PersonelPage()), // Personel sayfasına yönlendir
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()), // User sayfasına yönlendir (HomePage)
          );
        }
      }
    } catch (e) {
      print("Giriş hatası: $e"); // Hata mesajını loglara yazdırın
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Giriş yapılırken bir hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo veya Başlık
                Text(
                  'Hoşgeldiniz',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 40),
                // E-posta alanı
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'E-posta adresiniz',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                SizedBox(height: 20),
                // Şifre alanı
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Şifreniz',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                SizedBox(height: 20),
                // Giriş butonu
                ElevatedButton(
                  onPressed: _signIn,
                  child: Text('Giriş Yap'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Kayıt olma linki
                TextButton(
                  onPressed: () {
                    // Kayıt olma sayfasına yönlendirme
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignInPage()),
                    );
                  },
                  child: Text('Hesabınız yok mu? Kayıt Olun'),
                ),
                 TextButton(
                  onPressed: () {
                    // Kayıt olma sayfasına yönlendirme
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PasswordResetPage()),
                    );
                  },
                  child: Text('Şifremi unuttum!'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
