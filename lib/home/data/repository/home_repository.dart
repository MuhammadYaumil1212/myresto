import 'dart:developer';

import 'package:myresto/home/data/local/dataSources/restaurant_local_datasource.dart';
import 'package:myresto/home/data/models/Restaurant.dart';
import 'package:myresto/home/data/models/search_response.dart';

class HomeRepository {
  final RestaurantLocalDatasource restaurantLocalDatasource;

  HomeRepository({required this.restaurantLocalDatasource});

  final stopwatch = Stopwatch();
  int steps = 0;

  Future<List<Restaurant>> fetchRestaurant() async {
    try {
      return await restaurantLocalDatasource.getRestaurants();
    } catch (e) {
      throw Exception("Gagal load data restoran: $e");
    }
  }

  //Secara iteratif mencari data dengan interpolation
  Future<SearchResponse?> findRestaurantByInterpolationAlgorithm(
    int price,
  ) async {
    List<Restaurant> restaurants = await restaurantLocalDatasource
        .getRestaurants();
    stopwatch.reset();
    stopwatch.start();
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
          return SearchResponse(
            data: restaurants[low],
            executionTimeUs: stopwatch.elapsedMicroseconds,
            steps: steps,
          );
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
        return SearchResponse(
          data: restaurants[pos],
          executionTimeUs: stopwatch.elapsedMicroseconds,
          steps: steps,
        ); // ditemukan
      }

      if (restaurants[pos].price < price) {
        low = pos + 1; // cari di kiri
      } else {
        high = pos - 1; // cari di kanan
      }
    }
    stopwatch.stop();
    _printNotFoundLog(steps, stopwatch);
    return SearchResponse(
      data: null,
      executionTimeUs: stopwatch.elapsedMicroseconds,
      steps: steps,
    );
  }

  //Cari data dengan interpolation secara rekursif
  Future<SearchResponse> findRestaurantByInterpolationRecursive(
    int price,
  ) async {
    List<Restaurant> restaurants = await restaurantLocalDatasource
        .getRestaurants();

    // RESET Stopwatch
    stopwatch.reset();
    stopwatch.start();

    log("--- MULAI PENCARIAN INTERPOLATION REKURSIF ---");
    restaurants.sort((a, b) => a.price.compareTo(b.price));

    if (restaurants.isEmpty) {
      stopwatch.stop();
      return SearchResponse(data: null, executionTimeUs: 0, steps: 0);
    }

    return _interpolationRecursive(
      restaurants,
      0,
      restaurants.length - 1,
      price,
      0,
    );
  }

  // Helper Rekursif sekarang mengembalikan SearchResponse
  SearchResponse _interpolationRecursive(
    List<Restaurant> restaurants,
    int low,
    int high,
    int price,
    int steps,
  ) {
    steps++;

    // Base Case: Not Found (Out of bounds)
    if (low > high ||
        price < restaurants[low].price ||
        price > restaurants[high].price) {
      stopwatch.stop();
      _printNotFoundLog(steps, stopwatch);
      return SearchResponse(
        data: null,
        executionTimeUs: stopwatch.elapsedMicroseconds,
        steps: steps,
      );
    }

    // Base Case: Flat Range / Avoid Divide by Zero
    if (restaurants[high].price == restaurants[low].price) {
      if (restaurants[low].price == price) {
        stopwatch.stop();
        _printSuccessLog(restaurants[low], steps, stopwatch);
        return SearchResponse(
          data: restaurants[low],
          executionTimeUs: stopwatch.elapsedMicroseconds,
          steps: steps,
        );
      } else {
        stopwatch.stop();
        _printNotFoundLog(steps, stopwatch);
        return SearchResponse(
          data: null,
          executionTimeUs: stopwatch.elapsedMicroseconds,
          steps: steps,
        );
      }
    }

    // rumus interpolation
    int pos =
        low +
        ((price - restaurants[low].price) *
            (high - low) ~/
            (restaurants[high].price - restaurants[low].price));

    log("Langkah ke-$steps | Posisi Tebakan: $pos");

    // Check Position
    if (restaurants[pos].price == price) {
      stopwatch.stop();
      _printSuccessLog(restaurants[pos], steps, stopwatch);
      return SearchResponse(
        data: restaurants[pos],
        executionTimeUs: stopwatch.elapsedMicroseconds,
        steps: steps,
      );
    }

    // Recursive Calls
    if (restaurants[pos].price < price) {
      return _interpolationRecursive(restaurants, pos + 1, high, price, steps);
    } else {
      return _interpolationRecursive(restaurants, low, pos - 1, price, steps);
    }
  }

  void _printSuccessLog(Restaurant result, int steps, Stopwatch sw) {
    log(
      "DITEMUKAN: ${result.name} dalam ${sw.elapsedMicroseconds} us ($steps langkah)",
    );
  }

  void _printNotFoundLog(int steps, Stopwatch sw) {
    log("TIDAK DITEMUKAN dalam ${sw.elapsedMicroseconds} us ($steps langkah)");
  }
}
