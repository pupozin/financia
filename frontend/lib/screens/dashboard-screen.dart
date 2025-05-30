import 'package:flutter/material.dart';
import '../models/login-response.dart';
import '../services/api-service.dart';

class DashboardScreen extends StatefulWidget {
  final LoginResponse user;

  const DashboardScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    _handleFirstAccess();
  }

  Future<void> _handleFirstAccess() async {
    if (widget.user.firstAccess) {
      final banks = await _api.getAvailableBanks();

      for (final bank in banks) {
        await _api.requestAuthorization(widget.user.cpf, bank);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const Center(child: Text('Welcome to your dashboard!')),
    );
  }
}
