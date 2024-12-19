import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:xpider_chat/common/appbar/appbar.dart';
import 'package:xpider_chat/common/emoji/emoji_keyboard.dart';
import 'package:xpider_chat/common/images/circular_images.dart';
import 'package:xpider_chat/common/texts/date_format.dart';
import 'package:xpider_chat/data/user/user.dart';
import 'package:xpider_chat/features/chat/controllers/call_controller.dart';
import 'package:xpider_chat/features/chat/controllers/chat_controller.dart';
import 'package:xpider_chat/features/chat/screens/calender/cal.dart';
import 'package:xpider_chat/features/chat/screens/chat_section/widgets/type_messages_bar.dart';
import 'package:xpider_chat/features/chat/screens/messages/widgets/calling_button.dart';
import 'package:xpider_chat/features/chat/screens/messages/widgets/chat_bubble.dart';
import 'package:xpider_chat/features/chat/screens/user_profile/user_profile.dart';
import 'package:xpider_chat/utils/constants/colors.dart';
import 'package:xpider_chat/utils/constants/sizes.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/popups/loaders.dart';
import '../../controllers/user_controller.dart';
import '../../models/chat_message_model.dart';
import '../../models/thread_model.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({
    super.key,

    required this.userModelReceiver,

  });

  final UserModel userModelReceiver;


  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final chatController = ChatController.instance;
    final userController = UserController.instance;
    final messageController = TextEditingController();
    final callController = CallController.instance;

    RxList<String> archivedChats = UserController.instance.archivedChats;
    RxList<String> pinnedChats = UserController.instance.pinnedChats;
    RxList<String> favouriteChats = UserController.instance.favouriteChats;

    String roomId = chatController.getRoomId(userModelReceiver.id);

    RxBool isNetwork = false.obs;
    if(userModelReceiver.profilePicture != TImages.user){
      isNetwork = true.obs;
    }
    return WillPopScope(
      onWillPop: () async {
        ChatController.instance.getAllChatRooms();
        userController.showEmoji.value = false;
        return true;
      },child: Scaffold(
      backgroundColor: Colors.black87,
        /// Message typing area
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton:  Obx(
          () => SizedBox(
              height: 500,child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              TypeMessagesBar(
                dark: dark,messageController: messageController, chatController: chatController,
                userModelReceiver: userModelReceiver, isThread:false, thread: ThreadMessage.empty()),
              /// Emojis

               userController.showEmoji.value ? SizedBox(
                height: THelperFunctions.screenHeight() * 0.35,
                child: EmojiKeyboard(messageController: messageController, dark: dark)
              ) : const SizedBox(),
            ],
          )),
        ),


        /// Chat Title Bar
        appBar: TAppBar(
          showBackArrow: false,
          bgColor: Colors.grey.shade900,
          title: InkWell(
            onTap: () => Get.to(() => UserProfile(userProfile: userModelReceiver)),
            child: Obx(
                () => Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  /// Pin Button
                  Obx(() => IconButton(onPressed: () async {
                    if (!archivedChats.contains(userModelReceiver.id)){
                    if (!pinnedChats.contains(userModelReceiver.id)) {
                      pinnedChats.add(userModelReceiver.id);

                      Loaders.customToast(message: "'${userModelReceiver.fullName}' is added to Pins");
                      await chatController.db.collection("Users").doc(chatController.auth.currentUser!.uid)
                          .collection("Chats").doc(roomId).update({"IsPinned" : true});
                    }
                    else {
                      pinnedChats.remove(userModelReceiver.id);
                      Loaders.customToast(message: "'${userModelReceiver.fullName}' is removed from Pins");
                      await chatController.db.collection("Users").doc(chatController.auth.currentUser!.uid)
                          .collection("Chats").doc(roomId).update({"IsPinned" : false});
                    }
                    await chatController.db.collection("Users")
                        .doc(chatController.auth.currentUser!.uid)
                        .update({"PinnedChats" : pinnedChats.map((user) => user.toString()).toList()});
                    } else {
                      Loaders.customToast(message: "You need to remove '${userModelReceiver.fullName}' from Archives.");
                    }

                  }, icon: pinnedChats.contains(userModelReceiver.id)
                      ? const Icon(Icons.star, color: Colors.yellowAccent) : const Icon(Icons.star_border, color: TColors.white)),
                  ),
                  const SizedBox(width: TSizes.spaceBtwItems),


                  /// Profile Picture & Name
                  CircularImage(height: 35, width: 35, image: userModelReceiver.profilePicture, isNetworkImage: isNetwork.value),
                  const SizedBox(width: TSizes.spaceBtwItems),
                  Flexible(child: Text(userModelReceiver.fullName, style: Theme.of(context).textTheme.headlineLarge!.apply(fontSizeFactor: .5))),
                ],
              ),
            ),
          ),

          /// Additional Features
          padding: const EdgeInsets.symmetric(horizontal: 0),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [

                  /// Archive Button
                  Obx(() => IconButton(onPressed: () async {


                    if (!archivedChats.contains(userModelReceiver.id)) {
                      if ((!favouriteChats.contains(userModelReceiver.id) && !pinnedChats.contains(userModelReceiver.id))){
                      archivedChats.add(userModelReceiver.id);
                      await chatController.db.collection("Users").doc(chatController.auth.currentUser!.uid)
                          .collection("Chats").doc(roomId).update({"IsArchived" : true});
                      Loaders.customToast(message: "'${userModelReceiver.fullName}' is added to Archives");
                      }
                      else{
                        Loaders.customToast(message: "You need to remove '${userModelReceiver.fullName}' from 'Pins' and 'Favourites.'");
                      }
                    }
                    else {
                      archivedChats.remove(userModelReceiver.id);
                      await chatController.db.collection("Users").doc(chatController.auth.currentUser!.uid)
                          .collection("Chats").doc(roomId).update({"IsArchived" : false});
                      Loaders.customToast(message: "'${userModelReceiver.fullName}' is removed from Archives");
                    }
                    await chatController.db.collection("Users")
                        .doc(chatController.auth.currentUser!.uid)
                        .update({"ArchivedChats" : archivedChats.map((user) => user.toString()).toList()});

                    }, icon: archivedChats.contains(userModelReceiver.id)
                        ? const Icon(Icons.arrow_circle_up_rounded, color: Colors.blue) : const Icon(Icons.arrow_circle_down_rounded)),
                  ),
                  const SizedBox(width: TSizes.spaceBtwItems / 2),

                  /// Calender Filter
                  InkWell(
                    radius: 50,
                    onTap: () => Get.to(() => CalenderScreen(userModelReceiver: userModelReceiver)),
                    child: const Icon(Icons.date_range),
                  ),
                  const SizedBox(width: TSizes.spaceBtwItems),

                  /// Calling Button
                  CallingButton(userModelReceiver: userModelReceiver, callController: callController),
                  const SizedBox(width: TSizes.spaceBtwItems),

                  /// Settings Button
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

        /// Chat Messages
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
              child: StreamBuilder<List<ChatMessageModel>>(
                stream: chatController.getMessages(userModelReceiver.id),
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
                        
                        /// Update read status at receiver's end for receiver's messages
                        final message = snapshot.data![index];
                        if (message.receiverId != userController.user.value.id) {
                          userController.db.collection("Users").doc(
                              message.receiverId).collection("Chats").doc(roomId).collection("Messages").doc(message.id).update({"IsRead": true});
                        } else {
                          userController.db.collection("Users").doc(
                            message.senderId).collection("Chats").doc(roomId).collection("Messages").doc(message.id).update({"IsRead": true});
                        }
                        /// Decrypt the Message
                        final encryptedMessageString = snapshot.data![index].senderMessage;
                        final encryptedMessage = userController.stringToEncrypted(encryptedMessageString);
                        String formattedTime = DateFormat('hh:mm a').format(DateTime.parse(message.lastMessageTime));

                        ///
                        bool showDate = false;
                        bool isFirstTime = false;
                        if (index == snapshot.data!.length - 1) {
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
                              isComing: !(chatController.auth.currentUser!.uid == message.senderId),

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




// /// Emojis
// Obx(() =>
//  userController.showEmoji.value ? SizedBox(
//   height: THelperFunctions.screenHeight() * 0.35,
//   child: EmojiPicker(
//     textEditingController: messageController,
//     onBackspacePressed: () {},
//     config: Config(
//       height: 256,
//       emojiViewConfig: EmojiViewConfig(
//         backgroundColor: dark ? Colors.blueGrey.shade900 : Colors.white70,
//         columns: 7,
//         // Issue: https://github.com/flutter/flutter/issues/28894
//         emojiSizeMax: 28 *
//             (Platform.isIOS
//                 ?  1.20
//                 :  1.0),
//       ),
//       viewOrderConfig: const ViewOrderConfig(
//         top: EmojiPickerItem.categoryBar,
//         middle: EmojiPickerItem.emojiView,
//         bottom: EmojiPickerItem.searchBar,
//       ),
//       skinToneConfig: const SkinToneConfig(),
//       categoryViewConfig: CategoryViewConfig(
//         backgroundColor: dark ? Colors.blueGrey.shade900 : Colors.white70,
//         extraTab: CategoryExtraTab.BACKSPACE,
//       ),
//       bottomActionBarConfig: const BottomActionBarConfig(
//         showBackspaceButton: false,
//         showSearchViewButton: false
//       ),
//       searchViewConfig: const SearchViewConfig(),
//     ),
//
//   ),
// ) : const SizedBox(),
// )