import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'sign_up_page.dart';
import 'password_reset_page.dart';

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
        Navigator.pushReplacementNamed(context, '/home');
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
