import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:xpider_chat/common/appbar/appbar.dart';
import 'package:xpider_chat/features/chat/models/group_chat_model.dart';
import 'package:xpider_chat/features/chat/screens/groups/group_profile.dart';
import 'package:xpider_chat/features/chat/screens/groups/widgets/type_message_bar_group.dart';
import 'package:xpider_chat/features/chat/screens/messages/widgets/chat_bubble.dart';
import '../../../../common/custom_shapes/containers/rounded_container.dart';
import '../../../../common/emoji/emoji_keyboard.dart';
import '../../../../common/images/circular_images.dart';
import '../../../../common/texts/date_format.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/popups/loaders.dart';
import '../../controllers/group_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/group_message_model.dart';

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
    final userController = UserController.instance;
    final db = groupController.db;
    final auth = groupController.auth;

    groupController.fetchMyGroupProfile(auth.currentUser!.uid, group);

    RxList<String> archivedGroups = UserController.instance.archivedGroups;
    RxList<String> pinnedGroups = UserController.instance.pinnedGroups;

    RxBool isNetwork = false.obs;
    if(group.groupProfilePicture != TImages.group){
      isNetwork = true.obs;
    }

    return PopScope(
      onPopInvoked: (canPop){
        groupController.getAllGroupRooms();
        userController.showEmoji.value = false;
      },
      child: Scaffold(
        backgroundColor: Colors.black87,

        /// Message typing area
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Obx(
              () => SizedBox(
              height: 500,child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              TypeMessagesBarGroup(dark: dark, messageController: messageController, groupController: groupController, group: group),

              /// Emojis
              userController.showEmoji.value ? SizedBox(
                height: THelperFunctions.screenHeight() * 0.35,
                child: EmojiKeyboard(messageController: messageController, dark: dark),
              ) : const SizedBox(),
            ],
          )),
        ),
        /// Chat name
        appBar: TAppBar(
          showBackArrow: false,
          bgColor: Colors.grey.shade900,
          title: InkWell(
            onTap: () => Get.to(() => GroupProfile(group: group)),
            child: Obx(
                  () => Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  /// Pinned Button
                  Obx(() => IconButton(onPressed: () async {

                    /// Checking Conditions
                    if (!pinnedGroups.contains(group.id)) {
                      if (!group.isArchived) {

                        // Add in Pinned List
                        pinnedGroups.add(group.id);

                        // Set value "True"
                        group.isPinned = true;

                        // Update Firebase
                        await db.collection("Users").doc(auth.currentUser!.uid).collection("Groups").doc(group.id).update({"IsPinned": true});

                        // Notify User
                        Loaders.customToast(message: "'${group.groupName}' is added to Pins");

                      } else {

                        Loaders.customToast(message: "You need to remove '${group.groupName}' from Archives");
                      }
                    }

                    else {

                      // Remove from list
                      pinnedGroups.remove(group.id);

                      // Set Value "False"
                      group.isPinned = true;

                      // Update Firebase
                      await db.collection("Users").doc(auth.currentUser!.uid)
                          .collection("Groups").doc(group.id).update({"IsPinned" : false});

                      // Notify User
                      Loaders.customToast(message: "'${group.groupName}' is removed from Pins");
                    }

                    // Update List at Firebase
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

                  /// Archive Button
                  Obx(() => IconButton(onPressed: () async {

                    /// Checking Conditions
                    if (!archivedGroups.contains(group.id)) {
                      if (!(group.isPinned || group.isFavourite)) {

                        // Add in Archive List
                        archivedGroups.add(group.id);

                        // Set value "True"
                        group.isArchived = true;

                        // Update Firebase
                        await db.collection("Users").doc(auth.currentUser!.uid)
                            .collection("Groups").doc(group.id).update({"IsArchived": true});

                        // Notify User
                        Loaders.customToast(message: "'${group.groupName}' is added to Archives");

                      } else {

                        // Warning Conditions
                        Loaders.customToast(message: "First remove '${group.groupName}' from Favourites and Pins");
                      }
                    }
                    else {

                      // Remove from list
                      archivedGroups.remove(group.id);

                      // Set Value "False"
                      group.isArchived = false;

                      // Update Firebase
                      await db.collection("Users").doc(auth.currentUser!.uid).collection("Groups").doc(group.id).update({"IsArchived" : false});

                      // Notify User
                      Loaders.customToast(message: "'${group.groupName}' is removed from Archives");
                    }

                    // Update List at Firebase
                    await groupController.db.collection("Users").doc(groupController.auth.currentUser!.uid)
                        .update({"ArchivedGroups" : archivedGroups.map((user) => user.toString()).toList()});

                  }, icon: archivedGroups.contains(group.id)
                      ? const Icon(Icons.arrow_circle_up_rounded, color: Colors.blue) : const Icon(Icons.arrow_circle_down_rounded)),
                  ),
                  const SizedBox(width: TSizes.spaceBtwItems / 2),
                  // InkWell(
                  //   radius: 50,
                  //   // onTap: () => Get.to(() => CalenderScreen(group: group)),
                  //   child: const Icon(Icons.date_range),
                  // ),
                  // const SizedBox(width: TSizes.spaceBtwItems),
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
                          final encryptedMessageString = snapshot.data![index].senderMessage;
                          final encryptedMessage = userController.stringToEncrypted(encryptedMessageString);
                          String formattedTime = DateFormat('hh:mm a').format(DateTime.parse(message.lastMessageTime));
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
                                DateTag(text: snapshot.data![snapshot.data!.length - 1].lastMessageTime.substring(0,10)),
                              if (showDate)
                                DateTag(text: snapshot.data![index].lastMessageTime.substring(0,10)),
                              ChatBubble(
                                message: userController.encryptor.decrypt(encryptedMessage, iv: userController.iv),
                                imageUrl: message.imageUrl!,
                                // isThread: message.thread != ThreadModel.empty(),
                                time: formattedTime,
                                status: Status.read.toString(),
                                isRead: message.isRead,
                                senderName: message.senderName!,
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
