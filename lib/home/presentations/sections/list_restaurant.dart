import 'package:flutter/material.dart';
import 'package:myresto/home/data/models/Restaurant.dart';
import 'package:myresto/utils/values/colors/colors.dart';

class ListRestaurant extends StatefulWidget {
  final List<Restaurant> itemArray;
  const ListRestaurant({super.key, required this.itemArray});

  @override
  State<ListRestaurant> createState() => _ListRestaurantState();
}

class _ListRestaurantState extends State<ListRestaurant> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.itemArray.length,
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (BuildContext context, int itemCount) {
        final items = widget.itemArray[itemCount];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: MyColors.brown200,
                width: 1.5,
              ), // Defines the border
              borderRadius: BorderRadius.circular(
                10.0,
              ), // Optional: Adds rounded corners
            ),
            child: ListTile(
              title: Text(
                items.name,
                maxLines: 1,
                style: TextStyle(fontWeight: .bold, overflow: .ellipsis),
              ),
              subtitle: Text(
                items.cuisine,
                overflow: TextOverflow.clip,
                textAlign: TextAlign.justify,
                maxLines: 2,
              ),
              trailing: Text(
                items.formattedPrice,
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
        );
      },
    );
  }
}
