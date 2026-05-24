class TableModel {
  final int id;
  final String number;
  final String? name;
  final String type;
  final int capacity;
  final String status;
  final String? customerName;
  final bool isActive;

  TableModel({
    required this.id,
    required this.number,
    this.name,
    required this.type,
    required this.capacity,
    required this.status,
    this.customerName,
    required this.isActive,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      number: json['number']?.toString() ?? '',
      name: json['name'],
      type: json['type'] ?? 'Regular',
      capacity: json['capacity'] is int ? json['capacity'] : int.tryParse(json['capacity']?.toString() ?? '2') ?? 2,
      status: json['status'] ?? 'Aktif',
      customerName: json['customer_name'],
      isActive: json['is_active'] == 1 || json['is_active'] == '1' || json['is_active'] == true || json['is_active'] == 'true',
    );
  }

  static Map<String, dynamic> toJson(TableModel table) {
    return {
      'number': table.number,
      'name': table.name,
      'type': table.type,
      'capacity': table.capacity,
      'status': table.status,
      'customer_name': table.customerName,
      'is_active': table.isActive,
    };
  }
}
