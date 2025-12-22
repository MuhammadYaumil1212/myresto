import 'package:flutter/material.dart';
import 'package:myresto/utils/values/colors/colors.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Cari Harga.....",
          border: OutlineInputBorder(
            borderSide: BorderSide(color: MyColors.brown200),
            borderRadius: .all(.circular(20)),
          ),
        ),
      ),
    );
  }
}
