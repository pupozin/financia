import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:frontend/models/login-response.dart';
import 'package:frontend/services/api-service.dart';

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

  List<Map<String, dynamic>> availableMonths = [];
  int selectedIndex = -1;
  List<dynamic> allTransactions = [];
  bool isLoading = true;

  String cpf = '';
  List<String> banks = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      final login = LoginResponse.fromJson(jsonDecode(userJson));
      cpf = login.cpf;

      final api = ApiService();
      banks = await api.getAuthorizedBanks(cpf);

      await loadAvailableMonths();
    }
  }

  Future<void> loadAvailableMonths() async {
    final host = kIsWeb ? 'localhost' : '10.0.2.2';
    final List<Map<String, dynamic>> allMonths = [];

    for (final bank in banks) {
      final url = Uri.parse('http://$host:8081/api/transaction/paid-invoices/months/$cpf/$bank');
      final resp = await http.get(url);

      if (resp.statusCode == 200) {
        final List<dynamic> raw = jsonDecode(resp.body);
        final parsed = raw.map((m) {
          return {
            'month': m['month'],
            'year': m['year'],
            'label': '${months[m['month'] - 1]} ${m['year']}',
          };
        });
        allMonths.addAll(parsed);
      }
    }

    final unique = {
      for (var m in allMonths) '${m['month']}-${m['year']}': m
    }.values.toList();

    unique.sort((a, b) {
      final aDate = DateTime(a['year'], a['month']);
      final bDate = DateTime(b['year'], b['month']);
      return aDate.compareTo(bDate);
    });

    setState(() {
      availableMonths = unique;
      if (availableMonths.length >= 3) {
        selectedIndex = 2;
      } else if (availableMonths.isNotEmpty) {
        selectedIndex = 0;
      }
    });

    if (selectedIndex != -1) {
      await loadAllTransactions();
    }
  }

  Future<void> loadAllTransactions() async {
    setState(() => isLoading = true);
    final selected = availableMonths[selectedIndex];
    final month = selected['month'];
    final year = selected['year'];
    final host = kIsWeb ? 'localhost' : '10.0.2.2';

    final List<dynamic> allTx = [];
    final List<dynamic> allInvoices = [];

    for (final bank in banks) {
      final txUrl = Uri.parse('http://$host:8081/api/transaction/$cpf/$bank');
      final invoiceUrl = Uri.parse('http://$host:8081/api/transaction/paid-invoices/$cpf/$bank/$month/$year');

      final txResponse = await http.get(txUrl);
      final invoiceResponse = await http.get(invoiceUrl);

      if (txResponse.statusCode == 200) {
        final txList = jsonDecode(txResponse.body);
        final filteredCredit = txList.where((tx) {
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
        allTx.addAll(filteredCredit);
      }

      if (invoiceResponse.statusCode == 200) {
        final invoiceList = jsonDecode(invoiceResponse.body);
        final invoiceWithFlag = invoiceList.map((invoice) {
          invoice['isPaidInvoice'] = true;
          return invoice;
        }).toList();
        allInvoices.addAll(invoiceWithFlag);
      }
    }

    setState(() {
      allTransactions = [...allTx, ...allInvoices];
      isLoading = false;
    });
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
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: visibleMonths.map((month) {
                        final trueIndex = availableMonths.indexOf(month);
                        final isSelected = trueIndex == selectedIndex;

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: GestureDetector(
                              onTap: () async {
                                setState(() => selectedIndex = trueIndex);
                                await loadAllTransactions();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 3),
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