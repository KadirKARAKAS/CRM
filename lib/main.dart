import 'package:crm/firebase_options.dart';
import 'package:crm/home_page.dart';
import 'package:crm/model/user_provider.dart';
import 'package:crm/sign_up_page.dart';
import 'package:firebase_core/firebase_core.dart';  // Firebase başlatma için import
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); 

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        routes: {
          '/login': (context) => SignUpPage(),
          '/home': (context) => HomePage(),

    
        },
      ),
    ),
  );
}
