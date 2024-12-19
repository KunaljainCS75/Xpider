import 'package:flutter/material.dart';

import '../../../../../common/custom_shapes/containers/rounded_container.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class GroupButtons extends StatelessWidget {
  const GroupButtons({
    super.key,
    required this.onTap,
    this.backgroundColor = Colors.white12,
    this.iconBackgroundColor = TColors.primary,
    this.iconColor = Colors.white,
    this.label = "Button",
    required this.icon,
  });

  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String? label;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onTap,
      child: RoundedContainer(
        radius: 100,
          backgroundColor: backgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: TSizes.defaultSpace / 4, horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RoundedContainer(
                    radius: 100,
                    backgroundColor: iconBackgroundColor, child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Icon(icon, color: iconColor, size: 15),
                )),
                const SizedBox(width: TSizes.spaceBtwItems / 2),
                Text(label ?? '', style: Theme.of(context).textTheme.labelLarge,)
              ],
            ),
          )
      ),
    );
  }
}
