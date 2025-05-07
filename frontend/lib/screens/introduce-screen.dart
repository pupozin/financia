// lib/screens/introduce_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroduceScreen extends StatefulWidget {
  const IntroduceScreen({Key? key}) : super(key: key);

  @override
  State<IntroduceScreen> createState() => _IntroduceScreenState();
}

class _IntroduceScreenState extends State<IntroduceScreen> {
  final _controller = PageController();
  int _currentPage = 0;

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

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF0066FF);
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // full-screen background
          Image.asset(
            'images/background-introduce.png',
            fit: BoxFit.cover,
          ),

          SafeArea(
            child: Column(
              children: [
                // page view
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
                            const SizedBox(height: 90), // move image down
                            // fixed-height image
                            SizedBox(
                              height: height * 0.35,
                              child: Image.asset(p.image, fit: BoxFit.contain),
                            ),
                            const SizedBox(height: 30), // space before text
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

                const SizedBox(height: 8), // button slightly higher

                // Next / Get Started button — narrower
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
                      onPressed: _next,
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: blue,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48), // more space before dots

                // page-indicator dots
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
