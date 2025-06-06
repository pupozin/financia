import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
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
      final timeStr = item['time'];

      if (dateStr == null || dateStr == '' || timeStr == null || timeStr == '') return false;

      final dateOnly = DateTime.tryParse(dateStr);
      return dateOnly != null && dateOnly.month == now.month && dateOnly.year == now.year;
    }).toList();

    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in currentMonthData) {
      final dateStr = item['date'];
      final date = DateTime.tryParse(dateStr);
      if (date == null) continue;

      String label;
      final yesterday = now.subtract(const Duration(days: 1));

      if (date.day == now.day && date.month == now.month && date.year == now.year) {
        label = 'Today';
      } else if (date.day == yesterday.day && date.month == yesterday.month && date.year == yesterday.year) {
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
        title: const Text('Invoice'),
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
                Expanded(
                  child: ListView(
                    children: grouped.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...entry.value.map((item) {
                              final icon = CategoryHelper.getIcon(item['category'] ?? 'Other');
                              final color = CategoryHelper.getColor(item['category']);

                              final formattedTime = _formatTime12h(item['date'], item['time']);

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[900],
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
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            formattedTime,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
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

  String _formatTime12h(String? date, String? time) {
    if (date == null || time == null) return '';
    final dt = DateTime.tryParse('$date $time');
    if (dt == null) return '';
    return DateFormat.jm().format(dt); // 12h format with AM/PM
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
