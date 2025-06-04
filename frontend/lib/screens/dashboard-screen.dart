import 'package:flutter/material.dart';
import 'package:frontend/models/login-response.dart';
import '../services/api-service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  final List<Widget> _screens = const [
    HomeDashboard(),
    ChartScreen(),
    WalletScreen(),
    ProfileScreen(),
  ];

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
      setState(() => isLoading = false);
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

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Solicitação enviada'),
          content: const Text('As solicitações de acesso foram enviadas aos bancos.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.house), label: ''),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.chartColumn), label: ''),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.wallet), label: ''),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.user), label: ''),
        ],
      ),
    );
  }
}

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundImage: AssetImage('images/avatar.png'),
                  radius: 24,
                ),
                const SizedBox(width: 12),
                const Text('Fernanda', style: TextStyle(color: Colors.white, fontSize: 18)),
                const Spacer(),
                Icon(FontAwesomeIcons.magnifyingGlass, color: Colors.white),
                const SizedBox(width: 12),
                Icon(FontAwesomeIcons.bars, color: Colors.white),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Your balance', style: TextStyle(color: Colors.white70)),
            const Text('\$ 12,897.00',
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('September 2025',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _MetricBox(title: 'Income', value: '\$4.200,00', color: Colors.green),
                      _MetricBox(title: 'Expenses', value: '\$2.800,00', color: Colors.red),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _MetricBox(title: 'Net', value: '\$1.400,00', color: Colors.blue),
                      _MetricBox(title: 'Budget', value: '65%', color: Colors.lightBlueAccent),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Invoice', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('\$1.749,00',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 4),
                  Text('Closes on Oct 5', style: TextStyle(color: Colors.redAccent)),
                  Text('Due Oct 10', style: TextStyle(color: Colors.redAccent)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _MetricBox({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.38,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Chart Screen', style: TextStyle(color: Colors.white)));
  }
}

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Wallet Screen', style: TextStyle(color: Colors.white)));
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Profile Screen', style: TextStyle(color: Colors.white)));
  }
}
