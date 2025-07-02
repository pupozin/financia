import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

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

  List<Map<String, dynamic>> availableMonths = [
    {'month': 2, 'year': 2025, 'label': 'Feb 2025'},
    {'month': 3, 'year': 2025, 'label': 'Mar 2025'},
    {'month': 4, 'year': 2025, 'label': 'Apr 2025'},
    {'month': 5, 'year': 2025, 'label': 'May 2025'},
    {'month': 6, 'year': 2025, 'label': 'Jun 2025'},
    {'month': 7, 'year': 2025, 'label': 'Jul 2025'},
  ];

  int selectedIndex = 2;
  List<dynamic> allTransactions = [];
  bool isLoading = true;

  final String cpf = '18398375000';
  final String bank = 'NIBANK';

  @override
  void initState() {
    super.initState();
    loadAllTransactions();
  }

  Future<void> loadAllTransactions() async {
    setState(() => isLoading = true);
    final selected = availableMonths[selectedIndex];
    final month = selected['month'];
    final year = selected['year'];

    final txUrl = Uri.parse('http://localhost:8081/api/transaction/$cpf/$bank');
    final invoiceUrl = Uri.parse(
        'http://localhost:8081/api/transaction/paid-invoices/$cpf/$bank/$month/$year');

    try {
      final txResponse = await http.get(txUrl);
      final invoiceResponse = await http.get(invoiceUrl);

      if (txResponse.statusCode == 200 && invoiceResponse.statusCode == 200) {
        final allTx = jsonDecode(txResponse.body);
        final allInvoices = jsonDecode(invoiceResponse.body);

        final filteredCredit = allTx.where((tx) {
          final date = DateTime.tryParse(tx['date'] ?? '');
          final method = tx['method']?.toString()?.toUpperCase();
          return date != null &&
              date.month == month &&
              date.year == year &&
              method == 'CREDIT';
        }).map((tx) {
          tx['isPaidInvoice'] = false;
          return tx;
        }).toList();

        final invoiceWithFlag = allInvoices.map((invoice) {
          invoice['isPaidInvoice'] = true;
          return invoice;
        }).toList();

        setState(() {
          allTransactions = [...filteredCredit, ...invoiceWithFlag];
          isLoading = false;
        });
      } else {
        throw Exception('Erro na resposta da API');
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('Erro ao carregar dados: $e');
    }
  }

  List<Map<String, dynamic>> get visibleMonths {
    const visibleCount = 5;
    int start = selectedIndex - (visibleCount ~/ 2);
    int end = start + visibleCount;

    if (start < 0) {
      end += -start;
      start = 0;
    }
    if (end > availableMonths.length) {
      start -= (end - availableMonths.length);
      end = availableMonths.length;
      if (start < 0) start = 0;
    }

    return availableMonths.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final double invoiceTotal = allTransactions
        .where((t) => t['isPaidInvoice'] == false)
        .fold(0.0, (sum, t) => sum + (t['amount'] as num));

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Text(
                    '\$${invoiceTotal.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 32,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: visibleMonths.map((month) {
                        final trueIndex = availableMonths.indexOf(month);
                        final isSelected = trueIndex == selectedIndex;

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () async {
                                setState(() => selectedIndex = trueIndex);
                                await loadAllTransactions();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.blue : Colors.grey[800],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    month['label'],
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: ListView.builder(
                      itemCount: allTransactions.length,
                      itemBuilder: (context, index) {
                        final tx = allTransactions[index];
                        final date = DateTime.tryParse(tx['date'] ?? '');
                        final formattedDate = date != null
                            ? '${date.day} ${months[date.month - 1].toUpperCase()}'
                            : '';
                        final isPaidInvoice = tx['isPaidInvoice'] == true;

                        final textColor = isPaidInvoice ? Colors.green : Colors.white;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formattedDate,
                                style: GoogleFonts.inter(
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    isPaidInvoice
                                        ? 'Pagamento da fatura de ${months[date!.month - 1]}'
                                        : tx['description'] ?? '',
                                    style: GoogleFonts.poppins(
                                      color: textColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              Text(
                                '\$${(tx['amount'] as num).toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  color: textColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}