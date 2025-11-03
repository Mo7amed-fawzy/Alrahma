class PaymentHistory {
  final DateTime date;
  final double amountTotal;
  final double amountPaid;

  PaymentHistory({
    required this.date,
    required this.amountTotal,
    required this.amountPaid,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      date: DateTime.parse(json['date'] as String),
      amountTotal: (json['amountTotal'] as num).toDouble(),
      amountPaid: (json['amountPaid'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'amountTotal': amountTotal,
      'amountPaid': amountPaid,
    };
  }

  @override
  String toString() =>
      '${date.toString().split(' ').first} • إجمالي: $amountTotal • مدفوع: $amountPaid';
}
