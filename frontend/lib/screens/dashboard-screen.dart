// dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend/models/login-response.dart';
import 'package:frontend/models/dashboard-data.dart';
import 'package:frontend/screens/chart-screen.dart';
import 'package:frontend/screens/invoice-screen.dart';
import 'package:frontend/screens/profile-screen.dart';
import 'package:frontend/screens/wallet-screen.dart';
import 'package:frontend/screens/home-dashboard.dart';
import '../services/api-service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _api = ApiService();
  late LoginResponse user;
  DashboardData? dashboardData;
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
      await _loadDashboardData();
      setState(() {
        _screens.addAll([
            HomeDashboard(
              user: user,
              data: dashboardData!,
              onAvatarTap: () => setState(() => _selectedIndex = 3),
              onToggleMenu: () => setState(() => _showMenu = !_showMenu),
            ),
            ChartScreen(
                userName: user.name,
                onAvatarTap: () => setState(() => _selectedIndex = 3),
                onToggleMenu: () => setState(() => _showMenu = !_showMenu),
              ),
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
      Future.delayed(const Duration(seconds: 2), () async {
        if (mounted) {
         showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: Colors.black,
              titleTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              contentTextStyle: GoogleFonts.inter(color: Colors.white70),
              title: const Text('Solicitação enviada'),
              content: const Text('As solicitações de acesso foram enviadas aos bancos.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK', style: GoogleFonts.inter(color: Colors.white)),
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

  Future<void> _loadDashboardData() async {
    final now = DateTime.now();
  try {
  dashboardData = await _api.getDashboardData(user.cpf, now.month, now.year);
} catch (e) {
  print('Erro ao carregar dashboard: $e');
  dashboardData = DashboardData(income: 0, expense: 0, balance: 0, invoiceTotal: 0, transactions: []);
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
