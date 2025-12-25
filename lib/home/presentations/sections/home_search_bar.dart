import 'package:flutter/material.dart';
import 'package:myresto/utils/values/colors/colors.dart';

class HomeSearchBar extends StatelessWidget {
  final Function(String) onChanged;
  final TextEditingController controller;
  const HomeSearchBar({
    super.key,
    required this.onChanged,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        keyboardType: TextInputType.number,
        onChanged: onChanged,
        controller: controller,
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
