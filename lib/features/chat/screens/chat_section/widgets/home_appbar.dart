import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:xpider_chat/features/chat/screens/contacts/contacts.dart';
import 'package:xpider_chat/data/contacts/contacts_controller.dart';
import '../../../../../common/appbar/appbar.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../controllers/chat_controller.dart';

class ThemeAppBar extends StatelessWidget {
  const ThemeAppBar({
    super.key,
  });


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
              TTexts.homeAppbarTitle,
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
        IconButton(onPressed: () => Get.to(() => const Contacts(), transition: Transition.fade, duration: Duration(milliseconds: 950)), icon: const Icon(Icons.add)),
        PopupMenuButton(
            offset: Offset.fromDirection(1, 50),

            icon: const Icon(Iconsax.menu, color: TColors.white),
            itemBuilder: (BuildContext context) {
              return {'Favourites', 'Starred Messages', 'Pinned Chats'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            }
        ),
        Obx(
        () => AnimatedRotation(turns: turns.value, duration: const Duration(seconds: 1), child: IconButton(
              onPressed: () {
                turns.value += 1;
                controller.getAllChatRooms();}, icon: const Icon
              (Icons.refresh)
          ),),
        )
      ],
    );
  }
}