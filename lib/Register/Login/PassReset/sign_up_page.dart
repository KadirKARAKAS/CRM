import 'package:crm/messaging_services.dart';
import 'package:crm/Register/Login/PassReset/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _age = '';
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        String userId = userCredential.user!.uid;
        String? notificationToken =
            await MessagingServices().getNotificationToken();

        int userAge = int.tryParse(_age) ?? 0;

        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'uid': userId,
          'email': _email,
          'created_at': DateTime.now(),
          'role': 'user',
          'name': _email.split('@')[0],
          'notificationToken': notificationToken,
          'age': userAge,
        });

        Fluttertoast.showToast(msg: 'Kayıt başarılı!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInPage()),
        );
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'email-already-in-use') {
          message = 'Bu e-posta zaten kullanılıyor.';
        } else if (e.code == 'weak-password') {
          message = 'Şifre çok zayıf.';
        } else {
          message = 'Hata: ${e.message}';
        }
        Fluttertoast.showToast(msg: message);
      } catch (e) {
        Fluttertoast.showToast(msg: 'Bir hata oluştu: $e');
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const Text(
                          'Kayıt Ol',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 40),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'E-posta',
                            hintText: 'E-posta adresinizi girin',
                            prefixIcon: const Icon(Icons.email,
                                color: Colors.deepPurple),
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey[200],
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                          ),
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
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Şifre',
                            hintText: 'Şifrenizi girin',
                            prefixIcon: const Icon(Icons.lock,
                                color: Colors.deepPurple),
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey[200],
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                          ),
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
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Yaş',
                            hintText: 'Yaşınızı girin',
                            prefixIcon: const Icon(Icons.calendar_today,
                                color: Colors.deepPurple),
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey[200],
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Yaş boş olamaz';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Geçerli bir yaş girin';
                            }
                            return null;
                          },
                          onSaved: (value) => _age = value!.trim(),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _signUp,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Kayıt Ol',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Zaten bir hesabınız var mı? Geri Dön!',
                            style: TextStyle(color: Colors.deepPurple),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
