import 'package:alrahma/core/models/payment_history.dart';

class PaymentModel {
  String id;
  String projectId;
  double amountTotal;
  double amountPaid;
  DateTime datePaid;
  List<PaymentHistory> history; // ← الحقل الجديد

  PaymentModel({
    required this.id,
    required this.projectId,
    required this.amountTotal,
    required this.amountPaid,
    required this.datePaid,
    List<PaymentHistory>? history, // اختياري عند الإنشاء
  }) : history = history ?? [];

  double get remainingAmount => amountTotal - amountPaid;

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectId': projectId,
    'amountTotal': amountTotal,
    'amountPaid': amountPaid,
    'datePaid': datePaid.toIso8601String(),
    'history': history.map((h) => h.toJson()).toList(),
  };

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
    id: json['id'] as String,
    projectId: json['projectId'] as String,
    amountTotal: (json['amountTotal'] as num).toDouble(),
    amountPaid: (json['amountPaid'] as num).toDouble(),
    datePaid: DateTime.parse(json['datePaid'] as String),
    history:
        (json['history'] as List<dynamic>?)
            ?.map((e) => PaymentHistory.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );

  // لو حابب نسخة copyWith سريعة:
  PaymentModel copyWith({
    String? id,
    String? projectId,
    double? amountTotal,
    double? amountPaid,
    DateTime? datePaid,
    List<PaymentHistory>? history,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      amountTotal: amountTotal ?? this.amountTotal,
      amountPaid: amountPaid ?? this.amountPaid,
      datePaid: datePaid ?? this.datePaid,
      history: history ?? List<PaymentHistory>.from(this.history),
    );
  }
}
