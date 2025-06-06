// lib/screens/home-dashboard.dart
import 'package:flutter/material.dart';
import 'package:frontend/models/dashboard-data.dart';
import 'package:frontend/models/login-response.dart';
import 'package:frontend/screens/invoice-screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeDashboard extends StatelessWidget {
  final LoginResponse user;
  final DashboardData data;
  final void Function()? onAvatarTap;
  final VoidCallback? onToggleMenu;

  const HomeDashboard({
    super.key,
    required this.user,
    required this.data,
    this.onAvatarTap,
    this.onToggleMenu,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

final unpaidCreditThisMonth = data.transactions.where((item) {
  final method = item['method']?.toString().toUpperCase();
  final paid = item['paid'];
  final dateStr = item['date'];
  if (method != 'CREDIT' || paid == true || dateStr == null) return false;

  final parsedDate = DateTime.tryParse(dateStr);
  if (parsedDate == null) return false;

  return parsedDate.month == now.month && parsedDate.year == now.year;
}).toList();

final invoiceTotal = unpaidCreditThisMonth.fold<double>(
  0.0,
  (sum, item) => sum + (item['amount'] ?? 0),
);
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
                      onTap: onAvatarTap,
                      child: const CircleAvatar(
                        backgroundImage: AssetImage('images/avatar.png'),
                        radius: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(user.name, style: GoogleFonts.inter(color: Colors.white, fontSize: 18)),
                    const Spacer(),
                    GestureDetector(
                      onTap: onToggleMenu,
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
                    '\$${data.balance.toStringAsFixed(2)}',
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
                    child: Text(
                      _getMonthYear(),
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 16,
                  children: [
                    _MetricBox(title: 'Income', value: '\$${data.income.toStringAsFixed(2)}', color: Colors.green),
                    _MetricBox(title: 'Expenses', value: '\$${data.expense.toStringAsFixed(2)}', color: Colors.red),
                    _MetricBox(title: 'Net', value: '\$${data.balance.toStringAsFixed(2)}', color: Colors.blue),
                    _MetricBox(
                      title: 'Budget',
                      value: _calculateBudgetPercentage(data.income, data.expense),
                      color: Colors.lightBlueAccent,
                    ),
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
                            print('🚨 FIRST 5 TRANSACTIONS:');
for (var t in data.transactions.take(5)) {
  print(t);
}
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => InvoiceScreen(
                                        invoiceTotal: invoiceTotal,
                                        transactions: data.transactions,
                                      ),
                                    ),
                                  );
                                },

                            child: Text('View Details →',
                                style: GoogleFonts.inter(color: Colors.white70)),
                          ),
                        ),
                        Text(
                         '\$${invoiceTotal.toStringAsFixed(2)}',
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
                            Text(_formatNextMonthDate(5), style: GoogleFonts.inter(color: Colors.redAccent)),
                            const SizedBox(width: 20),
                            Text('Due ', style: GoogleFonts.inter(color: Colors.white70)),
                            Text(_formatNextMonthDate(10), style: GoogleFonts.inter(color: Colors.redAccent)),
                          ],
                        ),
                        const SizedBox(height: 23),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _calculateBudgetPercentage(double income, double expense) {
  if (income == 0) return '0%';
  final percent = ((income - expense) / income) * 100;
  return '${percent.toStringAsFixed(0)}%';
}


  String _getMonthYear() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[now.month - 1]} ${now.year}';
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

String _formatNextMonthDate(int day) {
  final now = DateTime.now();
  final nextMonth = (now.month == 12) ? 1 : now.month + 1;
  final year = (now.month == 12) ? now.year + 1 : now.year;
  final date = DateTime(year, nextMonth, day);

  final monthName = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ][date.month - 1];

  return '$monthName ${date.day}';
}
