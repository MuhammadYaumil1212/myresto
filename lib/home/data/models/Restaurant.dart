import 'package:intl/intl.dart';

class Restaurant {
  final int id;
  final String name;
  final String cuisine;
  final double rating;
  final int price;
  final String review;

  Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.price,
    required this.review,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown',
      cuisine: json['cuisine'] as String? ?? 'General',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      price: json['price'] as int? ?? 0,
      review: json['review'] as String? ?? '-',
    );
  }

  String get formattedPrice {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp.',
      decimalDigits: 0,
    ).format(price);
  }
}
