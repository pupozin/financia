class DashboardData {
  final double income;
  final double expense;
  final double balance;
  final double invoiceTotal;
  final List<Map<String, dynamic>> transactions;

  DashboardData({
    required this.income,
    required this.expense,
    required this.balance,
    required this.invoiceTotal,
    required this.transactions,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      income: (json['income'] ?? 0).toDouble(),
      expense: (json['expense'] ?? 0).toDouble(),
      balance: (json['balance'] ?? 0).toDouble(),
      invoiceTotal: (json['invoiceTotal'] ?? 0).toDouble(),
      transactions: (json['transactions'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
    );
  }
}
