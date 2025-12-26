import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myresto/home/data/local/dataSources/restaurant_local_datasource.dart';
import 'package:myresto/home/data/models/search_response.dart';
import 'package:myresto/home/data/repository/home_repository.dart';
import 'package:myresto/home/presentations/sections/home_search_bar.dart';
import 'package:myresto/home/presentations/sections/list_restaurant.dart';
import 'package:myresto/utils/values/colors/colors.dart';

import '../../../running_time/presentations/data/dataSources/running_time_local_datasource.dart';
import '../../../running_time/presentations/data/repository/running_time_repository.dart';
import '../../../running_time/presentations/pages/running_time_page.dart';
import '../../data/models/Restaurant.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeRepository _repository;
  late final RunningTimeRepository _runningTimeRepository;
  late TextEditingController _controller;
  final int _batchSize = 20;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  List<Restaurant> _allRestaurants = [];
  List<Restaurant> _displayedRestaurants = [];
  bool _isRecursiveMode = false;
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
    _runningTimeRepository = RunningTimeRepository(
      datasource: RunningTimeLocalDatasource(),
    );
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

  void _toggleSearchMode() {
    setState(() {
      _isRecursiveMode = !_isRecursiveMode;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Mode Pencarian: ${_isRecursiveMode ? 'REKURSIF' : 'ITERATIF'}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _isRecursiveMode
            ? MyColors.brown500
            : MyColors.brown200,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _displayedRestaurants = _allRestaurants;
      });
      return;
    }

    int? searchPrice = int.tryParse(query);
    SearchResponse? result;
    String methodUsed = _isRecursiveMode ? "Rekursif" : "Iteratif";
    if (searchPrice != null) {
      setState(() => _isLoading = true);

      if (_isRecursiveMode) {
        // panggil fungsi rekursif
        result = await _repository.findRestaurantByInterpolationRecursive(
          searchPrice,
        );
      } else {
        // panggil fungsi iteratif
        result = await _repository.findRestaurantByInterpolationAlgorithm(
          searchPrice,
        );
      }

      if (result != null) {
        await _runningTimeRepository.saveSearchLog(
          method: methodUsed,
          price: searchPrice,
          timeUs: result.executionTimeUs,
          steps: result.steps,
        );
      }

      setState(() {
        _isLoading = false;
        if (result != null && result.data != null) {
          _displayedRestaurants = [result.data!];
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

  Future<void> _initialLoad() async {
    try {
      final data = await _repository.fetchRestaurant();
      if (mounted) {
        setState(() {
          _allRestaurants = data;
          _displayedRestaurants = _allRestaurants.take(_batchSize).toList();

          _isLoading = false;
          _isRecursiveMode = false;
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          scrolledUnderElevation: 0.0,
          title: Text("Find My Restaurant"),
          titleTextStyle: TextStyle(
            fontSize: 20,
            color: MyColors.brown400,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: Colors.white,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _toggleSearchMode,
          elevation: 2.0,
          backgroundColor: Colors.white,
          shape: CircleBorder(
            side: BorderSide(
              color: _isRecursiveMode ? MyColors.brown500 : MyColors.brown300,
              width: 2,
            ),
          ),
          child: SvgPicture.asset(
            "assets/icons/rekursif_icon.svg",
            color: _isRecursiveMode ? MyColors.brown500 : MyColors.brown400,
            width: 30,
            height: 30,
          ),
        ),
        drawer: Drawer(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  "Total Jumlah Restaurant",
                  style: TextStyle(
                    fontSize: 18,
                    color: MyColors.brown400,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${_allRestaurants.length} Restaurant",
                  style: TextStyle(
                    fontSize: 15,
                    color: MyColors.brown400,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                InkWell(
                  onTap: () {
                    _controller.clear();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RunningTimePage(),
                      ),
                    );
                  },
                  splashColor: MyColors.brown100,
                  borderRadius: .all(.circular(10)),
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: MyColors.brown200,
                        width: 1.5,
                      ),
                      borderRadius: .circular(10.0),
                    ),
                    child: const ListTile(
                      title: Text(
                        "Laporan Running Time",
                        maxLines: 1,
                        style: TextStyle(
                          color: MyColors.brown400,
                          fontWeight: .bold,
                          overflow: .ellipsis,
                        ),
                      ),
                      trailing: Icon(
                        Icons.keyboard_arrow_right,
                        color: MyColors.brown400,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  "versi 1.0",
                  style: TextStyle(
                    fontSize: 13,
                    color: MyColors.brown400,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
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
