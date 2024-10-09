
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/sizes.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    super.key,
    this.icon = Iconsax.arrow_right_34,
    required this.prefixIcon,
    required this.onPressed,
    required this.title,
    required this.value,
    this.showIcon = true,
  });

  final IconData icon, prefixIcon;
  final VoidCallback onPressed;
  final String title, value;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TSizes.spaceBtwItems / 1.5),
        child: Row(
          children: [
            Icon(prefixIcon, size: 25),
            const SizedBox(width: TSizes.spaceBtwItems),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                const SizedBox(height: TSizes.spaceBtwItems / 2),
                Text(value, style: Theme.of(context).textTheme.bodyMedium!.apply(fontSizeFactor: 1.2), overflow: TextOverflow.ellipsis),
                showIcon? Icon(icon, size: 18) : Container(),
                const SizedBox(height: TSizes.spaceBtwItems / 2),
              ],
            )
          ],
        ),
      ),
    );
  }
}