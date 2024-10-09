import 'package:flutter/material.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/sizes.dart';

class IconContainer extends StatelessWidget {
  const IconContainer({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.textColor,
    this.onPressed,
  });

  final IconData icon;
  final Color? iconColor, textColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.spaceBtwItems, vertical: TSizes.spaceBtwItems / 1.2),
      child: Row(
        children: [
          IconButton(onPressed: onPressed, icon: Icon(icon, color: iconColor ?? TColors.white)),
          const SizedBox(width: TSizes.spaceBtwItems),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium!.apply(color: textColor ?? TColors.white)),

              if (subtitle != null)
                const SizedBox(height: TSizes.spaceBtwItems / 2),
              if (subtitle != null)
                Text(subtitle!, style: Theme.of(context).textTheme.labelMedium!.apply(fontSizeFactor: 1.2, color: textColor ?? TColors.darkGrey)),
            ],
          ),
        ],
      ),
    );
  }
}