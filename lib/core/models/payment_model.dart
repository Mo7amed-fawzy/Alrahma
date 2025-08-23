class PaymentModel {
  String id;
  String projectId;
  double amountTotal;
  double amountPaid;
  DateTime datePaid;

  PaymentModel({
    required this.id,
    required this.projectId,
    required this.amountTotal,
    required this.amountPaid,
    required this.datePaid,
  });

  double get remainingAmount => amountTotal - amountPaid;

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectId': projectId,
    'amountTotal': amountTotal,
    'amountPaid': amountPaid,
    'datePaid': datePaid.toIso8601String(),
  };

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
    id: json['id'],
    projectId: json['projectId'],
    amountTotal: (json['amountTotal'] as num).toDouble(),
    amountPaid: (json['amountPaid'] as num).toDouble(),
    datePaid: DateTime.parse(json['datePaid']),
  );
}
