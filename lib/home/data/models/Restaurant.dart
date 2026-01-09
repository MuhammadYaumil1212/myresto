import 'package:intl/intl.dart';

import 'MenuItem.dart';

class Restaurant {
  final int id;
  final String name;
  final String cuisine;
  final double rating;
  final List<MenuItem> menuList;
  final String review;

  Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.menuList,
    required this.review,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown',
      cuisine: json['cuisine'] as String? ?? 'General',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      review: json['review'] as String? ?? '-',
      menuList: (json['menu_list'] as List<dynamic>? ?? [])
          .map((e) => MenuItem.fromJson(e))
          .toList(),
    );
  }

  int get totalPrice {
    return menuList.fold(0, (sum, item) => sum + item.price);
  }

  int get cheapestPrice {
    if (menuList.isEmpty) return 0;
    return menuList.map((e) => e.price).reduce((a, b) => a < b ? a : b);
  }

  String formatPrice(int price) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp.',
      decimalDigits: 0,
    ).format(price);
  }
}
