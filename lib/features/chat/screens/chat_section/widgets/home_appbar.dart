import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:xpider_chat/features/chat/screens/contacts/contacts.dart';
import 'package:xpider_chat/data/contacts/contacts_controller.dart';
import 'package:xpider_chat/features/chat/screens/groups/xpider_members.dart';
import '../../../../../common/appbar/appbar.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../controllers/chat_controller.dart';

class ThemeAppBar extends StatelessWidget {
  const ThemeAppBar({
    super.key, required this.textTitle,
  });

  final String textTitle;
  @override
  Widget build(BuildContext context) {
    RxDouble turns = 0.0.obs;
    final dark = THelperFunctions.isDarkMode(context);
    final controller = ChatController.instance;
    return TAppBar(
      showBackArrow: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              textTitle,
              style: GoogleFonts.merienda(
                  textStyle: Theme.of(context).textTheme.headlineMedium!.apply(
                      color: TColors.white, fontWeightDelta: 2))
          ),
          // Obx(() {
          //   if (controller.profileLoading.value){
          //     // Display a Shimmer Loader
          //     return const Padding(
          //       padding: EdgeInsets.only(top: 16),
          //       child: ShimmerLoader(height: 15, width: 200),
          //     );
          //   }
          //   return Text(controller.user.value.fullName.trim(), style: !dark? Theme.of(context).textTheme.headlineSmall!.apply(color: TColors.white) : Theme.of(context).textTheme.headlineSmall!.apply(color: TColors.white, fontSizeFactor: .75, fontWeightDelta: 2));
          // }),
        ],
      ),
      actions: [
        IconButton(onPressed: () async {
          ContactsController.instance.getContactPermission();
          final contactPermissionStatus = await Permission.contacts.status;
          if (contactPermissionStatus.isGranted) {
            Get.to(() => const Contacts(), transition: Transition.fade, duration: const Duration(milliseconds: 950));
          }
        }, icon: const Icon(Icons.add, color: Colors.white)),
        IconButton(onPressed: () => Get.to(() => const XpiderMembersScreen()), icon: const Icon(Iconsax.menu, color: TColors.white)),
        Obx(
        () => AnimatedRotation(turns: turns.value, duration: const Duration(seconds: 1), child: IconButton(
              onPressed: () {
                turns.value += 1;
                controller.getAllChatRooms();
                }, icon: const Icon
              (Icons.refresh, color: TColors.white)
          ),),
        )
      ],
    );
  }
}