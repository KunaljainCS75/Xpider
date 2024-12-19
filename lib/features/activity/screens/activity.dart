import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:xpider_chat/common/appbar/appbar.dart';
import 'package:xpider_chat/features/activity/controller/story_controller.dart';
import 'package:xpider_chat/features/activity/screens/calls/call_logs_screen.dart';
import 'package:xpider_chat/features/activity/screens/status/add_story_screen.dart';
import 'package:xpider_chat/features/activity/screens/status/status_screen.dart';
import 'package:xpider_chat/features/chat/controllers/call_controller.dart';
import 'package:xpider_chat/utils/helpers/helper_functions.dart';
import '../../../common/custom_shapes/containers/primary_header_container.dart';
import '../../../common/custom_shapes/containers/rounded_container.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final activityList = ["Status", "Call Logs"];

    RxInt index = 0.obs;
    RxDouble turns = 0.0.obs;

    return Scaffold(
        floatingActionButton: (index.value == 0)
            ? RoundedContainer(
          backgroundColor: Colors.black87,
          child: InkWell(
            child: const Icon(Icons.add, color: Colors.yellow, size: 50),
            onTap: () => Get.to(() => const AddStoryScreen()),
          ),
        )
            : const SizedBox(),
        body: Stack(children: [
      RoundedContainer(
        backgroundColor: Colors.transparent,
        child: Image(
          image: const AssetImage("assets/images/network/spiweb.png"),
          color: dark ? Colors.white10 : TColors.grey,
          height: MediaQuery.of(context).size.height,
        ),
      ),
      SingleChildScrollView(
        child: Column(
          children: [
            PrimaryHeaderContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// AppBar
                  TAppBar(
                      title: Text(
                        "Activity",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      showBackArrow: false,
                    actions: [
                      Obx(
                            () => AnimatedRotation(turns: turns.value, duration: const Duration(seconds: 1), child: IconButton(
                            onPressed: () {
                              turns.value += 1;
                              if (index.value == 1) {
                                CallController.instance.getAllCalls();
                              } else {
                                StoryViewController.instance.fetchFriendStories();
                                    index.value = 0;
                              }
                              }, icon: const Icon
                          (Icons.refresh)
                        ),),
                      )
                    ],
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  DefaultTabController(
                      length: 2,
                      child: TabBar(
                        dividerColor: Colors.transparent,
                        indicatorColor: Colors.yellow,
                        tabs: activityList
                            .map((activity) => Text(activity,
                                style: const TextStyle(color: TColors.white)))
                            .toList(),
                        onTap: (value) {
                          index.value = value;
                        },
                      )),
                  const SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),
            Obx(
              () {
                if (index.value == 0) {
                  return const StatusScreen();
                } else {
                  return const CallLogs();
                }
              },
            ),
          ],
        ),
      )
    ]));
  }
}
