import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
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

  // validações
  bool _nameValid = false;
  bool _cpfValid = false;
  bool _emailValid = false;
  bool _pwdValid = false;
  bool _pwdVisible = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(() {
      setState(() => _nameValid = _nameCtrl.text.trim().isNotEmpty);
    });
    _cpfCtrl.addListener(() {
      final text = _cpfCtrl.text.replaceAll(RegExp(r"\D"), '');
      setState(() => _cpfValid = text.length == 11);
    });
    _emailCtrl.addListener(() {
      setState(() => _emailValid = RegExp(r"^[^@]+@[^@]+\.[^@]+$").hasMatch(_emailCtrl.text));
    });
    _pwdCtrl.addListener(() {
      setState(() => _pwdValid = _pwdCtrl.text.length >= 6);
    });
  }

 void _handleSignup() async {
    final ok = await _api.signup(
      name: _nameCtrl.text,
      cpf: _cpfCtrl.text,
      email: _emailCtrl.text,
      password: _pwdCtrl.text,
    );
    if (!ok) {
      setState(() => _error = 'Signup failed');
      return;
    }

    final loginResult = await _api.login(
      email: _emailCtrl.text,
      password: _pwdCtrl.text,
    );
    if (loginResult == null) {
      setState(() => _error = 'Auto login failed');
      return;
    }

    final route = loginResult.firstAccess ? '/introduce' : '/dashboard';
    Navigator.pushReplacementNamed(context, route);
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

          // Painel branco
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: _BottomCurveClipper(),
              child: Container(
                height: height * 0.6,
                color: Colors.white,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(FontAwesomeIcons.chevronLeft, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 100),
                   Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Text(
                      'Create\nAccount',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ),

                  const Spacer(),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(_error!, style: const TextStyle(color: Colors.red)),
                    ),
                  // Name
                  TextField(
                    controller: _nameCtrl,
                    style: GoogleFonts.inter(fontSize: 14, color: _nameValid ? blue : Colors.black87),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      prefixIcon: Icon(FontAwesomeIcons.user, size: 20, color: _nameValid ? blue : Colors.grey),
                      suffixIcon: _nameValid ? Icon(FontAwesomeIcons.checkCircle, size: 20, color: blue) : null,
                      hintText: 'Name',
                      hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey[500]),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _nameValid ? Colors.white : Colors.grey.shade100, width: 2)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _nameValid ? Colors.white : Colors.grey.shade100, width: 2)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.white, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // CPF
                  TextField(
                    controller: _cpfCtrl,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.inter(fontSize: 14, color: _cpfValid ? blue : Colors.black87),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      prefixIcon: Icon(FontAwesomeIcons.idCard, size: 20, color: _cpfValid ? blue : Colors.grey),
                      suffixIcon: _cpfValid ? Icon(FontAwesomeIcons.checkCircle, size: 20, color: blue) : null,
                      hintText: 'CPF',
                      hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey[500]),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _cpfValid ? Colors.white : Colors.grey.shade100, width: 2)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _cpfValid ? Colors.white : Colors.grey.shade100, width: 2)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.white, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Email
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.inter(fontSize: 14, color: _emailValid ? blue : Colors.black87),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      prefixIcon: Icon(FontAwesomeIcons.envelope, size: 20, color: _emailValid ? blue : Colors.grey),
                      suffixIcon: _emailValid ? Icon(FontAwesomeIcons.checkCircle, size: 20, color: blue) : null,
                      hintText: 'Email',
                      hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey[500]),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _emailValid ? Colors.white : Colors.grey.shade100, width: 2)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _emailValid ? Colors.white : Colors.grey.shade100, width: 2)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.white, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Password
                  TextField(
                    controller: _pwdCtrl,
                    obscureText: !_pwdVisible,
                    style: GoogleFonts.inter(fontSize: 14, color: _pwdValid ? blue : Colors.black87),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      prefixIcon: Icon(FontAwesomeIcons.lock, size: 20, color: _pwdVisible || _pwdValid ? blue : Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(_pwdVisible ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye, size: 20, color: _pwdValid ? blue : Colors.grey),
                        onPressed: () => setState(() => _pwdVisible = !_pwdVisible),
                      ),
                      hintText: 'Password',
                      hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey[500]),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _pwdValid ? Colors.white : Colors.grey.shade100, width: 2)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _pwdValid ? Colors.white : Colors.grey.shade100, width: 2)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.white, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18), backgroundColor: blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        onPressed: _handleSignup,
                        child: Text('Sign Up', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
