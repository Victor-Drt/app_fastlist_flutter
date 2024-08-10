import 'package:fast_list/firebase_options.dart';
import 'package:fast_list/pages/home_page.dart';
import 'package:fast_list/pages/login_page.dart';
import 'package:fast_list/services/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

// App
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthenticationService authenticationService =
        AuthenticationService();

    return MaterialApp(
      title: "FastList",
      theme: ThemeData(),
      home: authenticationService.isUserLoggedIn() ? const HomePage() : const LoginPage(),
    );
  }
}
