import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:xpider_chat/utils/constants/colors.dart';

import '../../utils/constants/sizes.dart';

class FunctionalButtons extends StatelessWidget {
  const FunctionalButtons({
    super.key,
    required this.icon,
    this.name,
    this.color,
    required this.onPressed
  });

  final IconData icon;
  final String? name;
  final VoidCallback onPressed;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: color ?? TColors.primary,
              side: BorderSide(color: color ?? TColors.primary)
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon),
                const SizedBox(height: TSizes.spaceBtwItems),
                Text(name!)
              ],
            ),
          )
      ),
    );
  }
}
