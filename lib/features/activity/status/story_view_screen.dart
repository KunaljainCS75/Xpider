import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:xpider_chat/utils/helpers/helper_functions.dart';

import '../controller/story_controller.dart';

class StoryViewScreen extends StatelessWidget {
  const StoryViewScreen({super.key, required this.storyItems});

  final List<StoryItem> storyItems;
  @override
  Widget build(BuildContext context) {
    final controller = StoryViewController.instance;
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      body: StoryView(
          storyItems: storyItems,
          controller: controller.storyController, // pass controller here too
        inline: false,
          indicatorColor: dark ? Colors.black54 : Colors.white54,
          indicatorForegroundColor: Colors.blue,
          onComplete:() => Get.back(),
          onStoryShow: (s, n) async {
            await Future.delayed(const Duration(seconds: 1));
            if (controller.seen < controller.storyItems.length){
              controller.seen++;
            }
          },
          // repeat: true, // should the stories be slid forever
          // onStoryShow: (s) {notifyServer(s)},
          // onComplete: () {},
          // onVerticalSwipeComplete: (direction) {
          //   if (direction == Direction.down) {
          //     Navigator.pop(context);
          //   }
          // } // To disable vertical swipe gestures, ignore this parameter.
        // Preferrably for inline story view.
      )
    );
  }
}
