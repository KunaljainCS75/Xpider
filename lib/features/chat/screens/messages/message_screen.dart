import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:xpider_chat/common/appbar/appbar.dart';
import 'package:xpider_chat/common/custom_shapes/containers/rounded_container.dart';
import 'package:xpider_chat/common/images/circular_images.dart';
import 'package:xpider_chat/data/user/user.dart';
import 'package:xpider_chat/features/chat/controllers/call_controller.dart';
import 'package:xpider_chat/features/chat/controllers/chat_controller.dart';
import 'package:xpider_chat/features/chat/screens/calender/cal.dart';
import 'package:xpider_chat/features/chat/screens/call/audio_call_screen.dart';
import 'package:xpider_chat/features/chat/screens/chat_section/widgets/type_messages_bar.dart';
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
import '../call/video_call_screen.dart';

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
    final messageController = TextEditingController();

    final callController = CallController.instance;

    RxList<String> archivedChats = UserController.instance.archivedChats;
    RxList<String> pinnedChats = UserController.instance.pinnedChats;

    RxBool isNetwork = false.obs;
    if(userModelReceiver.profilePicture != TImages.user){
      isNetwork = true.obs;
    }
    return WillPopScope(
      onWillPop: () async {
        ChatController.instance.getAllChatRooms();
        return true;
      },child: Scaffold(
      backgroundColor: Colors.black87,
        /// Message typing area
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton:  TypeMessagesBar(dark: dark,messageController: messageController, chatController: chatController, userModelReceiver: userModelReceiver, isThread:false, thread: ThreadModel.empty(),),
        /// Chat name
        appBar: TAppBar(
          showBackArrow: false,
          bgColor: Colors.grey.shade900,
          title: InkWell(
            onTap: () => Get.to(() => UserProfile(userProfile: userModelReceiver)),
            child: Obx(
                () => Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Obx(() => IconButton(onPressed: () async {
                    if (!pinnedChats.contains(userModelReceiver.id)) {
                      pinnedChats.add(userModelReceiver.id);
                      Loaders.customToast(message: "'${userModelReceiver.fullName}' is added to Pins");
                    }
                    else {
                      pinnedChats.remove(userModelReceiver.id);
                      Loaders.customToast(message: "'${userModelReceiver.fullName}' is removed from Pins");
                    }
                    await chatController.db.collection("Users")
                        .doc(chatController.auth.currentUser!.uid)
                        .update({"PinnedChats" : pinnedChats.map((user) => user.toString()).toList()});

                  }, icon: pinnedChats.contains(userModelReceiver.id)
                      ? const Icon(Icons.star, color: Colors.yellowAccent) : const Icon(Icons.star_border, color: TColors.white)),
                  ),
                  const SizedBox(width: TSizes.spaceBtwItems),

                  CircularImage(height: 35, width: 35, image: userModelReceiver.profilePicture, isNetworkImage: isNetwork.value),
                  const SizedBox(width: TSizes.spaceBtwItems),
                  Flexible(child: Text(userModelReceiver.fullName, style: Theme.of(context).textTheme.headlineLarge!.apply(fontSizeFactor: .5))),
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
                    if (!archivedChats.contains(userModelReceiver.id)) {
                      archivedChats.add(userModelReceiver.id);
                      Loaders.customToast(message: "'${userModelReceiver.fullName}' is added to Archives");
                    }
                    else {
                      archivedChats.remove(userModelReceiver.id);
                      Loaders.customToast(message: "'${userModelReceiver.fullName}' is removed from Archives");
                    }
                    await chatController.db.collection("Users")
                        .doc(chatController.auth.currentUser!.uid)
                        .update({"ArchivedChats" : archivedChats.map((user) => user.toString()).toList()});

                    }, icon: archivedChats.contains(userModelReceiver.id)
                        ? const Icon(Icons.arrow_circle_up_rounded, color: Colors.blue) : const Icon(Icons.arrow_circle_down_rounded)),
                  ),
                  const SizedBox(width: TSizes.spaceBtwItems / 2),
                  InkWell(
                    radius: 50,
                    onTap: () => Get.to(() => CalenderScreen(userModelReceiver: userModelReceiver)),
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
                                    Get.to(() =>
                                        AudioCallScreen(receiver: userModelReceiver));
                                        callController.callUser(UserController.instance.user.value, userModelReceiver, "audio");
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
                                    Get.to(() =>
                                        VideoCallScreen(receiver: userModelReceiver));
                                    callController.callUser(UserController.instance.user.value, userModelReceiver, "video");
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

class DateTimeTag extends StatelessWidget {
  const DateTimeTag({
    super.key, required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final date = DateTime.parse(text);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: RoundedContainer(
          backgroundColor: dark ? Colors.blueGrey.shade900 :Colors.white70,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text("${date.day} ${DateFormat.MMMM().format(date)}, ${date.year}",
        style: Theme.of(context).textTheme.titleMedium!.apply(color: dark ? Colors.white70 :Colors.black87),),
    ))),
    );
  }
}


