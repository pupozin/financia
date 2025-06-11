import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MonthlyInvoicesScreen extends StatefulWidget {
  const MonthlyInvoicesScreen({super.key});

  @override
  State<MonthlyInvoicesScreen> createState() => _MonthlyInvoicesScreenState();
}

class _MonthlyInvoicesScreenState extends State<MonthlyInvoicesScreen> {
  final List<String> months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  int currentYear = DateTime.now().year;
  int selectedIndex = DateTime.now().month - 1;

  @override
  Widget build(BuildContext context) {
    final visibleMonths = _getVisibleMonths();
    final selectedMonth = months[selectedIndex % 12];
    final transactions = _getMockTransactionsFor(selectedMonth);

    final double totalPaid = transactions
        .where((t) => t['type'] == 'payment')
        .fold(0.0, (sum, t) => sum + (t['amount'] as double));

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Text(
              '\$1,749.00',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Closes on ', style: GoogleFonts.inter(color: Colors.white70)),
                Text('Oct 5', style: GoogleFonts.inter(color: Colors.redAccent)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Due ', style: GoogleFonts.inter(color: Colors.white70)),
                Text('Oct 10', style: GoogleFonts.inter(color: Colors.redAccent)),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 45,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(visibleMonths.length, (i) {
                  final realIndex = visibleMonths[i]['index'];
                  final isSelected = realIndex == selectedIndex;
                  return GestureDetector(
                    onTap: () => setState(() {
                      selectedIndex = realIndex;
                      if (selectedIndex >= 12) {
                        selectedIndex %= 12;
                        currentYear++;
                      } else if (selectedIndex < 0) {
                        selectedIndex += 12;
                        currentYear--;
                      }
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.grey[800],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        visibleMonths[i]['label'],
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Today', style: GoogleFonts.poppins(color: Colors.green, fontWeight: FontWeight.w500)),
                Text('Payed', style: GoogleFonts.poppins(color: Colors.green, fontWeight: FontWeight.w500)),
                Text('\$${totalPaid.toStringAsFixed(2)}', style: GoogleFonts.poppins(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  final isPayment = tx['type'] == 'payment';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Today', style: GoogleFonts.inter(color: Colors.white70)),
                        Text(tx['title'], style: GoogleFonts.poppins(color: Colors.white)),
                        Text(
                          '${isPayment ? '+ ' : '- '}\$${tx['amount'].toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            color: isPayment ? Colors.green : Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getVisibleMonths() {
    int start = selectedIndex - 2;
    List<Map<String, dynamic>> result = [];
    for (int i = 0; i < 5; i++) {
      int index = start + i;
      int adjustedIndex = index;
      int year = currentYear;
      if (index >= 12) {
        adjustedIndex = index % 12;
        year += index ~/ 12;
      } else if (index < 0) {
        adjustedIndex = (index + 12) % 12;
        year -= ((-index - 1) ~/ 12) + 1;
      }
      result.add({
        'label': months[adjustedIndex],
        'index': adjustedIndex,
        'year': year
      });
    }
    return result;
  }

  List<Map<String, dynamic>> _getMockTransactionsFor(String month) {
    return [
      {'title': 'McDonald\'s', 'amount': 22.32, 'type': 'expense'},
      {'title': 'McDonald\'s', 'amount': 22.32, 'type': 'expense'},
      {'title': 'McDonald\'s', 'amount': 22.32, 'type': 'expense'},
      {'title': 'Invoice Payment', 'amount': 67.32, 'type': 'payment'},
    ];
  }
}