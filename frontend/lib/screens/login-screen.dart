// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api-service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _api = ApiService();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _emailValid = false;
  bool _pwdValid = false;
  bool _pwdVisible = false;

  @override
  void initState() {
    super.initState();
    // Listener para validar senha com mais de 6 caracteres
    _pwdCtrl.addListener(() {
      setState(() => _pwdValid = _pwdCtrl.text.length > 5);
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    const blue = Color(0xFF0066FF);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fundo completo
          Image.asset('images/fundo-home.png', fit: BoxFit.cover),

          // Painel branco na base com curva convexa para fora no topo
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: _BottomCurveClipper(),
              child: Container(
                height: height * 0.5,
                color: Colors.white,
              ),
            ),
          ),

          // Conteúdo: back button, título e inputs no fim
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Botão de voltar
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(FontAwesomeIcons.chevronLeft, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 100),

                  // Título "Welcome Back"
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Text(
                      'Welcome\nBack',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Email input
                  TextField(
                    controller: _emailCtrl,
                    onChanged: (v) => setState(() => _emailValid = RegExp(r"^[^@]+@[^@]+\.[^@]+$").hasMatch(v)),
                    style: GoogleFonts.inter(fontSize: 14, color: _emailValid ? blue : Colors.black87),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      prefixIcon: Icon(
                        FontAwesomeIcons.envelope,
                        size: 15,
                        color: _emailValid ? blue : Colors.grey,
                      ),
                      suffixIcon: _emailValid
                          ? Icon(FontAwesomeIcons.checkCircle, size: 15, color: blue)
                          : null,
                      hintText: 'name@example.com',
                      hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey[500]),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: _emailValid ? Colors.white : Colors.grey.shade100, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: _emailValid ? Colors.white : Colors.grey.shade100, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password input
                  TextField(
                    controller: _pwdCtrl,
                    obscureText: !_pwdVisible,
                    style: GoogleFonts.inter(fontSize: 14, color: _pwdValid ? blue : Colors.black87),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      prefixIcon: Icon(
                        FontAwesomeIcons.lock,
                        size: 15,
                        color: _pwdValid ? blue : Colors.grey,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _pwdVisible ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                          size: 15,
                          color: _pwdValid ? blue : Colors.grey,
                        ),
                        onPressed: () => setState(() => _pwdVisible = !_pwdVisible),
                      ),
                      hintText: 'Password',
                      hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey[500]),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: _pwdValid ? blue : Colors.grey.shade100, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: _pwdValid ? blue : Colors.grey.shade100, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botão Login a 30px do bottom
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                     onPressed: () async {
  final result = await _api.login(
    email: _emailCtrl.text,
    password: _pwdCtrl.text,
  );
  if (result == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Credenciais inválidas')),
    );
    return;
  }

  if (result.firstAccess) {
    // se for o primeiro acesso, abre a tela de introdução
    Navigator.pushReplacementNamed(context, '/introduce');
  } else {
    // senão vai direto pro dashboard
    Navigator.pushReplacementNamed(context, '/dashboard');
  }
},
                        child: Text(
                          'Log In',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Clipper para painel branco com curva convexa no topo
class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(size.width / 2, 80, size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}