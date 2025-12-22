import 'package:flutter/material.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Cari Restaurant......",
        border: OutlineInputBorder(borderRadius: .all(.circular(20))),
      ),
    );
  }
}
