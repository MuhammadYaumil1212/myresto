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
  final int _batchSize = 20;
  bool _isLoadingMore = false;
  bool _hasMore = true;
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
          _displayedRestaurants = _allRestaurants.take(_batchSize).toList();

          _isLoading = false;
          _hasMore = _allRestaurants.length > _displayedRestaurants.length;
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

  void _loadMoreData() async {
    if (_isLoadingMore || !_hasMore || _controller.text.isNotEmpty) return;

    setState(() {
      _isLoadingMore = true;
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    setState(() {
      int currentLength = _displayedRestaurants.length;
      List<Restaurant> nextBatch = _allRestaurants
          .skip(currentLength)
          .take(_batchSize)
          .toList();

      if (nextBatch.isEmpty) {
        _hasMore = false;
      } else {
        _displayedRestaurants.addAll(nextBatch);
      }

      _isLoadingMore = false;
    });
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
        _hasMore = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Interpolation Search hanya untuk Angka, tanpa spesial karakter",
          ),
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
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (!_isLoadingMore &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                    _loadMoreData();
                  }
                  return true;
                },
                child: Column(
                  children: [
                    Expanded(child: _buildListContent()),
                    if (_isLoadingMore)
                      const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: CupertinoActivityIndicator(),
                      ),
                  ],
                ),
              ),
            ),
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
