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
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final items = widget.itemArray[index];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: MyColors.brown200, width: 1.5),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ExpansionTile(
              shape: const Border(),
              collapsedShape: const Border(),
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              collapsedIconColor: MyColors.brown500,
              iconColor: MyColors.brown500,
              title: Text(
                items.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: MyColors.brown500,
                ),
              ),
              subtitle: Text(
                items.cuisine,
                style: TextStyle(color: MyColors.brown500),
              ),
              trailing: Text(
                items.formatPrice(items.cheapestPrice),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              children: [
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: items.menuList.map((menu) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "• ${menu.name}",
                                style: TextStyle(
                                  color: MyColors.brown500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Text(
                              items.formatPrice(menu.price),
                              style: TextStyle(
                                color: MyColors.brown500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
