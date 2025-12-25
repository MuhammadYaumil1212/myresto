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

  //Secara iteratif mencari data dengan interpolation
  Future<Restaurant?> findRestaurantByInterpolationAlgorithm(int price) async {
    List<Restaurant> restaurants = await restaurantLocalDatasource
        .getRestaurants();
    //sorting sebelum proses interpolation, karena interpolation data nya harus terurut
    restaurants.sort((a, b) => a.price.compareTo(b.price));

    int low = 0;
    int high = restaurants.length - 1;

    while (low <= high &&
        price >= restaurants[low].price &&
        price <= restaurants[high].price) {
      // menghindari pembagian dengan nol
      if (restaurants[high].price == restaurants[low].price) {
        if (restaurants[low].price == price) return restaurants[low];
        return null;
      }
      //rumus interpolation
      int pos =
          low +
          ((price - restaurants[low].price) *
              (high - low) ~/
              (restaurants[high].price - restaurants[low].price));

      if (restaurants[pos].price == price) {
        return restaurants[pos]; // ditemukan
      }

      if (restaurants[pos].price < price) {
        low = pos + 1; // cari di kiri
      } else {
        high = pos - 1; // cari di kanan
      }
    }
    return null;
  }
}
