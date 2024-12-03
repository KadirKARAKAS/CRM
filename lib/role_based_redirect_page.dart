import 'package:crm/admin_home_page.dart';
import 'package:crm/home_page.dart';
import 'package:crm/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoleBasedRedirectPage extends StatefulWidget {
  @override
  _RoleBasedRedirectPageState createState() => _RoleBasedRedirectPageState();
}

class _RoleBasedRedirectPageState extends State<RoleBasedRedirectPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> _getUserRole(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc['role'] ?? 'unknown';
      }
      return 'unknown';
    } catch (e) {
      print('Error fetching user role: $e');
      return 'unknown';
    }
  }

  Future<void> _redirectBasedOnRole() async {
    User? user = _auth.currentUser;

    if (user != null) {
      // Kullanıcı rolü alınır
      String role = await _getUserRole(user.uid);

      // Yönlendirmeyi build işleminden sonra yapıyoruz
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (role == 'admin') {
          // Admin rolü varsa AdminHomePage'e yönlendirme yapılır
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminHomePage()),
          );
        } else {
          // Normal kullanıcı için HomePage'e yönlendirme yapılır
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      });
    } else {
      // Oturum açmamış kullanıcı için SignInPage'e yönlendirme yapılır
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInPage()),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Kullanıcı rolüne göre yönlendirmeyi başlatıyoruz
    _redirectBasedOnRole();
  }

  @override
  Widget build(BuildContext context) {
    // Yönlendirme işlemi tamamlanana kadar yükleme göstergesi
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
