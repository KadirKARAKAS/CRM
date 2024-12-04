import 'package:crm/firebase_options.dart';
import 'package:crm/home_page.dart';
import 'package:crm/model/user_provider.dart';
import 'package:crm/Register/Login/PassReset/sign_in_page.dart';
import 'package:firebase_core/firebase_core.dart';
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
          '/login': (context) => SignInPage(),
          '/home': (context) => HomePage(),
        },
      ),
    ),
  );
}
