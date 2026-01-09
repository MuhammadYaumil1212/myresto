import 'package:flutter/material.dart';
import 'package:myresto/home/data/models/Restaurant.dart';
import 'package:myresto/utils/values/colors/colors.dart';

class ListRestaurant extends StatefulWidget {
  final List<Restaurant> itemArray;
  final int targetPrice;
  const ListRestaurant({
    super.key,
    required this.itemArray,
    required this.targetPrice,
  });

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
        bool shouldExpand =
            widget.targetPrice != 0 &&
            items.menuList.any((menu) => menu.price == widget.targetPrice);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: MyColors.brown200, width: 1.5),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ExpansionTile(
              initiallyExpanded: shouldExpand,
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
              subtitle: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    items.cuisine,
                    style: TextStyle(fontSize: 18, color: MyColors.brown500),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${items.rating} / 5",
                    style: TextStyle(fontSize: 14, color: Colors.orange),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    items.review,
                    softWrap: true,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: MyColors.brown300),
                  ),
                ],
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
                                backgroundColor:
                                    widget.targetPrice == menu.price
                                    ? Colors.yellow.withOpacity(0.7)
                                    : Colors.transparent,
                                color: MyColors.brown500,
                                fontWeight: widget.targetPrice == menu.price
                                    ? FontWeight.bold
                                    : FontWeight.w500,
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
