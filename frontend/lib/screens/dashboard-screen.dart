// Todas as importações necessárias
import 'package:flutter/material.dart';
import 'package:frontend/models/login-response.dart';
import 'package:frontend/screens/invoice-screen.dart';
import '../services/api-service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chart-screen.dart';
import 'wallet-screen.dart';
import 'profile-screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _api = ApiService();
  late LoginResponse user;
  bool isLoading = true;
  int _selectedIndex = 0;
  bool _showMenu = false;
  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('user');

    if (stored != null) {
      final decoded = jsonDecode(stored);
      user = LoginResponse.fromJson(decoded);
      await _handleFirstAccess();
      setState(() {
        _screens.addAll([
          HomeDashboard(user: user),
          const ChartScreen(),
          const WalletScreen(),
          const ProfileScreen(),
        ]);
        isLoading = false;
      });
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _handleFirstAccess() async {
    if (user.firstAccess) {
      final banks = await _api.getAvailableBanks();
      for (final bank in banks) {
        await _api.requestAuthorization(user.cpf, bank);
      }
      Future.delayed(Duration(seconds: 2), () async {
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Solicitação enviada'),
              content: const Text('As solicitações de acesso foram enviadas aos bancos.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          user.firstAccess = false;
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('user', jsonEncode(user.toJson()));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          IndexedStack(index: _selectedIndex, children: _screens),

          if (_showMenu)
            Positioned(
              top: 75,
              right: 20,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 180,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MenuItem(
                        icon: FontAwesomeIcons.arrowRightFromBracket,
                        label: 'Logout',
                        onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                      ),
                      _MenuItem(
                        icon: FontAwesomeIcons.circleQuestion,
                        label: 'Help',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: FontAwesomeIcons.gear,
                        label: 'Configurações',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 18),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 37, 36, 36),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 143, 138, 138).withOpacity(0.5),
                    spreadRadius: 4,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                iconSize: 20,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: Colors.blue,
                unselectedItemColor: Colors.white,
                currentIndex: _selectedIndex,
                type: BottomNavigationBarType.fixed,
                onTap: (index) => setState(() {
                  _showMenu = false;
                  _selectedIndex = index;
                }),
                items: const [
                  BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.house), label: ''),
                  BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.chartColumn), label: ''),
                  BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.wallet), label: ''),
                  BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.user), label: ''),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16)),
      child: Row(
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.inter(color: Colors.white)),
        ],
      ),
    );
  }
}

// Tela principal do dashboard
class HomeDashboard extends StatelessWidget {
  final LoginResponse user;

  const HomeDashboard({super.key, required this.user});

  @override
Widget build(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      final dashboard = context.findAncestorStateOfType<_DashboardScreenState>();
                      if (dashboard != null) {
                        dashboard.setState(() {
                          dashboard._selectedIndex = 3;
                          dashboard._showMenu = false;
                        });
                      }
                    },
                    child: const CircleAvatar(
                      backgroundImage: AssetImage('images/avatar.png'),
                      radius: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(user.name, style: GoogleFonts.inter(color: Colors.white, fontSize: 18)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      final dashboard = context.findAncestorStateOfType<_DashboardScreenState>();
                      if (dashboard != null) {
                        dashboard.setState(() => dashboard._showMenu = !dashboard._showMenu);
                      }
                    },
                    child: const Icon(FontAwesomeIcons.barsStaggered, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 45),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text('Your balance', style: GoogleFonts.poppins(color: Colors.white70)),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, bottom: 20),
                child: Text(
                  '\$ 12,897.00',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 37, 36, 36),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(65),
              topRight: Radius.circular(65),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text('September 2025',
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 16,
                children: const [
                  _MetricBox(title: 'Income', value: '\$4.200,00', color: Colors.green),
                  _MetricBox(title: 'Expenses', value: '\$2.800,00', color: Colors.red),
                  _MetricBox(title: 'Net', value: '\$1.400,00', color: Colors.blue),
                  _MetricBox(title: 'Budget', value: '65%', color: Colors.lightBlueAccent),
                ],
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text('Invoice',
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                constraints: const BoxConstraints(maxWidth: 410),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 54, 53, 53),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const InvoiceScreen()),
                            );
                          },
                          child: Text('View Details →',
                              style: GoogleFonts.inter(color: Colors.white70)),
                        ),
                      ),
                      Text(
                        '\$1.749,00',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text('Closes on ', style: GoogleFonts.inter(color: Colors.white70)),
                          Text('Oct 5', style: GoogleFonts.inter(color: Colors.redAccent)),
                          const SizedBox(width: 20),
                          Text('Due ', style: GoogleFonts.inter(color: Colors.white70)),
                          Text('Oct 10', style: GoogleFonts.inter(color: Colors.redAccent)),
                        ],
                      ),
                      const SizedBox(height: 23),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100), // espaço extra antes da navbar
            ],
          ),
        ),
      ],
    ),
  );
}
}

// Bloco das métricas financeiras
class _MetricBox extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _MetricBox({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 54, 52, 52),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Text(value,
              style: GoogleFonts.poppins(
                  color: color, fontSize: 19, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}