import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:myresto/home/data/local/dataSources/restaurant_local_datasource.dart';
import 'package:myresto/home/data/repository/home_repository.dart';
import 'package:myresto/home/presentations/sections/home_search_bar.dart';
import 'package:myresto/home/presentations/sections/list_restaurant.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeRepository _repository;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final dataSource = RestaurantLocalDatasource();
    _repository = HomeRepository(restaurantLocalDatasource: dataSource);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          scrolledUnderElevation: 0.0,
          title: Text("Find My Restaurant"),
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: [
            HomeSearchBar(),
            Expanded(
              child: FutureBuilder(
                future: _repository.fetchRestaurant(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Data Kosong"));
                  }
                  final restaurant = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListRestaurant(itemArray: restaurant),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
