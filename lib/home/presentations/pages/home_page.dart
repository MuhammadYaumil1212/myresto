import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:myresto/home/data/local/dataSources/restaurant_local_datasource.dart';
import 'package:myresto/home/data/repository/home_repository.dart';
import 'package:myresto/home/presentations/sections/home_search_bar.dart';
import 'package:myresto/home/presentations/sections/list_restaurant.dart';

import '../../data/models/Restaurant.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeRepository _repository;
  late TextEditingController _controller;
  List<Restaurant> _allRestaurants = [];
  List<Restaurant> _displayedRestaurants = [];
  bool _isLoading = true;
  String _errorMessage = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = TextEditingController();
    final dataSource = RestaurantLocalDatasource();
    _repository = HomeRepository(restaurantLocalDatasource: dataSource);
    _initialLoad();
  }

  Future<void> _initialLoad() async {
    try {
      final data = await _repository.fetchRestaurant();
      if (mounted) {
        setState(() {
          _allRestaurants = data;
          _displayedRestaurants = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _handleSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _displayedRestaurants = _allRestaurants;
      });
      return;
    }
    int? searchPrice = int.tryParse(query);

    if (searchPrice != null) {
      setState(() => _isLoading = true);

      final result = await _repository.findRestaurantByInterpolationAlgorithm(
        searchPrice,
      );

      setState(() {
        _isLoading = false;
        if (result != null) {
          _displayedRestaurants = [result];
        } else {
          _displayedRestaurants = [];
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Interpolation Search hanya untuk Harga (Angka)"),
        ),
      );
    }
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
            HomeSearchBar(
              onChanged: (value) => _handleSearch(_controller.text),
              controller: _controller,
            ),
            Expanded(child: _buildListContent()),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Widget _buildListContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text("Error: $_errorMessage"));
    }

    if (_displayedRestaurants.isEmpty) {
      return const Center(child: Text("Data Tidak Ditemukan"));
    }

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListRestaurant(itemArray: _displayedRestaurants),
    );
  }
}
