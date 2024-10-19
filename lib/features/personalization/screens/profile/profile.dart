import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:xpider_chat/common/custom_shapes/containers/rounded_container.dart';
import 'package:xpider_chat/features/personalization/screens/profile/widget/change_name.dart';
import 'package:xpider_chat/features/personalization/screens/profile/widget/profile_menu.dart';
import 'package:xpider_chat/utils/constants/colors.dart';

import '../../../../common/appbar/appbar.dart';
import '../../../../common/images/circular_images.dart';
import '../../../../common/loaders/shimmer_loader.dart';
import '../../../../common/texts/section_heading.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../chat/controllers/user_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    return Scaffold(
      appBar: const TAppBar(
        title: Text('Profile'),
        showBackArrow: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.05, horizontal: TSizes.defaultSpace),
        child: Column(
          children: [
            /// Profile Picture
            SizedBox(

              child: Stack(
                alignment: Alignment.center,
                children : [
                  Obx((){
                  final networkImage = controller.user.value.profilePicture;
                  final image = networkImage.isNotEmpty? networkImage : "assets/images/user/user.png";
                  return controller.imageUploading.value?
                    const ShimmerLoader(height: 120, width: 120, radius: 120, color: Colors.blue,)
                        : CircularImage(image: image, width: 120, height: 120, isNetworkImage: (controller.user.value.profilePicture != TImages.user));
                }),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: RoundedContainer(
                      radius: 400,
                      backgroundColor: TColors.primary,
                      child: IconButton(icon: const Icon(Icons.camera_alt_outlined),
                      onPressed: () => controller.uploadUserProfilePicture())),
                ),
                ]
              ),
            ),
            /// Details
            const SizedBox(height: TSizes.spaceBtwItems / 2),
            const SizedBox(height: TSizes.spaceBtwItems),

            /// Heading Profile Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SectionHeading(title: 'Profile Information', showActionButton: false, onPressed: () {}),
                IconButton(icon: const Icon(Iconsax.edit, size: 30), onPressed: () => Get.to(() => const ChangeName()))
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            /// Information
            ProfileMenu(prefixIcon: Iconsax.profile_circle, title: 'Name', value: controller.user.value.fullName, showIcon: false, onPressed: () {}),
            ProfileMenu(prefixIcon: Icons.person_search_sharp, title: 'Username (Permanent)', value: controller.user.value.username,showIcon: false, onPressed: (){}),
            ProfileMenu(prefixIcon: Iconsax.information, title: 'About', value: controller.user.value.about, onPressed: (){}, showIcon: false),
          ],
        ),
      ),
    );
  }
}


