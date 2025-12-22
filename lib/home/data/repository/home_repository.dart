import 'package:myresto/home/data/local/dataSources/restaurant_local_datasource.dart';
import 'package:myresto/home/data/models/Restaurant.dart';

class HomeRepository {
  final RestaurantLocalDatasource restaurantLocalDatasource;

  HomeRepository({required this.restaurantLocalDatasource});

  Future<List<Restaurant>> fetchRestaurant() async {
    try {
      return await restaurantLocalDatasource.getRestaurants();
    } catch (e) {
      throw Exception("Gagal load data restoran: $e");
    }
  }
}
