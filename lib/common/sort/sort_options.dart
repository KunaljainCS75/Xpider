import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../utils/constants/sizes.dart';


class SortOptions extends StatelessWidget {
  const SortOptions({
    super.key,
    required this.controller,
    required this.list,
  });

  final dynamic controller;
  final List<String> list;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
      child: DropdownButtonFormField(
        iconEnabledColor: Colors.white,
        iconDisabledColor: Colors.white,
        focusColor: Colors.white,
        dropdownColor: Colors.black,
        isExpanded: true,
        hint: const Text("Sort", style: TextStyle(color: Colors.white70)),

        onChanged: (value) {
         controller.sortChats(value!);
        },
        value: controller.selectedSortOption.value,

        decoration: InputDecoration(
          prefixIcon: const Icon(Iconsax.sort, color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 1), // Border when unfocused
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        items: list.map((item) => DropdownMenuItem(
            value: item,
            child: Text(item))).toList(),
      ),
    );
  }
}
