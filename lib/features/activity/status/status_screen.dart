import 'package:flutter/material.dart';

import '../../../common/custom_shapes/containers/rounded_container.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';


class StatusScreen extends StatelessWidget {
  const StatusScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: TSizes.md, vertical: 0),
      child: ListView.separated(
          shrinkWrap: true,
          separatorBuilder: (_, __) =>
          const SizedBox(height: TSizes.spaceBtwItems),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (_, index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    RoundedContainer(
                      radius: 50,
                      child: SizedBox(height: 50, width: 50),
                      showBorder: true,
                      borderColor: TColors.primary,
                      backgroundColor: Colors.transparent,
                    ),
                    const SizedBox(width: TSizes.spaceBtwItems),

                    Text("Uploader Name", style: Theme.of(context).textTheme.titleSmall!.apply(fontSizeFactor: 1.2)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Last Updated"),
                    Text("17:00")
                  ],
                )
              ],
            );
          }
      ),

    );
  }
}