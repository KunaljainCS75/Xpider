import 'package:flutter/material.dart';
import 'package:xpider_chat/common/images/rounded_images.dart';
import '../../../../../common/custom_shapes/containers/rounded_container.dart';
import '../../../../../common/images/circular_images.dart';
import '../../../../../data/user/user.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../models/group_user_model.dart';

class ListWithHeading extends StatelessWidget {
  const ListWithHeading({
    super.key,
    this.isImage = true,
    required this.heading,
    this.imageUrl,
    required this.list,
    this.textColor = Colors.white,
    this.overLayColor = Colors.blueAccent
  });

  final bool isImage;
  final String heading;
  final String? imageUrl;
  final Color? textColor, overLayColor;
  final List<GroupUserModel> list;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Column(
        children: [

          /// Heading
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isImage ? CircularImage(overLayColor: overLayColor, image: imageUrl, height: 40, width: 40, backgroundColor: Colors.white) : const SizedBox(),
                isImage ? const SizedBox(width: TSizes.spaceBtwItems) : const SizedBox(),
                Text(heading, style: Theme.of(context).textTheme.titleLarge!.apply(fontSizeFactor: 1.2, color: textColor)),
                Text(" ( ${list.length.toString()} )", style: Theme.of(context).textTheme.titleSmall!.apply(fontSizeFactor: 1.2, color: textColor)),
              ],
            ),
          ),

          /// List
          Padding(
            padding: const EdgeInsets.symmetric(vertical: TSizes.defaultSpace, horizontal: TSizes.defaultSpace),
            child: RoundedContainer(
              height: (list.length > 2) ? 200 : 65,
              backgroundColor: Colors.transparent,
              showBorder: true,
              borderColor: dark ? Colors.white70 : Colors.black45,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: (list.isNotEmpty) ? GridView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: list.length,
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: TSizes.gridViewSpacing,
                      crossAxisSpacing: TSizes.gridViewSpacing,
                      mainAxisExtent: 41
                  ),
                  itemBuilder:(_, index) {
                    final user = list[index];

                    return Row(
                      children: [

                        /// Profile DP
                        CircularImage(image:  user.profilePicture, isNetworkImage: true, height: 40, width: 40),
                        // CircleAvatar(),
                        const SizedBox(width: TSizes.spaceBtwItems / 2),

                        /// Name and Number
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.firstName, style: Theme.of(context).textTheme.titleMedium),
                              Text("(${user.phoneNumber})", style: Theme.of(context).textTheme.labelLarge),

                              // Flexible(child: Text("Name", style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis,)),
                              // Flexible(child: Text("(+915550011100)", style: Theme.of(context).textTheme.labelLarge, overflow: TextOverflow.ellipsis,)),
                            ],
                          ),
                        )

                      ],
                    );
                  },
                ) : const Center(child: Text("No selected user at Member Position")),
              ),
            ),
          ),
        ]
    );
  }
}
