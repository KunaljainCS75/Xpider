import 'package:flutter/material.dart';
import 'package:xpider_chat/utils/constants/sizes.dart';
import 'package:xpider_chat/utils/helpers/helper_functions.dart';
import '../../../../../common/custom_shapes/containers/rounded_container.dart';
import '../../../../../utils/constants/colors.dart';

class FilterFunctions extends StatelessWidget {
  const FilterFunctions({
    super.key,
    required this.filterName,
    required this.onTap,
  });

  final String filterName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onTap,
          child: RoundedContainer(
            backgroundColor: THelperFunctions.isDarkMode(context)? Colors.black54: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              child: Text(filterName, style: Theme.of(context).textTheme.labelLarge!.apply(color: TColors.primary, fontWeightDelta: 2)),
            ),
          ),
        ),
        const SizedBox(width: TSizes.spaceBtwItems / 2)
      ],
    );
  }
}
