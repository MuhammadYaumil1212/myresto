import 'package:flutter/material.dart';

class ListRestaurant extends StatefulWidget {
  const ListRestaurant({super.key});

  @override
  State<ListRestaurant> createState() => _ListRestaurantState();
}

class _ListRestaurantState extends State<ListRestaurant> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: 100,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int itemCount) {
          return ListTile(title: Text("Restaurant $itemCount"));
        },
      ),
    );
  }
}
