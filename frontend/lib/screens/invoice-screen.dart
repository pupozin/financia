import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../helpers/categoryhelper.dart';
import 'package:frontend/screens/monthly-invoices-screen.dart';

class InvoiceScreen extends StatelessWidget {
  final double invoiceTotal;
  final List<Map<String, dynamic>> transactions;

  const InvoiceScreen({
    super.key,
    required this.invoiceTotal,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final filtered = transactions.where((item) {
      final dateStr = item['date'];
      final timeStr = item['time'];
      final method = item['method'];
      if (dateStr == null || timeStr == null || method == null) return false;

      final methodUpper = method.toString().toUpperCase();
      final category = item['category']?.toString().toLowerCase() ?? '';

      final isCredit = methodUpper == 'CREDIT';
      final isFaturaDebit = methodUpper == 'DEBIT' && category == 'invoice';
      return isCredit || isFaturaDebit;
    }).toList();

    filtered.sort((a, b) {
      final aDate = DateTime.tryParse('${a['date']} ${a['time']}') ?? DateTime(2000);
      final bDate = DateTime.tryParse('${b['date']} ${b['time']}') ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });

   
    final Map<DateTime, List<Map<String, dynamic>>> grouped = {};
    for (var item in filtered) {
      final date = DateTime.tryParse(item['date']);
      if (date == null) continue;

      final normalized = DateTime(date.year, date.month, date.day);
      grouped.putIfAbsent(normalized, () => []).add(item);
    }

    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 20, 20, 20),
        foregroundColor: Colors.white,
        title: const Text(''),
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, bottom: 6),
                  child: Text(
                    '\$${invoiceTotal.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Closes on ', style: GoogleFonts.inter(color: Colors.white70)),
                          Text(_formatNextMonthDate(5), style: GoogleFonts.inter(color: Colors.redAccent)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text('Due ', style: GoogleFonts.inter(color: Colors.white70)),
                          Text(_formatNextMonthDate(10), style: GoogleFonts.inter(color: Colors.redAccent)),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15, top: 25, bottom: 45),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MonthlyInvoicesScreen()),
                      );
                    },
                    child: Text(
                      'Months Invoice',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: ListView(
                        children: sortedEntries.map((entry) => _buildTransactionGroup(entry)).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionGroup(MapEntry<DateTime, List<Map<String, dynamic>>> entry) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final label = entry.key == today
        ? 'Today'
        : entry.key == yesterday
            ? 'Yesterday'
            : '${entry.key.day} ${_monthAbbreviation(entry.key.month)}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...entry.value.map((item) {
            final icon = CategoryHelper.getIcon(item['category'] ?? 'Other');
            final color = CategoryHelper.getColor(item['category']);
            final formattedTime = _formatTime12h(item['date'], item['time']);

            final isFaturaPayment = item['method'].toString().toUpperCase() == 'DEBIT' &&
                (item['category']?.toString().toLowerCase() == 'invoice');

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isFaturaPayment ? Colors.green[700] : Colors.grey[900],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] ?? item['description'] ?? 'Sem título',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formattedTime,
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${(item['amount'] ?? 0).toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  String _formatTime12h(String? date, String? time) {
    if (date == null || time == null) return '';
    final dt = DateTime.tryParse('$date $time');
    if (dt == null) return '';
    return DateFormat.jm().format(dt);
  }

  String _monthAbbreviation(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _formatNextMonthDate(int day) {
    final now = DateTime.now();
    final nextMonth = (now.month == 12) ? 1 : now.month + 1;
    final year = (now.month == 12) ? now.year + 1 : now.year;
    final date = DateTime(year, nextMonth, day);
    final monthName = _monthAbbreviation(date.month);
    return '$monthName ${date.day}';
  }
}
