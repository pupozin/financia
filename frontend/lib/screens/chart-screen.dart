import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/widget/header.dart';
import 'package:frontend/services/api-service.dart';

class ChartScreen extends StatefulWidget {
  final void Function()? onAvatarTap;
  final VoidCallback? onToggleMenu;
  final String userName;

  const ChartScreen({
    super.key,
    this.onAvatarTap,
    this.onToggleMenu,
    required this.userName,
  });

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  final _api = ApiService();

  bool isIncomeSelected = true;
  String selectedTimeFilter = "Month";
  bool isLoading = true;

  String? cpf;
  List<String> banks = [];

  // dados do gráfico
  List<String> labels = [];
  List<double> incomeSeries = [];
  List<double> expenseSeries = [];

  // cache de histórico do mês corrente para não bater mil vezes
  final Map<String, List<dynamic>> _historyCacheByBank = {};

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('user');
      if (stored == null) {
        // volta pro login se necessário
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final decoded = jsonDecode(stored) as Map<String, dynamic>;
      cpf = decoded['cpf'] as String?;

      if (cpf == null || cpf!.isEmpty) {
        throw Exception('CPF não encontrado no SharedPreferences.');
      }

      // bancos autorizados
      banks = await _api.getAuthorizedBanks(cpf!);

      await _loadChartData(); // carrega de acordo com filtro default "Month"
    } catch (e) {
      debugPrint('Erro no bootstrap do ChartScreen: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _loadChartData() async {
    setState(() => isLoading = true);

    try {
      if (selectedTimeFilter == 'Month') {
        await _loadLast6Months();
      } else if (selectedTimeFilter == 'Year') {
        await _loadLast5Years();
      } else if (selectedTimeFilter == 'Week') {
        await _loadLast7Days(); // baseado no histórico do mês atual
      } else if (selectedTimeFilter == 'Day') {
        await _loadTodayByHours(); // simples/agregado por dia (1 ponto)
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados do gráfico: $e');
      labels = [];
      incomeSeries = [];
      expenseSeries = [];
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // -----------------------------
  // Helpers de período
  // -----------------------------

  // Últimos 6 meses
  Future<void> _loadLast6Months() async {
    final now = DateTime.now();
    final List<DateTime> monthsBack = List.generate(6, (i) {
      final m = DateTime(now.year, now.month - (5 - i), 1);
      return DateTime(m.year, m.month, 1);
    });

    labels = monthsBack.map((d) => _monthAbbr(d.month)).toList();

    double sumIncome(int month, int year) => 0.0;
    double sumExpense(int month, int year) => 0.0;

    final List<double> income = [];
    final List<double> expense = [];

    for (final d in monthsBack) {
      double incomeTotal = 0;
      double expenseTotal = 0;

      for (final bank in banks) {
        final summary = await _api.getMonthlySummary(cpf!, bank, d.month, d.year);
        final inc = (summary['income'] ?? 0).toDouble();
        final exp = (summary['expense'] ?? 0).toDouble();
        incomeTotal += inc;
        expenseTotal += exp;
      }

      income.add(incomeTotal);
      expense.add(expenseTotal);
    }

    incomeSeries = income;
    expenseSeries = expense;
  }

  // Últimos 5 anos (somando 12 meses de cada ano)
  Future<void> _loadLast5Years() async {
    final now = DateTime.now();
    final List<int> yearsBack = List.generate(5, (i) => now.year - (4 - i));

    labels = yearsBack.map((y) => y.toString()).toList();

    final List<double> income = [];
    final List<double> expense = [];

    for (final year in yearsBack) {
      double incomeTotalYear = 0;
      double expenseTotalYear = 0;

      for (int m = 1; m <= 12; m++) {
        for (final bank in banks) {
          final summary = await _api.getMonthlySummary(cpf!, bank, m, year);
          incomeTotalYear += (summary['income'] ?? 0).toDouble();
          expenseTotalYear += (summary['expense'] ?? 0).toDouble();
        }
      }

      income.add(incomeTotalYear);
      expense.add(expenseTotalYear);
    }

    incomeSeries = income;
    expenseSeries = expense;
  }

  // Últimos 7 dias (do mês atual, somando por dia)
  Future<void> _loadLast7Days() async {
    final now = DateTime.now();
    // carrega histórico do mês atual pra cada banco (com cache)
    await _ensureCurrentMonthHistoryLoaded(now.month, now.year);

    final List<DateTime> days = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return DateTime(d.year, d.month, d.day);
    });

    labels = days.map((d) => '${d.day}/${d.month}').toList();

    final List<double> income = [];
    final List<double> expense = [];

    for (final d in days) {
      double inc = 0;
      double exp = 0;

      for (final bank in banks) {
        final hist = _historyCacheByBank[bank] ?? [];
        for (final tx in hist) {
          final dateStr = tx['date']?.toString() ?? '';
          final dt = DateTime.tryParse(dateStr);
          if (dt == null) continue;
          if (dt.year == d.year && dt.month == d.month && dt.day == d.day) {
            final method = tx['method']?.toString()?.toUpperCase();
            final amount = (tx['amount'] ?? 0).toDouble();
            if (method == 'INCOME' || method == 'CREDIT') {
              inc += amount; // se "income" vier como transação, soma aqui; se não, ajuste pra sua regra
            } else if (method == 'DEBIT') {
              exp += amount;
            }
          }
        }
      }

      income.add(inc);
      expense.add(exp);
    }

    incomeSeries = income;
    expenseSeries = expense;
  }

  // Hoje (um ponto só — agregando o dia atual)
  Future<void> _loadTodayByHours() async {
    final now = DateTime.now();
    await _ensureCurrentMonthHistoryLoaded(now.month, now.year);

    labels = ['Today'];
    double inc = 0;
    double exp = 0;

    for (final bank in banks) {
      final hist = _historyCacheByBank[bank] ?? [];
      for (final tx in hist) {
        final dateStr = tx['date']?.toString() ?? '';
        final dt = DateTime.tryParse(dateStr);
        if (dt == null) continue;
        if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
          final method = tx['method']?.toString()?.toUpperCase();
          final amount = (tx['amount'] ?? 0).toDouble();
          if (method == 'INCOME' || method == 'CREDIT') {
            inc += amount;
          } else if (method == 'DEBIT') {
            exp += amount;
          }
        }
      }
    }

    incomeSeries = [inc];
    expenseSeries = [exp];
  }

  Future<void> _ensureCurrentMonthHistoryLoaded(int month, int year) async {
    for (final bank in banks) {
      if (_historyCacheByBank.containsKey(bank)) continue;
      final hist = await _api.getMonthlyHistory(cpf!, bank, month, year);
      _historyCacheByBank[bank] = hist;
    }
  }

  // -----------------------------
  // UI
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    final series = isIncomeSelected ? incomeSeries : expenseSeries;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SharedDashboardHeader(
              userName: widget.userName,
              onAvatarTap: widget.onAvatarTap,
              onToggleMenu: widget.onToggleMenu,
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 37, 36, 36),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(65),
                  topRight: Radius.circular(65),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            'Graphic',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Filtros Income/Expense
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _filterButton("Income", isIncomeSelected, () async {
                              setState(() => isIncomeSelected = true);
                            }, Colors.blue),
                            const SizedBox(width: 12),
                            _filterButton("Expense", !isIncomeSelected, () async {
                              setState(() => isIncomeSelected = false);
                            }, Colors.orange),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Filtros por tempo
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: ["Day", "Week", "Month", "Year"].map((label) {
                            final isSelected = label == selectedTimeFilter;
                            return GestureDetector(
                              onTap: () async {
                                if (selectedTimeFilter == label) return;
                                setState(() {
                                  selectedTimeFilter = label;
                                  isLoading = true;
                                });
                                // quando troca o filtro, recarrega dados
                                await _loadChartData();
                              },
                              child: Text(
                                label,
                                style: GoogleFonts.inter(
                                  color: isSelected ? Colors.white : Colors.white60,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 0),

                        // Gráfico
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 90),
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(show: false),
                                borderData: FlBorderData(show: false),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 1,
                                      getTitlesWidget: (value, meta) {
                                        final idx = value.toInt();
                                        if (idx < 0 || idx >= labels.length) {
                                          return const SizedBox.shrink();
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            labels[idx],
                                            style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                lineBarsData: [
                                  _lineBar(
                                    series.isEmpty ? [0] : series,
                                    color: isIncomeSelected ? Colors.blue : Colors.orange,
                                  ),
                                ],
                                minY: 0,
                                maxY: _calcMaxY(series),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  double _calcMaxY(List<double> s) {
    final mx = (s.isEmpty ? 0 : s.reduce((a, b) => a > b ? a : b));
    if (mx <= 0) return 10;
    return (mx * 1.2).clamp(10, double.infinity);
  }

  LineChartBarData _lineBar(List<double> values, {required Color color}) {
    final pts = values.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();
    return LineChartBarData(
      spots: pts,
      isCurved: true,
      color: color,
      barWidth: 3,
      belowBarData: BarAreaData(show: false),
      dotData: FlDotData(show: true),
    );
  }

  Widget _filterButton(String label, bool selected, VoidCallback onTap, Color activeColor) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? activeColor : Colors.grey[800],
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _monthAbbr(int m) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[m - 1];
  }
}
