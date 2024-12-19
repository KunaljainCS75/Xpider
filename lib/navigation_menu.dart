import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:xpider_chat/features/activity/screens/activity.dart';
import 'package:xpider_chat/features/chat/screens/chat_section/ChatSection.dart';
import 'package:xpider_chat/features/chat/screens/groups/create_groups.dart';
import 'package:xpider_chat/features/personalization/screens/settings/settings.dart';
import 'package:xpider_chat/utils/constants/colors.dart';
import 'package:xpider_chat/utils/helpers/helper_functions.dart';

import 'features/chat/screens/groups/groups.dart';


class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final darkMode = THelperFunctions.isDarkMode(context);

    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) => controller.selectedIndex.value = index,
          backgroundColor: darkMode? TColors.black : Colors.white,
          indicatorColor: darkMode? TColors.primary.withOpacity(0.4) : TColors.primary.withOpacity(0.4),

          destinations: [
            NavigationDestination(icon: Icon(Icons.email_outlined), label: 'Friends', selectedIcon: Icon(Icons.mail_rounded, color: darkMode ? Colors.white60:TColors.darkerGrey)),
            NavigationDestination(icon: Icon(Icons.group), label: 'Groups'),
            NavigationDestination(icon: Icon(Iconsax.setting), label: 'Settings'),
            NavigationDestination(icon: Icon(Iconsax.status), label: 'Status'),
          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController{
  final Rx<int> selectedIndex = 0.obs;

  final screens = [const ChatSectionScreen(), const GroupsScreen(), const SettingScreen(), const ActivityScreen()];
}