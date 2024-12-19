import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpider_chat/common/appbar/appbar.dart';
import 'package:xpider_chat/common/images/circular_images.dart';
import 'package:xpider_chat/data/user/user.dart';
import 'package:xpider_chat/features/chat/controllers/user_controller.dart';
import 'package:xpider_chat/features/chat/screens/chat_section/widgets/type_messages_bar.dart';
import 'package:xpider_chat/features/chat/screens/messages/widgets/chat_bubble.dart';
import 'package:xpider_chat/features/chat/screens/user_profile/user_profile.dart';
import 'package:xpider_chat/utils/constants/sizes.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/thread_controller.dart';
import '../../models/thread_model.dart';

class ThreadMessageScreen extends StatelessWidget {
  const ThreadMessageScreen({
    super.key,
    required this.userModelReceiver,
    required this.thread,

  });

  final UserModel userModelReceiver;
  final ThreadMessage thread;


  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final threadController = ThreadController.instance;
    final userController = UserController.instance;
    final messageController = TextEditingController();
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
      floatingActionButton:  TypeMessagesBar(
          dark: dark,
          messageController: messageController,
          threadController: threadController,
          userModelReceiver: userModelReceiver,
          thread: thread,
          isThread: true
      ),
      /// Chat name
      appBar: TAppBar(
        showBackArrow:true,
        bgColor: Colors.green.withOpacity(.6),
        title: InkWell(
          onTap: () => Get.to(() => UserProfile(userProfile: userModelReceiver)),
          child: Obx(
                () => Row(
              children: [

                CircularImage(height: 35, width: 35, image: userModelReceiver.profilePicture, isNetworkImage: isNetwork.value),
                const SizedBox(width: TSizes.spaceBtwItems),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(thread.threadName, style: Theme.of(context).textTheme.headlineLarge!.apply(fontSizeFactor: .7)),
                      Text("(${userModelReceiver.fullName})", style: Theme.of(context).textTheme.labelLarge!.apply(fontSizeFactor: 1)),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 0),
        actions: [
          PopupMenuButton(
              offset: Offset.fromDirection(1, 50),

              icon: const Icon(Icons.more_vert_rounded),
              itemBuilder: (BuildContext context) {
                return {'Add Thread', 'Option 2', 'Option 3'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: InkWell(
                      child: Text(choice),
                      onTap: () {
                        if (choice == 'Add Thread'){

                        }
                      },
                    ),
                  );
                }).toList();
              }
          )
        ],
      ),

      /// Chat Messages
      body: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: StreamBuilder<List<ThreadMessage>>(
            stream: threadController.getThreadMessages(userModelReceiver.id, thread.id!),
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
                    final encryptedMessage = userController.stringToEncrypted(encryptedMessageString!);

                    return ChatBubble(
                      message: userController.encryptor.decrypt(encryptedMessage, iv: userController.iv),
                      imageUrl: message.imageUrl!,
                      // isThread: message.thread != ThreadModel.empty(),
                      time: message.lastMessageTime,
                      status: Status.read.toString(),
                      senderName: message.senderName!,
                      isRead: true,
                      isComing: !(threadController.auth.currentUser!.uid == message.senderId),
                    );
                  },
                );
              }
            }

        ),
      ),




    ),
    );
  }
}

