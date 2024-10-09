import 'package:flutter/material.dart'
;

import '../../utils/constants/colors.dart';
import '../../utils/constants/sizes.dart';
import '../custom_shapes/containers/rounded_container.dart';
class OptionIconButton extends StatelessWidget {
  const OptionIconButton({
    super.key,
    this.height = 50,
    this.width = 50,
    this.backgroundColor = TColors.primary,
    required this.onPressed,
    this.icon = Icons.call,
    this.iconColor = Colors.white,
    this.iconSize = TSizes.iconLg,
    this.buttonLabel = "Button"
  });

  final double height;
  final double width;
  final Color backgroundColor;
  final VoidCallback onPressed;
  final IconData icon;
  final Color? iconColor;
  final double iconSize;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RoundedContainer(
          backgroundColor: backgroundColor,
          height: height, width: width,
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, size: iconSize, color: iconColor),
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        Text(buttonLabel, style: Theme.of(context).textTheme.titleMedium,),
      ],
    );
  }
}