import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crm/messaging_services.dart';
import 'package:crm/password_reset_page.dart';
import 'package:crm/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crm/admin_home_page.dart';
import 'package:crm/personel_page.dart'; 
import 'package:crm/home_page.dart'; 

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}



class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;



  Future<void> _signIn() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;

        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        String role = userDoc['role'];

        print("Kullanıcı rolü: $role"); 
String? notificationToken =
        await MessagingServices().getNotificationToken();

              await FirebaseFirestore.instance.collection('users').doc(uid).update({'notificationToken': notificationToken});

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminHomePage()),
          );
        } else if (role == 'personel') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PersonelPage()), 
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()), 
          );
        }
      }
    } catch (e) {
      print("Giriş hatası: $e"); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eksik veya hatalı bilgi!')),
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
                Text(
                  'Hoşgeldiniz',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 40),
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
                ElevatedButton(
                  onPressed: _signIn,
                  child: Text('Giriş Yap',style: TextStyle(color: Colors.black),),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  },
                  child: Text('Hesabınız yok mu? Kayıt Olun'),
                ),
                 TextButton(
                  onPressed: () {
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

  // Future<void> sendNotification() async {
  //   final String serverKey = 'MIIEvgIBADANBgkqhkiG9ETDw0BAQEFAASCBKgwggSkXCVAgEAAoIBAQDlCDSii8NieyTSsm6iX5d0UwtKGEz7P5Ixs4/IbiinSnfAJ7A0vbc7EXd+CH1FkJC7jVgqowHc8H1TPHF6B+n9bn+sd38QvYM7wmdp6KqC9WLPMbC/ir9LfUIH3cam3XSqgKCLIJPDEVFSEPAuRrJsA792Tl+6l9aPi9fhOSfrNVjv3mwMV9onPoZInpoN24LXihjs+Y/nlO2cB7oN02X+rYDQsH1jhYGlaCbpq5jHw9ar1nhBRAEFyE0oelwJcHdmTPDSumISjRrKnKh/Kxx3ThIWRAqmuH7wQpxZC8OIfA7mpMmwuJLOk7muQ8l8Jt8iTkRCS1EzCMTals82AthkyEOg5B9bfAgMBAAECggEADDtaqZKK1C7i2FSxUuKgCApXVAt7pRaG4ag62+ZhDIDG8SLf7jxjfMleKGL87u4h06PIDq3T8fHGB7e52RJ6eGuvW0WINnCdptnJCiPPp7v7MXa5fQPzThfAGJ+tENiT4vR2F0YZrWY3h/Qb4xTsDFGVHGMwTg5JGnWdPfmeQjd8v9ITUoNzGdKs0ra9l4pvLkk1ldTHdqcPiAS4U9EgWYh9yEbFGCghWKBotcamlsupIa56L8HF/ZpSHB/iOJNuh88WZDAduvctHvW7GGU5oNhTfpU1M1alpIhg0JifD4Oej2TObU94+Nfav/cPeWRaEWRZ5XVHgIrA2tt1ZTDDnl6OQ92egQKBgQD3er2oiFv1v4OY6UTT+pAb4qooEbnqnL+KCQiRyYzsvNwImc/aej9nyceGXLDthM+RsC+8cGAuXNZloSnfyAI4GfePtWKQs0lc6W3Fkp0zwgrIPEgEFOmXVGLtUv3OowLgLn5vyRzX/3s32Iooqb6un++b8Sy8TmEzWsf4xvmAEQKBgQDs7ORXmpny5KCSAyMuKZ7djwXaZV1+8jyGI3X3ZJGllJYNdFgkOCtOtUrZsslxPGZRu1Ct5DNy0iidoWft3o9qpHZurf3jd1jvTIDB5oA6KqseVMdKHe8MzJtukAZ0bS04zxpTDE4ns7yrFTXK5j5KvkrBSBxCtAxChdmDPWBjdvX7wKBgQDkx6IW79/bYe1c6aCIOmUIclUM774oRjnHeKxkYaeWnszmYpLFDSgaYW3DJ2MkYBenPfITSOuRUJ+emgtk5bgvdsnmHy98R1G1w9GHyQ7sbyCalSeaJl7/V7KQZJ1fblDVQAYAfzHb+EFHkjW+e5VcR1wxlBXgCrFO0Uh2EjNKkQKBgELLFiTMZRJg/XQ+qlCsKIzBK22zqhb2bSaqRI652kUcBwceUPkFWQt/U042k5YOtNzWO3CJGtUSbOF2LHQuHigvx6V2zS9NK0hHYFdZQKSXH6NcwUTBejoNA/1DbZqBZYqZ/FZmDxnDE7gFhn7Yap6CN38m+UKaAba3eI8pmwzpAoGBAIkjo2/EzlVPSytQCwa9fcSPR0qp9p/qc3hxUIwimk9NY0YzsKzAxdlM4RvUbJQR2ZJTPE6TqWRP9e53LWof+NPUy6UnJlDKwHM3VH1UeVMuy8VCbj7r9x14pc1KGKc2qg0LGucB30bG+GOAFXCBmEqDqhMotPLFpZYIM4+Fgdrg'; 
  // final String fcmToken = 'dHo7pSEsatRLyU9eVnx2ore4:APA91bFqO-kY_8B3AjyPz_RXCKXcEErZ8HIUjZzTvpMkqzb1dj_OXApNRCClmSptS-5eCxSDatldUUUdc6NX8-VlI3HOmA0sprkEcsJ3LoI_UFcb6cdNs7FS4OtMNIDs';
  //   const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

  //   try {
  //     final response = await http.post(
  //       Uri.parse(fcmUrl),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'key=$serverKey',
  //       },
  //       body: jsonEncode({
  //         'to': fcmToken, 
  //         'notification': {
  //           'title': 'Bildirim Başlığı',
  //           'body': 'Bu bir test bildirimi.',
  //         },
  //         'data': {
  //           'customKey': 'customValue', 
  //         },
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       print('Bildirim başarıyla gönderildi: ${response.body}');
  //     } else {
  //       print('Hata oluştu: ${response.statusCode}, ${response.body}');
  //     }
  //   } catch (e) {
  //     print('İstek gönderilemedi: $e');
  //   }
  // }
}
