import 'package:flutter/material.dart';
import 'screens/home-screen.dart';
import 'screens/login-screen.dart';
import 'screens/signup-screen.dart';
import 'screens/dashboard-screen.dart';
import 'screens/introduce-screen.dart';

class FinanciaApp extends StatelessWidget {
  const FinanciaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => const DashboardScreen(),
         '/introduce': (context) => const IntroduceScreen(),
      },
    );
  }
}