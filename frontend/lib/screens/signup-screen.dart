import 'package:flutter/material.dart';
import '../services/api-service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _api = ApiService();
  String? _error;

  void _handleSignup() async {
    final ok = await _api.signup(
      name: _nameCtrl.text,
      cpf: _cpfCtrl.text,
      email: _emailCtrl.text,
      password: _pwdCtrl.text,
    );
    if (ok) {
      // after signup, automatically login
      final logged = await _api.login(
        email: _emailCtrl.text,
        password: _pwdCtrl.text,
      );
      if (logged) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        setState(() => _error = 'Auto login failed');
      }
    } else {
      setState(() => _error = 'Signup failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cpfCtrl,
                decoration: const InputDecoration(labelText: 'CPF'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pwdCtrl,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _handleSignup,
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
