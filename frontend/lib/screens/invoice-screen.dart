import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../helpers/categoryhelper.dart';

class InvoiceScreen extends StatelessWidget {
  final double invoiceTotal;
  final List<Map<String, dynamic>> transactions;

  const InvoiceScreen({super.key, required this.invoiceTotal, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentMonthData = transactions.where((item) {
  final dateStr = item['date'];
  if (dateStr == null || dateStr == '') return false;

  final date = DateTime.tryParse(dateStr);
  if (date == null) return false;

  return date.month == now.month && date.year == now.year;
}).toList();


    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in currentMonthData) {
      final date = DateTime.parse(item['date']);

      String label;

      if (date.day == now.day && date.month == now.month && date.year == now.year) {
        label = 'Today';
      } else if (date.day == now.subtract(const Duration(days: 1)).day &&
          date.month == now.month &&
          date.year == now.year) {
        label = 'Yesterday';
      } else {
        label = '${date.day} ${_monthAbbreviation(date.month)}';
      }

      grouped.putIfAbsent(label, () => []).add(item);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(''),
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Valor total da fatura
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, bottom: 6),
                  child: Text(
                    '\$${invoiceTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Closes on / Due
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, bottom: 16),
                  child: Row(
                    children: [
                      Text('Closes on ', style: TextStyle(color: Colors.white70)),
                      Text(_formatNextMonthDate(5), style: TextStyle(color: Colors.redAccent)),
                      const SizedBox(width: 20),
                      Text('Due ', style: TextStyle(color: Colors.white70)),
                      Text(_formatNextMonthDate(10), style: TextStyle(color: Colors.redAccent)),
                    ],
                  ),
                ),

                // Histórico
                Expanded(
                  child: ListView(
                    children: grouped.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.key,
                                style: const TextStyle(
                                    color: Colors.white70, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 12),
                            ...entry.value.map((item) {
                              final icon = CategoryHelper.getIcon(item['category'] ?? 'Other');
                              final color = CategoryHelper.getColor(item['category']);

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[900],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(icon, color: color, size: 20),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                    child: Text(
                                          item['title'] ?? item['description'] ?? 'Sem título',
                                          style: const TextStyle(color: Colors.white),
                                        ),

                                    ),
                                    Text(
                                      '\$${(item['amount'] ?? 0).toStringAsFixed(2)}',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _monthAbbreviation(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
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
}
