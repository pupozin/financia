import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api-service.dart'; // 🔁 importa a API
import '../models/login-response.dart'; // 👈 ISSO É ESSENCIAL



class IntroduceScreen extends StatefulWidget {
 final LoginResponse user;

  const IntroduceScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<IntroduceScreen> createState() => _IntroduceScreenState();
}

class _IntroduceScreenState extends State<IntroduceScreen> {
  final _controller = PageController();
  final _api = ApiService(); // ✅ instancia o serviço
  int _currentPage = 0;
  bool _isLoading = false;

  final _pages = <_IntroPage>[
    _IntroPage(
      image: 'images/earnings-introduce.png',
      title: 'Earnings',
      subtitle: 'Track your income and expenses',
    ),
    _IntroPage(
      image: 'images/dashboard-introduce.png',
      title: 'Dashboard',
      subtitle: 'See the best reports',
    ),
    _IntroPage(
      image: 'images/financia-introduce.png',
      title: 'Financia',
      subtitle: 'Make your finances clearer than ever.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

 Future<void> _next() async {
  if (_currentPage < _pages.length - 1) {
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    final authorizedBanks = await _api.getAuthorizedBanks(widget.user.cpf);

    if (authorizedBanks.isEmpty) {
      final availableBanks = await _api.getAvailableBanks();
      for (final bank in availableBanks) {
        await _api.requestAuthorization(widget.user.cpf, bank);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação enviada aos bancos.')),
      );
    }

   final prefs = await SharedPreferences.getInstance();
prefs.setString('user', jsonEncode(widget.user.toJson()));

Navigator.pushReplacementNamed(
  context,
  '/dashboard',
);



  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Erro ao verificar autorizações.')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    const blue = Color.fromARGB(255, 0, 0, 0);
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('images/background-introduce.png', fit: BoxFit.cover),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (ctx, i) {
                      final p = _pages[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 90),
                            SizedBox(
                              height: height * 0.35,
                              child: Image.asset(p.image, fit: BoxFit.contain),
                            ),
                            const SizedBox(height: 30),
                            Text(
                              p.title,
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              p.subtitle,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _isLoading ? null : _next,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : Text(
                              _currentPage == _pages.length - 1
                                  ? 'Get Started'
                                  : 'Next',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: blue,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == i ? 12 : 8,
                      height: _currentPage == i ? 12 : 8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 62),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroPage {
  final String image;
  final String title;
  final String subtitle;

  const _IntroPage({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}
