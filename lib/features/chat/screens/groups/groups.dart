import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:iconsax/iconsax.dart';
import 'package:xpider_chat/common/appbar/appbar.dart';
import 'package:xpider_chat/features/chat/controllers/group_controller.dart';
import 'package:xpider_chat/features/chat/screens/groups/widgets/single_group.dart';
import 'package:xpider_chat/features/chat/screens/messages/group_message_screen.dart';
import 'package:xpider_chat/utils/constants/sizes.dart';

import '../../../../common/sort/sort_options.dart';
import '../../../../utils/constants/text_strings.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groupController = GroupController.instance;
    groupController.getAllGroupRooms();
    print(groupController.myGroups.length);
    return Scaffold(
      appBar: TAppBar(
        showBackArrow: false,
        title: Text("Groups", style: Theme.of(context).textTheme.headlineMedium),
      ),

      body: SingleChildScrollView(
        child:  Column(
          children: [
            const SizedBox(height: TSizes.spaceBtwItems),

            /// Groups Filters
            SortOptions(
              controller: groupController,
              list: const ["All Groups", "Pinned Groups", "Favourite Groups", "Archived Groups"]
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            Obx(
              () => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  // separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
                  itemCount: groupController.myGroups.length,
                  itemBuilder: (_, index) {
                    final group = groupController.myGroups[index];
                    return InkWell(
                      highlightColor: Colors.green.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(100),
                      onTap: () => Get.to(() => GroupMessageScreen(group: group)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: TSizes.spaceBtwItems, vertical: 5),
                        child: SingleGroup(group: group),
                      ));
                  },
                ),
            ),

            /// End Section
            const Divider(thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline),
                const SizedBox(width: TSizes.sm),
                Text(TTexts.securityStatement, style: Theme.of(context).textTheme.labelLarge)
              ],
            ),
            const SizedBox(height: TSizes.defaultSpace),
          ],
        ),
      ),
    );
  }
}
