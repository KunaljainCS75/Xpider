import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:xpider_chat/common/images/rounded_images.dart';
import 'package:xpider_chat/features/chat/controllers/group_controller.dart';
import 'package:xpider_chat/features/chat/screens/groups/widgets/member_label.dart';
import '../../../../../common/custom_shapes/containers/rounded_container.dart';
import '../../../../../common/images/circular_images.dart';
import '../../../../../data/user/user.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../models/group_user_model.dart';

class EditListWithHeading extends StatelessWidget {
  const EditListWithHeading({
    super.key,
    this.isImage = true,
    required this.heading,
    this.imageUrl,
    required this.list,
    this.mainAxisExtent = 41,
    this.textColor = Colors.white,
    this.overLayColor = Colors.blueAccent
  });

  final bool isImage;
  final String heading;
  final String? imageUrl;
  final double mainAxisExtent;
  final Color? textColor, overLayColor;
  final List<GroupUserModel> list;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final admins = GroupController.instance.groupAdmins;
    print(admins.length);
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
              ],
            ),
          ),

          /// List
          Padding(
            padding: const EdgeInsets.symmetric(vertical: TSizes.defaultSpace, horizontal: TSizes.defaultSpace / 4),
            child: RoundedContainer(
              height: (list.length > 3) ? THelperFunctions.screenHeight() / 4 : THelperFunctions.screenHeight() / 7,
              backgroundColor: Colors.transparent,
              showBorder: true,
              borderColor: dark ? Colors.white70 : Colors.black45,
              child:Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: (list.isNotEmpty) ? GridView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: list.length,
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: TSizes.gridViewSpacing,
                        crossAxisSpacing: 1,
                        mainAxisExtent: mainAxisExtent
                    ),
                    itemBuilder:(_, index) {
                      final user = list[index];
                      // return MemberLabel(user: user, isRemoveButton: true,) ;
                      return MemberLabel(user: user);
                    },
                  ) : const Center(child: Text("No selected user at Member Position")),
                ),
              ),
            ),

        ]
    );
  }
}
