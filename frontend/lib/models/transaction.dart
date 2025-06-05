class TransactionModel {
  final String title;
  final double amount;
  final String category;
  final String date; // ou DateTime se já for convertido

  TransactionModel({
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      title: json['description'] ?? 'Unknown',
      amount: (json['amount'] ?? 0).toDouble(),
      category: json['category'] ?? 'Other',
      date: json['date'] ?? '',
    );
  }
}
