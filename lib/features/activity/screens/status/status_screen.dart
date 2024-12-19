import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:status_view/status_view.dart';
import 'package:story_view/story_view.dart';
import 'package:xpider_chat/features/activity/controller/status_controller.dart';
import 'package:xpider_chat/features/activity/controller/story_controller.dart';
import 'package:xpider_chat/features/activity/screens/status/story_view_screen.dart';
import 'package:xpider_chat/utils/helpers/helper_functions.dart';
import '../../../../common/custom_shapes/containers/rounded_container.dart';
import '../../../../common/texts/date_time_tag.dart';
import '../../../../utils/constants/sizes.dart';
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
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      StatusView(
                        radius: 30,
                        spacing: 15,
                        strokeWidth: 2,
                        indexOfSeenStatus: status.value.seenIndex,
                        numberOfStatus: controller.storyItems.length,
                        padding: 4,
                        centerImageUrl: controller.storyItems.isNotEmpty
                            ? status.value.imageUrl
                            : statusController.user.value.profilePicture,
                        seenColor: Colors.grey,
                        unSeenColor: Colors.blue,
                      ),
                      statusController.isStatusLoading.value ? const CircularProgressIndicator() : const SizedBox()
                    ],
                  ),
                  controller.storyItems.isEmpty
                      ? const RoundedContainer(backgroundColor: Colors.white,
                          child: Icon(Icons.add_circle_outlined, color: Colors.black87, size: TSizes.iconLg))
                      : const SizedBox(),


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
              const Text("My Status", style: TextStyle(fontSize: 12)),
              if (status.value.lastUpdateTime.isNotEmpty)
                Text(DateFormat("hh:mm a, d-MMMM-yyyy").format(DateTime.parse(status.value.lastUpdateTime.substring(0, 16))), style: const TextStyle(fontSize: 10)),
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
                  try {
                    // print(controller.friendStoriesList.length.toString() +
                    //     "eeeeeeeeeeeeeeee");
                    final friendStatus = statusController
                        .friendsStatusList[index];


                    final List<StoryItem> friendStories = controller
                        .friendStoriesList[index];
                    print("yes ${controller.friendStoriesList.length} ");

                    if (friendStories.isNotEmpty) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                InkWell(
                                  child: StatusView(
                                    radius: 30,
                                    spacing: 15,
                                    strokeWidth: 2,
                                    indexOfSeenStatus: friendStatus.seenIndex,
                                    numberOfStatus: friendStories.length,
                                    padding: 4,
                                    centerImageUrl: friendStatus.imageUrl != ''
                                        ? friendStatus.imageUrl
                                        : friendStatus.senderProfilePicture,
                                    seenColor: Colors.grey,
                                    unSeenColor: Colors.red,
                                  ),
                                  onTap: () {
                                    Get.to(() =>
                                        StoryViewScreen(
                                            storyItems: friendStories));
                                  },
                                ),
                                const SizedBox(width: TSizes.spaceBtwItems),
                            
                                Flexible(
                                  child: Text(friendStatus.senderName, style: Theme.of(context).textTheme.titleSmall!
                                      .apply(fontSizeFactor: 0.8), overflow: TextOverflow.ellipsis,),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text("Last Updated",
                                  style: TextStyle(color: Colors.yellow, fontSize: 10)),
                              Text(DateFormat("hh:mm a").format(DateTime.parse(friendStatus.lastUpdateTime.substring(0, 16))), style: const TextStyle(fontSize: 10),),
                              Text(DateFormat("d MMM, yyyy").format(DateTime.parse(friendStatus.lastUpdateTime.substring(0, 16))), style: const TextStyle(fontSize: 8),),

                            ],
                          )
                        ],
                      );
                    }
                  } catch (e) {
                    print(e);
                  }
                }
          ),

        ],
      ),
      )
    );
  }
}