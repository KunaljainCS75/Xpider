import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpider_chat/common/appbar/appbar.dart';
import 'package:xpider_chat/features/chat/models/group_chat_model.dart';
import 'package:xpider_chat/features/chat/screens/groups/widgets/type_message_bar_group.dart';
import 'package:xpider_chat/features/chat/screens/messages/widgets/chat_bubble.dart';
import '../../../../common/custom_shapes/containers/rounded_container.dart';
import '../../../../common/images/circular_images.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/popups/loaders.dart';
import '../../controllers/call_controller.dart';
import '../../controllers/group_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/group_message_model.dart';
import '../chat_section/widgets/type_messages_bar.dart';
import 'message_screen.dart';

class GroupMessageScreen extends StatelessWidget {
  const GroupMessageScreen({
    super.key,
    required this.group
  });

  final GroupRoomModel group;
  @override
  Widget build(BuildContext context) {

    final dark = THelperFunctions.isDarkMode(context);
    final groupController = GroupController.instance;
    final messageController = TextEditingController();

    final callController = CallController.instance;

    RxList<String> archivedGroups = UserController.instance.archivedGroups;
    RxList<String> pinnedGroups = UserController.instance.pinnedGroups;

    RxBool isNetwork = false.obs;
    if(group.groupProfilePicture != TImages.group){
      isNetwork = true.obs;
    }

    return Scaffold(
      backgroundColor: Colors.black87,
      /// Message typing area
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton:  TypeMessagesBarGroup(dark: dark, messageController: messageController, groupController: groupController, group: group),
      /// Chat name
      appBar: TAppBar(
        showBackArrow: false,
        bgColor: Colors.grey.shade900,
        title: InkWell(
          // onTap: () => Get.to(() => UserProfile(userProfile: group)),
          child: Obx(
                () => Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                Obx(() => IconButton(onPressed: () async {
                  if (!pinnedGroups.contains(group.id)) {
                    pinnedGroups.add(group.id);
                    Loaders.customToast(message: "'${group.groupName}' is added to Pins");
                  }
                  else {
                    pinnedGroups.remove(group.id);
                    Loaders.customToast(message: "'${group.groupName}' is removed from Pins");
                  }
                  await groupController.db.collection("Users")
                      .doc(groupController.auth.currentUser!.uid)
                      .update({"PinnedGroups" : pinnedGroups.map((user) => user.toString()).toList()});

                }, icon: pinnedGroups.contains(group.id)
                    ? const Icon(Icons.star, color: Colors.yellowAccent) : const Icon(Icons.star_border, color: TColors.white)),
                ),
                const SizedBox(width: TSizes.spaceBtwItems),

                CircularImage(height: 35, width: 35, image: group.groupProfilePicture, isNetworkImage: isNetwork.value),
                const SizedBox(width: TSizes.spaceBtwItems),
                Flexible(child: Text(group.groupName, style: Theme.of(context).textTheme.headlineLarge!.apply(fontSizeFactor: .5))),
              ],
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 0),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Obx(() => IconButton(onPressed: () async {
                  if (!archivedGroups.contains(group.id)) {
                    archivedGroups.add(group.id);
                    Loaders.customToast(message: "'${group.groupName}' is added to Archives");
                  }
                  else {
                    archivedGroups.remove(group.id);
                    Loaders.customToast(message: "'${group.groupName}' is removed from Archives");
                  }
                  await groupController.db.collection("Users")
                      .doc(groupController.auth.currentUser!.uid)
                      .update({"ArchivedGroups" : archivedGroups.map((user) => user.toString()).toList()});

                }, icon: archivedGroups.contains(group.id)
                    ? const Icon(Icons.arrow_circle_up_rounded, color: Colors.blue) : const Icon(Icons.arrow_circle_down_rounded)),
                ),
                const SizedBox(width: TSizes.spaceBtwItems / 2),
                InkWell(
                  radius: 50,
                  // onTap: () => Get.to(() => CalenderScreen(group: group)),
                  child: const Icon(Icons.date_range),
                ),
                const SizedBox(width: TSizes.spaceBtwItems),
                InkWell(
                  radius: 50,
                  onTap: () {

                    Get.defaultDialog(
                        title: "Choose calling type",
                        middleText: "Call via Video or Audio",
                        onConfirm: () {
                          Get.back();
                        },
                        confirm: RoundedContainer(
                          backgroundColor: Colors.black87,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
                            child: IconButton(
                                onPressed: () {
                                  // Get.to(() =>
                                  //     AudioCallScreen(receiver: group));
                                  // callController.callUser(UserController.instance.user.value, group, "audio");
                                },
                                icon: const Icon(Icons.call, color: Colors.green)),
                          ),
                        ),
                        cancel: RoundedContainer(
                          backgroundColor: Colors.black87,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
                            child: IconButton(
                                onPressed: () {
                                  // Get.to(() =>
                                  //     VideoCallScreen(receiver: group));
                                  // callController.callUser(UserController.instance.user.value, group, "video");
                                },
                                icon: const Icon(Icons.videocam, color: Colors.blue)),
                          ),
                        ),
                        onCancel: () => () => Get.back()
                    );
                  },
                  child: const Icon(Icons.call, color: Colors.green),
                ),
                const SizedBox(width: TSizes.spaceBtwItems),
                InkWell(
                  radius: 50,
                  onTap: () {},
                  child: const Icon(Icons.settings),
                ),
              ],
            ),
          )
        ],
      ),

      body: Stack(
        children: [

          /// Background chat Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/network/chatBackground.png',
              fit: BoxFit.cover,
            ),
          ),

          /// Stream of Messages
          Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: StreamBuilder<List<GroupMessageModel>>(
                stream: groupController.getGroupMessages(
                    memberId:  UserController.instance.user.value.id,
                    groupId:  group.id),
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if(snapshot.hasError || snapshot.data == null){
                    return const Center(child: Text("No messages"));
                  }
                  else {
                    return ListView.builder(
                      reverse: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final message = snapshot.data![index];
                        DateTime timestamp = DateTime.parse(message.lastMessageTime);
                        // String formattedTime = DateFormat('hh:mm a').format(timestamp);
                        bool showDate = false;
                        bool isFirstTime = false;
                        if (index == snapshot.data!.length - 1){
                          isFirstTime = true;
                        }
                        if (index < snapshot.data!.length - 1) {
                          // print("$index = ${snapshot.data![index].lastMessageTime.substring(0,10)}");
                          if (DateTime.parse(snapshot.data![index].lastMessageTime
                              .substring(0, 10)).isAfter(DateTime.parse(snapshot
                              .data![index + 1].lastMessageTime.substring(
                              0, 10)))) {
                            showDate = true;
                          }
                          else {
                            showDate = false;
                          }
                        }
                        return Column(
                          children: [
                            // if (snapshot.data!.isEmpty || index == index - snapshot.data!.length - 1)
                            if (isFirstTime)
                              DateTimeTag(text: snapshot.data![snapshot.data!.length - 1].lastMessageTime.substring(0,10)),
                            if (showDate)
                              DateTimeTag(text: snapshot.data![index].lastMessageTime.substring(0,10)),
                            ChatBubble(
                              message: message.senderMessage!,
                              imageUrl: message.imageUrl!,
                              // isThread: message.thread != ThreadModel.empty(),
                              time: message.lastMessageTime,
                              status: Status.read.toString(),
                              isRead: true,
                              isComing: !(groupController.auth.currentUser!.uid == message.senderId),
                            ),
                          ],
                        );

                      },
                    );
                  }
                }

            ),
          ),
        ],
      ),
    );
  }
}
// Column(
//   children: [
//     DateTimeTag(text: group.createdAt.substring(0, 19)),
//
//     /// Group Poster
//     Padding(
//       padding: const EdgeInsets.symmetric(vertical: TSizes.defaultSpace * 2),
//       child: Center(
//           child: RoundedContainer(
//             width: THelperFunctions.screenWidth() * 0.8,
//             backgroundColor: dark ? Colors.white10 : TColors.primary.withOpacity(0.1),
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: CircularImage(
//                     height: 100, width: 100,
//                     image: group.groupProfilePicture,
//                     isNetworkImage: group.groupProfilePicture != TImages.group,),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(group.createdBy.fullName, style: Theme.of(context).textTheme.titleMedium!.apply(color: TColors.primary)),
//                     Text(" has created this group", style: Theme.of(context).textTheme.titleMedium),
//                   ],
//                 ),
//                 const SizedBox(height: TSizes.spaceBtwItems / 2),
//
//                 Text("Total Group Participants : ${(group.admins.length + group.editors!.length + group.users!.length)}", style: TextStyle(color: TColors.darkGrey)),
//                 const SizedBox(height: TSizes.spaceBtwItems / 2),
//
//                 Text("${group.description == '' ? "No description Provided" : group.description}"),
//                 const SizedBox(height: TSizes.spaceBtwItems),
//
//                 InkWell(
//                   onTap: () {},
//                   child: RoundedContainer(
//                     backgroundColor: Colors.transparent,
//                     showBorder: true,
//                     borderColor: TColors.darkGrey,
//                     width: THelperFunctions.screenWidth() * 0.6,
//                     child: const Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.info_outline, color: TColors.primary),
//                           SizedBox(width: TSizes.spaceBtwItems),
//                           Text("Group Info", style: TextStyle(color: TColors.primary, fontWeight: FontWeight.bold))
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: TSizes.spaceBtwItems),
//
//                 InkWell(
//                   onTap: () {},
//                   child: RoundedContainer(
//                     backgroundColor: Colors.transparent,
//                     showBorder: true,
//                     borderColor: TColors.darkGrey,
//                     width: THelperFunctions.screenWidth() * 0.6,
//                     child: const Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.group_add_outlined, color: TColors.primary),
//                           SizedBox(width: TSizes.spaceBtwItems),
//                           Text("Add Members", style: TextStyle(color: TColors.primary, fontWeight: FontWeight.bold))
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: TSizes.spaceBtwItems / 2),
//               ],
//             ),
//           )),
//     ),
//   ],
// ),
