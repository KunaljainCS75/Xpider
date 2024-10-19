import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:status_view/status_view.dart';
import 'package:xpider_chat/features/activity/controller/story_controller.dart';

import '../../../common/custom_shapes/containers/rounded_container.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import 'add_story_screen.dart';


class StatusScreen extends StatelessWidget {
  const StatusScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StoryViewController());
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: TSizes.md, vertical: 0),
      child: Column(
        children: [
          const SizedBox(height: TSizes.spaceBtwSections),
          Obx(
            () => InkWell(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  StatusView(
                    radius: 40,
                    spacing: 15,
                    strokeWidth: 2,
                    indexOfSeenStatus: 2,
                    numberOfStatus: 5,
                    padding: 4,
                    centerImageUrl: "https://wallpaperaccess.com/full/3609297.jpg",
                    seenColor: Colors.grey,
                    unSeenColor: Colors.red,
                  ),
                  controller.storyItems.isEmpty
                      ? const RoundedContainer(backgroundColor: Colors.white,
                          child: Icon(Icons.add_circle_outlined, color: Colors.black87, size: TSizes.iconLg))
                      : const SizedBox()
                ],
              ),
              onTap: (){
                if (controller.storyItems.isEmpty){
                  Get.to(() => const AddStoryScreen());
                }
              },
            ),
          ),
          ListView.separated(
              shrinkWrap: true,
              separatorBuilder: (_, __) =>
              const SizedBox(height: TSizes.spaceBtwItems),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (_, index) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          child: StatusView(
                            radius: 40,
                            spacing: 15,
                            strokeWidth: 2,
                            indexOfSeenStatus: 2,
                            numberOfStatus: 5,
                            padding: 4,
                            centerImageUrl: "https://wallpaperaccess.com/full/3609297.jpg",
                            seenColor: Colors.grey,
                            unSeenColor: Colors.red,
                          ),
                          onTap: (){
                            // Get.to(() => S)
                          },
                        ),
                        const SizedBox(width: TSizes.spaceBtwItems),

                        Text("Uploader Name", style: Theme.of(context).textTheme.titleSmall!.apply(fontSizeFactor: 1.2)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("Last Updated"),
                        Text("17:00")
                      ],
                    )
                  ],
                );
              }
          ),
        ],
      ),

    );
  }
}