import 'package:crm/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'sign_in_page.dart'; // SignInPage'inizi ekleyin

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase'i başlatıyoruz
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SignInPage(),));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SignInPage(), // Başlangıç sayfası olarak SignInPage
    );
  }
}
