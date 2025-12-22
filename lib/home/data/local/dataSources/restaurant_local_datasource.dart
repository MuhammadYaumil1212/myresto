import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:myresto/home/data/models/Restaurant.dart';

class RestaurantLocalDatasource {
  Future<List<Restaurant>> getRestaurants() async {
    final String response = await rootBundle.loadString(
      'assets/MockRestaurant.json',
    );
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Restaurant.fromJson(json)).toList();
  }
}
