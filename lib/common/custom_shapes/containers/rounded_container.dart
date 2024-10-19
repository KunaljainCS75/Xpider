
import 'package:flutter/material.dart';
import '../../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';

class RoundedContainer extends StatelessWidget {
  const RoundedContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.isMessageContainer = false,
    this.margin,
    this.radius = TSizes.cardRadiusLg,
    this.borderColor = TColors.borderPrimary,
    this.showBorder = false,
    this.backgroundColor = TColors.white, this.constraints,
  });

  final double? width;
  final double? height;
  final double radius;
  final bool isMessageContainer;
  final Widget? child;
  final bool showBorder;
  final Color borderColor;
  final Color backgroundColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    return isMessageContainer ?Container(
      width: width,
      height: height,
      constraints: constraints,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(radius), bottomRight: Radius.circular(radius)),
        color: backgroundColor,
        border: showBorder? Border.all(color: borderColor, width: 2) : null,
      ),
      child: child,
    ) : Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: backgroundColor,
          border: showBorder? Border.all(color: borderColor, width: 2) : null,
      ),
      child: child,
    );
  }
}

