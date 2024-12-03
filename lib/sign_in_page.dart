import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'sign_up_page.dart';
import 'password_reset_page.dart';
import 'home_page.dart';  // HomePage importu
import 'admin_home_page.dart'; // AdminHomePage importu

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  
  String _email = '';
  String _password = '';
  
  bool _isLoading = false;

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      setState(() {
        _isLoading = true;
      });
      
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        // Giriş yaptıktan sonra kullanıcı rolünü kontrol et ve uygun sayfaya yönlendir
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          String role = await _getUserRole(user.uid);
          if (role == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminHomePage()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'user-not-found') {
          message = 'Kullanıcı bulunamadı.';
        } else if (e.code == 'wrong-password') {
          message = 'Yanlış şifre.';
        } else {
          message = 'Hata: ${e.message}';
        }
        Fluttertoast.showToast(msg: message);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _getUserRole(String userId) async {
    try {
      // Kullanıcı rolünü Firestore'dan al
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc['role'] ?? 'unknown';
      }
      return 'unknown';
    } catch (e) {
      print('Error fetching user role: $e');
      return 'unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Giriş Yap'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: _isLoading 
          ? Center(child: CircularProgressIndicator())
          : Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-posta'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'E-posta boş olamaz';
                    }
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return 'Geçerli bir e-posta girin';
                    }
                    return null;
                  },
                  onSaved: (value) => _email = value!.trim(),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Şifre'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Şifre boş olamaz';
                    }
                    if (value.length < 6) {
                      return 'Şifre en az 6 karakter olmalı';
                    }
                    return null;
                  },
                  onSaved: (value) => _password = value!.trim(),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _signIn,
                  child: Text('Giriş Yap'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => PasswordResetPage())
                    );
                  },
                  child: Text('Şifrenizi mi unuttunuz?'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => SignUpPage())
                    );
                  },
                  child: Text('Hesabınız yok mu? Kayıt Olun'),
                ),
              ],
            ),
          ),
      ),
    );
  }
}
