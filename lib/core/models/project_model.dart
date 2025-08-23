class ProjectModel {
  String id;
  String clientId;
  String type; // Kitchen / Window / Dressing Room ...
  String description;
  DateTime createdAt;

  ProjectModel({
    required this.id,
    required this.clientId,
    required this.type,
    required this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'clientId': clientId,
    'type': type,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
    id: json['id'],
    clientId: json['clientId'],
    type: json['type'],
    description: json['description'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}
