import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';

import '../controller/story_controller.dart';

class StoryViewScreen extends StatelessWidget {
  const StoryViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StoryViewController());

    return Scaffold(
      body: StoryView(
          storyItems: controller.storyItems,
          controller: controller.storyController, // pass controller here too
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
