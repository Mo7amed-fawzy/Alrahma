class ClientModel {
  String id;
  String name;
  String phone;
  String address;

  ClientModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'address': address,
  };

  factory ClientModel.fromJson(Map<String, dynamic> json) => ClientModel(
    id: json['id'],
    name: json['name'],
    phone: json['phone'],
    address: json['address'],
  );
}
