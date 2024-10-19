

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:xpider_chat/common/appbar/appbar.dart';
import 'package:xpider_chat/common/custom_shapes/containers/rounded_container.dart';
import 'package:xpider_chat/features/chat/controllers/chat_controller.dart';
import 'package:xpider_chat/features/chat/screens/messages/thread_messages.dart';
import 'package:xpider_chat/utils/constants/sizes.dart';

import '../../../../data/user/user.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/popups/loaders.dart';
import '../../controllers/thread_controller.dart';
import '../../controllers/user_controller.dart';

class ThreadsScreen extends StatelessWidget {
  const ThreadsScreen({super.key, required this.receiver});

  final UserModel receiver;
  @override
  Widget build(BuildContext context){
    final threadController = Get.put(ThreadController());
    final chatController = ChatController.instance;
    final threadNameController = TextEditingController();
    threadController.getThreads(ChatController.instance.getRoomId(receiver.id));

    return Scaffold(
      backgroundColor: TColors.darkerGrey,
      appBar: TAppBar(bgColor: TColors.darkerGrey, title: Text("Threads", style: Theme.of(context).textTheme.headlineMedium)),
      body: Container(
        color: Colors.black87,
        child: Obx(
          () => ListView.builder(
            itemCount: threadController.threadRoomList.length,
            itemBuilder: (_, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace, vertical: TSizes.spaceBtwItems / 2),
              child: InkWell(
                onTap: () => Get.to(() => ThreadMessageScreen(userModelReceiver: receiver, thread: threadController.threadRoomList[index])),
                child: RoundedContainer(
                  showBorder: true,
                  borderColor: Colors.red,
                  backgroundColor: Colors.transparent,
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Center(child: Row(
                      children: [
                        const Icon(Iconsax.bookmark),
                        const SizedBox(width: TSizes.spaceBtwItems / 2),
                        Text("${threadController.threadRoomList[index].id!} : ", style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis,),
                        const SizedBox(width: TSizes.spaceBtwItems),
                        Flexible(child: Text(threadController.threadRoomList[index].threadName, style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis,)),
                      ],
                    )
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 1.0,
        backgroundColor: TColors.darkerGrey,
        onPressed: () {
          Get.defaultDialog(
              title: "Add New Thread",
              middleText: "Write a name for new thread",
              onConfirm: () async {
                Loaders.customToast(message: "Thread added");
                print(threadNameController.text);
                chatController.selectedImagePath.value = '';
                chatController.sendMessage(
                    receiver: receiver,
                    message: UserController.instance.encryptor.encrypt("A thread is created", iv: UserController.instance.iv).base64,
                    sender: UserController.instance.user.value,
                    imgUrl: chatController.selectedImagePath.value);
                await threadController.addThread(receiver, UserController.instance.encryptor.encrypt("A thread is created", iv: UserController.instance.iv).base64, receiver.profilePicture, threadNameController.text);
                threadNameController.clear();
                Get.back();

              },
              content: RoundedContainer(
                backgroundColor: TColors.grey,
                child: Row(
                  children: [
                    IconButton(onPressed: () {}, icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.black26,)),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .55,
                      child: TextField(
                        style: TextStyle(color: Colors.black87),
                        controller: threadNameController,
                        textAlign: TextAlign.justify,
                        textInputAction: TextInputAction.newline,
                        // textAlignVertical: TextAlignVertical.center,
                        cursorColor: TColors.darkGrey,
                        cursorHeight: 18,
                        scrollPhysics: const BouncingScrollPhysics(),
                        cursorOpacityAnimates: true,
                        decoration: const InputDecoration(
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            border: InputBorder.none,
                            hintFadeDuration: Duration(milliseconds: 500),
                            hintText: "Thread Name...",
                            hintStyle: TextStyle(color: TColors.darkGrey)
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onCancel: () => () => Get.back()
          );
        },
        child: Icon(Icons.add_outlined, size: 50, color: Colors.yellow),
      ),
    );
  }
}
