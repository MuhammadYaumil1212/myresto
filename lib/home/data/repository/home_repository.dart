import 'dart:developer';

import 'package:myresto/home/data/local/dataSources/restaurant_local_datasource.dart';
import 'package:myresto/home/data/models/Restaurant.dart';

class HomeRepository {
  final RestaurantLocalDatasource restaurantLocalDatasource;
  HomeRepository({required this.restaurantLocalDatasource});
  final stopwatch = Stopwatch()..start();
  int steps = 0;

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
    log("--- MULAI PENCARIAN INTERPOLATION ITERATIF ---");
    log("Mencari Harga: $price");
    log("Total Data: ${restaurants.length} restoran");
    log(
      "Range Harga Data: ${restaurants.first.price} - ${restaurants.last.price}",
    );
    //sorting sebelum proses interpolation, karena interpolation data nya harus terurut
    restaurants.sort((a, b) => a.price.compareTo(b.price));

    int low = 0;
    int high = restaurants.length - 1;

    while (low <= high &&
        price >= restaurants[low].price &&
        price <= restaurants[high].price) {
      steps++;
      // menghindari pembagian dengan nol
      if (restaurants[high].price == restaurants[low].price) {
        //kalau ketemu
        if (restaurants[low].price == price) {
          stopwatch.stop();
          _printSuccessLog(restaurants[low], steps, stopwatch);
          return restaurants[low]; //ditemukan
        }
        _printNotFoundLog(steps, stopwatch);
        return null;
      }
      //rumus interpolation
      int pos =
          low +
          ((price - restaurants[low].price) *
              (high - low) ~/
              (restaurants[high].price - restaurants[low].price));
      log(
        "Langkah ke-$steps | Low: $low, High: $high, Posisi Tebakan: $pos, Harga di Posisi: ${restaurants[pos].price}",
      );
      //kondisi kalau ketemu
      if (restaurants[pos].price == price) {
        stopwatch.stop();
        _printSuccessLog(restaurants[pos], steps, stopwatch);
        return restaurants[pos]; // ditemukan
      }

      if (restaurants[pos].price < price) {
        low = pos + 1; // cari di kiri
      } else {
        high = pos - 1; // cari di kanan
      }
    }
    stopwatch.stop();
    _printNotFoundLog(steps, stopwatch);
    return null;
  }

  //Cari data dengan interpolation secara rekursif
  Future<Restaurant?> findRestaurantByInterpolationRecursive(int price) async {
    List<Restaurant> restaurants = await restaurantLocalDatasource
        .getRestaurants();
    log("--- MULAI PENCARIAN INTERPOLATION REKURSIF ---");
    log("Mencari Harga: $price");
    log("Total Data: ${restaurants.length} restoran");

    restaurants.sort((a, b) => a.price.compareTo(b.price));

    log(
      "Range Harga Data: ${restaurants.first.price} - ${restaurants.last.price}",
    );

    if (restaurants.isEmpty) {
      return null;
    }

    return _interpolationRecursive(
      restaurants,
      0,
      restaurants.length - 1,
      price,
      0,
    );
  }

  Restaurant? _interpolationRecursive(
    List<Restaurant> restaurants,
    int low,
    int high,
    int price,
    int steps,
  ) {
    steps++;

    if (low > high ||
        price < restaurants[low].price ||
        price > restaurants[high].price) {
      stopwatch.stop();
      _printNotFoundLog(steps, stopwatch);
      return null;
    }

    if (restaurants[high].price == restaurants[low].price) {
      if (restaurants[low].price == price) {
        stopwatch.stop();
        _printSuccessLog(restaurants[low], steps, stopwatch);
        return restaurants[low];
      } else {
        stopwatch.stop();
        _printNotFoundLog(steps, stopwatch);
        return null;
      }
    }

    int pos =
        low +
        ((price - restaurants[low].price) *
            (high - low) ~/
            (restaurants[high].price - restaurants[low].price));

    log(
      "Langkah ke-$steps | Low: $low, High: $high, Posisi Tebakan: $pos, Harga di Posisi: ${restaurants[pos].price}",
    );

    if (restaurants[pos].price == price) {
      stopwatch.stop();
      _printSuccessLog(restaurants[pos], steps, stopwatch);
      return restaurants[pos];
    }

    if (restaurants[pos].price < price) {
      return _interpolationRecursive(restaurants, pos + 1, high, price, steps);
    } else {
      return _interpolationRecursive(restaurants, low, pos - 1, price, steps);
    }
  }

  void _printSuccessLog(Restaurant result, int steps, Stopwatch sw) {
    log("DITEMUKAN: ${result.name}");
    log("STATISTIK:");
    log("   - Jumlah Langkah (Iterasi): $steps");
    log("   - Waktu Eksekusi: ${sw.elapsedMicroseconds} microsecond");
    log("---------------------------------------");
  }

  void _printNotFoundLog(int steps, Stopwatch sw) {
    log("TIDAK DITEMUKAN");
    log("STATISTIK:");
    log("   - Jumlah Langkah (Iterasi): $steps");
    log("   - Waktu Eksekusi: ${sw.elapsedMicroseconds} microsecond");
    log("---------------------------------------");
  }
}
