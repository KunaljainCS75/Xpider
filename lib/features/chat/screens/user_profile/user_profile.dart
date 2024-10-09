import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';
import 'package:xpider_chat/common/custom_shapes/containers/rounded_container.dart';
import 'package:xpider_chat/common/images/circular_images.dart';
import 'package:xpider_chat/common/images/rounded_images.dart';
import 'package:xpider_chat/data/user/user.dart';
import 'package:xpider_chat/features/chat/screens/messages/message_screen.dart';
import 'package:xpider_chat/features/personalization/screens/profile/widget/change_name.dart';
import 'package:xpider_chat/utils/constants/colors.dart';
import 'package:xpider_chat/utils/constants/sizes.dart';

import '../../../../common/buttons/functional_buttons.dart';
import '../../../../common/containers/icon_container.dart';
import '../../../../utils/constants/image_strings.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({
    super.key,
    required this.userProfile
  });

  final UserModel userProfile;

  @override
  Widget build(BuildContext context) {
    RxBool isNetwork = false.obs;
    if (userProfile.profilePicture != TImages.user){
      isNetwork.value = true;
    }
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SingleChildScrollView(
        child: Container(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircularImage(
                    image: isNetwork.value ? userProfile.profilePicture : TImages.user,
                    isNetworkImage: isNetwork.value,
                    height: 125,
                    width: 125,
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  Text(userProfile.fullName, style: Theme.of(context).textTheme.headlineMedium),
                  Text(userProfile.email, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: TSizes.spaceBtwItems * 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FunctionalButtons(icon: Iconsax.call, name: 'Voice Call', color: Colors.yellow, onPressed: (){}),
                      FunctionalButtons(icon: Iconsax.video, name: 'Video Call', onPressed: (){}, color: Colors.lightBlueAccent,),
                      FunctionalButtons(icon: Iconsax.message, name: 'Messages', onPressed: () => Get.off(() => MessageScreen(userModelReceiver: userProfile)))
                    ],
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  IconContainer(icon: Iconsax.information, title: "About", subtitle: userProfile.about),
                  IconContainer(icon: Iconsax.call4, title: "Mobile", subtitle: userProfile.phoneNumber),
                  IconContainer(icon: Icons.favorite, title: "Add to Favourites", onPressed: () {}),
                  IconContainer(icon: Icons.block, iconColor: Colors.redAccent, title: "Block", textColor: Colors.redAccent, onPressed: () {}),
                  IconContainer(icon: Iconsax.dislike, iconColor: Colors.redAccent, title: "Report", textColor: Colors.redAccent, onPressed: () {}),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}





