class ProjectModel {
  String id;
  String clientId;
  String type; // Kitchen / Window / Dressing Room ...
  String description;
  DateTime createdAt;
  String? clientName; // ✅ حقل جديد للعرض فقط، اختياري

  ProjectModel({
    required this.id,
    required this.clientId,
    required this.type,
    required this.description,
    required this.createdAt,
    this.clientName, // ✅ optional
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'clientId': clientId,
    'type': type,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'clientName': clientName, // ✅ ضفت الحقل هنا
  };

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
    id: json['id'],
    clientId: json['clientId'],
    type: json['type'],
    description: json['description'],
    createdAt: DateTime.parse(json['createdAt']),
    clientName: json['clientName'], // ✅ ضفت الحقل هنا
  );
}
