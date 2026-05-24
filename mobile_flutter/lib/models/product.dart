import 'package:mobile_flutter/constants.dart';

class Product {
  final int id;
  final int categoryId;
  final String name;
  final String description;
  final double price;
  final String? image;
  final bool isPopular;
  final bool isAvailable;

  final String? categoryName;

  Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    this.image,
    required this.isPopular,
    required this.isAvailable,
    this.categoryName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String? imageUrl = json['image'];
    if (imageUrl != null && !imageUrl.startsWith('http')) {
      // Use the storage URL from constants
      imageUrl = '${ApiConstants.baseUrl.replaceAll('/api', '/storage/')}$imageUrl';
    }

    return Product(
      id: int.parse(json['id'].toString()),
      categoryId: int.parse(json['category_id'].toString()),
      name: json['name'] ?? 'Tanpa Nama',
      description: json['description'] ?? '',
      price: double.parse(json['price'].toString()),
      image: imageUrl,
      isPopular: json['is_popular'] == 1 || json['is_popular'] == true,
      isAvailable: json['is_available'] == 1 || json['is_available'] == true,
      categoryName: json['category'] != null ? json['category']['name'] : null,
    );
  }
}
