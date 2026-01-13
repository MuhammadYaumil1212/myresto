import 'dart:developer';

import 'package:myresto/home/data/local/dataSources/restaurant_local_datasource.dart';
import 'package:myresto/home/data/models/Restaurant.dart';
import 'package:myresto/home/data/models/search_response.dart';

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

  // =========================================================
  // INTERPOLATION SEARCH ITERATIF
  // =========================================================
  Future<SearchResponse> findRestaurantByInterpolationAlgorithm(
    int price,
  ) async {
    final stopwatch = Stopwatch();
    int steps = 0;

    List<Restaurant> restaurants = await restaurantLocalDatasource
        .getRestaurants();

    List<Map<String, dynamic>> flatData = [];

    for (var restaurant in restaurants) {
      if (restaurant.menuList.isNotEmpty) {
        for (var menu in restaurant.menuList) {
          flatData.add({
            'price': menu.price,
            'restaurant': restaurant,
            'menuName': menu.name,
          });
        }
      }
    }

    flatData.sort((a, b) => (a['price'] as int).compareTo(b['price'] as int));

    if (flatData.isEmpty) {
      return SearchResponse(data: null, executionTimeUs: 0, steps: 0);
    }

    stopwatch.start();
    log("--- MULAI PENCARIAN ---");
    log("Mencari harga $price di antara ${flatData.length} menu.");

    int low = 0;
    int high = flatData.length - 1;

    int getPrice(int index) => flatData[index]['price'] as int;

    while (low <= high && price >= getPrice(low) && price <= getPrice(high)) {
      steps++;

      // Cek ujung bawah == ujung atas (hindari division by zero)
      if (getPrice(low) == getPrice(high)) {
        if (getPrice(low) == price) {
          stopwatch.stop();
          _printSuccessLog(flatData[low], steps, stopwatch);
          return SearchResponse(
            data: flatData[low]['restaurant'] as Restaurant,
            executionTimeUs: stopwatch.elapsedMicroseconds,
            steps: steps,
          );
        }
        break;
      }

      // Rumus Interpolation
      int pos =
          low +
          ((price - getPrice(low)) *
              (high - low) ~/
              (getPrice(high) - getPrice(low)));

      log(
        "Step $steps | pos=$pos harga=${getPrice(pos)} (${flatData[pos]['menuName']})",
      );

      if (getPrice(pos) == price) {
        stopwatch.stop();
        _printSuccessLog(flatData[pos], steps, stopwatch);
        return SearchResponse(
          data: flatData[pos]['restaurant'] as Restaurant,
          executionTimeUs: stopwatch.elapsedMicroseconds,
          steps: steps,
        );
      }

      if (getPrice(pos) < price) {
        low = pos + 1;
      } else {
        high = pos - 1;
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

  // =========================================================
  // INTERPOLATION SEARCH - REKURSIF
  // =========================================================
  Future<SearchResponse> findRestaurantByInterpolationRecursive(
    int price,
  ) async {
    final stopwatch = Stopwatch();

    List<Restaurant> restaurants = await restaurantLocalDatasource
        .getRestaurants();

    List<Map<String, dynamic>> flatData = [];
    for (var restaurant in restaurants) {
      if (restaurant.menuList.isNotEmpty) {
        for (var menu in restaurant.menuList) {
          flatData.add({
            'price': menu.price,
            'restaurant': restaurant,
            'menuName': menu.name,
          });
        }
      }
    }

    flatData.sort((a, b) => (a['price'] as int).compareTo(b['price'] as int));

    if (flatData.isEmpty) {
      return SearchResponse(data: null, executionTimeUs: 0, steps: 0);
    }

    stopwatch.start();
    log("--- MULAI PENCARIAN REKURSIF ---");

    return _interpolationRecursive(
      flatData,
      0,
      flatData.length - 1,
      price,
      0,
      stopwatch,
    );
  }

  SearchResponse _interpolationRecursive(
    List<Map<String, dynamic>> listData,
    int low,
    int high,
    int price,
    int steps,
    Stopwatch stopwatch,
  ) {
    steps++;

    int getPrice(int index) => listData[index]['price'] as int;
    //basis (data nya tidak ditemukan)
    if (low > high || price < getPrice(low) || price > getPrice(high)) {
      stopwatch.stop();
      _printNotFoundLog(steps, stopwatch);
      return SearchResponse(
        data: null,
        executionTimeUs: stopwatch.elapsedMicroseconds,
        steps: steps,
      );
    }
    //pengecekan division by zero
    if (getPrice(low) == getPrice(high)) {
      if (getPrice(low) == price) {
        stopwatch.stop();
        _printSuccessLog(listData[low], steps, stopwatch);
        return SearchResponse(
          data: listData[low]['restaurant'] as Restaurant,
          executionTimeUs: stopwatch.elapsedMicroseconds,
          steps: steps,
        );
      }
      stopwatch.stop();
      _printNotFoundLog(steps, stopwatch);
      return SearchResponse(
        data: null,
        executionTimeUs: stopwatch.elapsedMicroseconds,
        steps: steps,
      );
    }
    //proses perhitungan posisi interpolation
    int pos =
        low +
        ((price - getPrice(low)) *
            (high - low) ~/
            (getPrice(high) - getPrice(low)));

    log(
      "Recursive step $steps | pos=$pos harga=${getPrice(pos)} (${listData[pos]['menuName']})",
    );
    //memeriksa apakah data yang ada di array, sama dengan data yang kita inputkan
    if (getPrice(pos) == price) {
      stopwatch.stop();
      _printSuccessLog(listData[pos], steps, stopwatch);
      return SearchResponse(
        data: listData[pos]['restaurant'] as Restaurant,
        executionTimeUs: stopwatch.elapsedMicroseconds,
        steps: steps,
      );
    }
    //kalau data yang ada di array lebih kecil dari input
    if (getPrice(pos) < price) {
      return _interpolationRecursive(
        listData,
        pos + 1,
        high,
        price,
        steps,
        stopwatch,
      );
    } else {
      return _interpolationRecursive(
        listData,
        low,
        pos - 1,
        price,
        steps,
        stopwatch,
      );
    }
  }

  void _printSuccessLog(Map<String, dynamic> result, int steps, Stopwatch sw) {
    var restoName = (result['restaurant'] as Restaurant).name;
    var menuName = result['menuName'];
    var price = result['price'];
    log("DITEMUKAN: $menuName ($price) di $restoName");
    log("Waktu: ${sw.elapsedMicroseconds} ms ($steps langkah)");
  }

  void _printNotFoundLog(int steps, Stopwatch sw) {
    log("TIDAK DITEMUKAN dalam ${sw.elapsedMicroseconds} ms ($steps langkah)");
  }
}
