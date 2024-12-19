import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xpider_chat/common/appbar/appbar.dart';
import 'package:xpider_chat/features/chat/controllers/chat_controller.dart';
import 'package:xpider_chat/features/chat/controllers/thread_controller.dart';
import 'package:xpider_chat/features/chat/controllers/user_controller.dart';
import 'package:xpider_chat/features/chat/models/thread_model.dart';
import 'package:xpider_chat/utils/constants/sizes.dart';
import 'package:xpider_chat/utils/helpers/helper_functions.dart';
import '../../../../common/custom_shapes/containers/rounded_container.dart';
import '../../../../data/user/user.dart';
import '../../../../utils/constants/colors.dart';

class ImageSendScreen extends StatelessWidget {
  const ImageSendScreen({
    super.key,
    required this.messageController,
    required this.userModelReceiver, required this.isThread, required this.thread

  });

  final TextEditingController messageController;
  final UserModel userModelReceiver;
  final bool isThread;
  final ThreadMessage thread;


  @override
  Widget build(BuildContext context) {
    final chatController = ChatController.instance;
    final threadController = ThreadController.instance;
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      backgroundColor: Colors.indigo,

      /// AppBar
      appBar: TAppBar(
        title: Text("Send Image", style: Theme.of(context).textTheme.headlineMedium),
        showBackArrow: true,
      ),
      floatingActionButton: WriteCaptionsBox(userModelReceiver: userModelReceiver, messageController: messageController, isThread: isThread, thread: thread,),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      /// Body
      body: Obx(
        () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(200)
                ),
                margin: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace*2),
                 child: RoundedContainer(
                   padding: const EdgeInsets.all(TSizes.defaultSpace / 2),
                     backgroundColor: TColors.black,
                     child: SizedBox(height: 300, width: THelperFunctions.screenWidth(),
                         child: isThread
                             ? Image.file(File(threadController.selectedImagePath.value), fit: BoxFit.fitWidth,)
                             : Image.file(File(chatController.selectedImagePath.value), fit: BoxFit.fitWidth)))),
              const SizedBox(height: TSizes.defaultSpace),

            ],
          ),
        ),
      ),
    );
  }
}

class WriteCaptionsBox extends StatelessWidget {
  const WriteCaptionsBox({
    super.key,
    required this.messageController,
    required this.userModelReceiver, required this.isThread, required this.thread,
  });

  final TextEditingController messageController;
  final UserModel userModelReceiver;
  final ThreadMessage thread;
  final bool isThread;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final chatController = ChatController.instance;
    final threadController = ThreadController.instance;
    return PopScope(
      onPopInvoked: (value) {
        threadController.selectedImagePath.value = '';
        chatController.selectedImagePath.value = '';
      },

      /// Typing Bar
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RoundedContainer(
              backgroundColor: dark? Colors.black87 : TColors.grey,
              width: MediaQuery.of(context).size.width*.9,
              height: 55,
              // padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [

                      /// Emoji
                      IconButton(onPressed: () {}, icon: const Icon(Icons.emoji_emotions_outlined)),

                      /// Captions
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .55,
                        child: TextField(
                          controller: messageController,
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
                              hintText: " Type captions...",
                              hintStyle: TextStyle(color: TColors.darkGrey)
                          ),
                        ),
                      ),
                    ],
                  ),

                  /// Change Image Button
                  IconButton(onPressed: () async {
                    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                    chatController.selectedImagePath.value = image!.path;
                    threadController.selectedImagePath.value = image.path;
                  },
                      icon: const Icon(Icons.image_search)),
                  IconButton(onPressed: (){
                    if (messageController.text == ''){
                      messageController.text = "Image Message";
                    }
                      if (isThread) {
                        threadController.sendThreadMessage(thread, userModelReceiver,
                            UserController.instance.encryptor.encrypt(messageController.text, iv: UserController.instance.iv).base64,
                            threadController.selectedImage);
                      } else {
                        chatController.sendMessage(
                            receiver: userModelReceiver,
                            sender: UserController.instance.user.value,
                            message: UserController.instance.encryptor.encrypt(messageController.text, iv: UserController.instance.iv).base64,
                            image: chatController.selectedImage);
                      }
                        messageController.clear();
                      threadController.selectedImagePath.value = '';
                      chatController.selectedImagePath.value = '';
                      Get.back();
                  },
                      icon: const Icon(Icons.send))
                ],
              ),
            ),
      ),
    );
  }
}
