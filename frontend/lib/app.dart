import 'package:flutter/material.dart';
import 'models/login-response.dart'; // <-- IMPORTANTE!
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
        '/dashboard': (context) {
  final args = ModalRoute.of(context)!.settings.arguments;
  if (args is LoginResponse) {
    return DashboardScreen(user: args);
  } else {
    return const HomeScreen(); // ou LoginScreen
  }
},
        '/introduce': (context) {
           final args = ModalRoute.of(context)!.settings.arguments as LoginResponse;
           return IntroduceScreen(user: args);
         },

      },
    );
  }
}
