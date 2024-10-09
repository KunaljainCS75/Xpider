import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbols.dart';
import 'package:xpider_chat/common/appbar/appbar.dart';
import 'package:xpider_chat/features/chat/controllers/chat_controller.dart';
import 'package:xpider_chat/features/chat/controllers/thread_controller.dart';
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
  final ThreadModel thread;


  @override
  Widget build(BuildContext context) {
    final chatController = ChatController.instance;
    final threadController = ThreadController.instance;
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      backgroundColor: Colors.indigo,
      appBar: TAppBar(
        title: Text("Send Image", style: Theme.of(context).textTheme.headlineMedium),
        showBackArrow: true,
      ),
      floatingActionButton: WriteCaptionsBox(userModelReceiver: userModelReceiver, messageController: messageController, isThread: isThread, thread: thread,),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
                             ? Image.file(File(chatController.selectedImagePath.value), fit: BoxFit.fitHeight)
                             : Image.file(File(threadController.selectedImagePath.value), fit: BoxFit.fitHeight)))),
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
  final ThreadModel thread;
  final bool isThread;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final chatController = ChatController.instance;
    final threadController = ThreadController.instance;
    return Padding(
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
                    IconButton(onPressed: () {}, icon: const Icon(Icons.emoji_emotions_outlined)),
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
                IconButton(onPressed: () async {
                  final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                  chatController.selectedImagePath.value = image!.path;
                  threadController.selectedImagePath.value = image.path;
                },
                    icon: const Icon(Icons.image_search)),
                IconButton(onPressed: (){
                    if (isThread) {
                      threadController.sendThreadMessage(thread, userModelReceiver, messageController.text, threadController.selectedImagePath.value);
                    } else {
                      chatController.sendMessage(userModelReceiver.id, userModelReceiver, messageController.text, chatController.selectedImagePath.value);
                    }
                      messageController.clear();
                    Get.back();
                },
                    icon: const Icon(Icons.send))
              ],
            ),
          ),
    );
  }
}
