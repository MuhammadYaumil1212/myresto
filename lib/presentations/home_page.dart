import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:myresto/presentations/sections/home_search_bar.dart';
import 'package:myresto/presentations/sections/list_restaurant.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(children: [HomeSearchBar(), ListRestaurant()]),
        ),
      ),
    );
  }
}
