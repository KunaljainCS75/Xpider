import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:status_view/status_view.dart';
import 'package:story_view/story_view.dart';
import 'package:xpider_chat/features/activity/controller/status_controller.dart';
import 'package:xpider_chat/features/activity/controller/story_controller.dart';
import 'package:xpider_chat/features/activity/status/story_view_screen.dart';
import 'package:xpider_chat/utils/helpers/helper_functions.dart';

import '../../../common/custom_shapes/containers/rounded_container.dart';
import '../../../common/texts/date_time_tag.dart';
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
    final statusController = Get.put(StatusController());
    final status = statusController.status;
    statusController.getStatusUpdates(statusController.user.value.id);
    statusController.fetchMyFriendsStatus();
    controller.fetchFriendStories();
    controller.fetchMyStories();


    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: TSizes.md, vertical: 0),
      child: Obx(
            () => Column(
        children: [
          const SizedBox(height: TSizes.spaceBtwSections),
          InkWell(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  StatusView(
                    radius: 40,
                    spacing: 15,
                    strokeWidth: 2,
                    indexOfSeenStatus: status.value.seenIndex,
                    numberOfStatus: controller.storyItems.length,
                    padding: 4,
                    centerImageUrl: status.value.imageUrl != ''
                        ? status.value.imageUrl
                        : statusController.user.value.profilePicture,
                    seenColor: Colors.grey,
                    unSeenColor: Colors.blue,
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
                } else {
                  Get.to(() => StoryViewScreen(storyItems: controller.storyItems));
                }
              },
            ),

          Column(
            children: [
              const SizedBox(height: 10),
              const Text("My Status"),
              if (status.value.lastUpdateTime.isNotEmpty)
                Text("Last updated : ${status.value.lastUpdateTime.substring(0, 16)}"),
            ],
          ),

          controller.friendStoriesList.isEmpty
              ? Padding(
                padding: EdgeInsets.only(top: THelperFunctions.screenHeight() * 0.2),
                child: Text("No Stories from your friends", style: Theme.of(context).textTheme.headlineMedium,),
              )
              : ListView.separated(
                shrinkWrap: true,
                separatorBuilder: (_, __) =>
                const SizedBox(height: TSizes.spaceBtwItems),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: statusController.friendsStatusList.length,
                itemBuilder: (_, index) {

                  final friendStatus = statusController.friendsStatusList[index];

                  final List<StoryItem> friendStories = controller.friendStoriesList[index];
                  print("yes ${controller.friendStoriesList.length} ");
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
                              indexOfSeenStatus: friendStatus.seenIndex,
                              numberOfStatus: friendStories.length,
                              padding: 4,
                              centerImageUrl: friendStatus.imageUrl != '' ? friendStatus.imageUrl : friendStatus.senderProfilePicture,
                              seenColor: Colors.grey,
                              unSeenColor: Colors.red,
                            ),
                            onTap: (){
                              Get.to(() => StoryViewScreen(
                                  storyItems: friendStories));
                            },
                          ),
                          const SizedBox(width: TSizes.spaceBtwItems),

                          Text(friendStatus.senderName, style: Theme.of(context).textTheme.titleSmall!.apply(fontSizeFactor: 1.2)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("Last Updated", style: TextStyle(color: Colors.yellow)),
                          DateTimeTag(text: friendStatus.lastUpdateTime.substring(0,16))
                        ],
                      )
                    ],
                  );
                }
          ),
        ],
      ),
      )
    );
  }
}