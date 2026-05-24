class Promo {
  final int id;
  final String name;
  final String? description;
  final String code;
  final String type; // percentage, fixed
  final String promoType; // diskon, bundling, free_item
  final double value;
  final double minPurchase;
  final int? quota;
  final int used;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? image;
  final bool isBanner;
  final bool isActive;
  final String? bundlingItems;
  final String? freeItemName;

  Promo({
    required this.id,
    required this.name,
    this.description,
    required this.code,
    required this.type,
    required this.promoType,
    required this.value,
    required this.minPurchase,
    this.quota,
    required this.used,
    this.startDate,
    this.endDate,
    this.image,
    required this.isBanner,
    required this.isActive,
    this.bundlingItems,
    this.freeItemName,
  });

  factory Promo.fromJson(Map<String, dynamic> json) {
    return Promo(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      description: json['description'],
      code: json['code'] ?? '',
      type: json['type'] ?? 'percentage',
      promoType: json['promo_type'] ?? 'diskon',
      value: double.parse(json['value']?.toString() ?? '0'),
      minPurchase: double.parse(json['min_purchase']?.toString() ?? '0'),
      quota: json['quota'] != null ? int.parse(json['quota'].toString()) : null,
      used: int.parse(json['used']?.toString() ?? '0'),
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      image: json['image'],
      isBanner: json['is_banner'] == 1 || json['is_banner'] == true,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      bundlingItems: json['bundling_items'],
      freeItemName: json['free_item_name'],
    );
  }
}
