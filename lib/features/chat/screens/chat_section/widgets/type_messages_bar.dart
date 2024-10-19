import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xpider_chat/data/repositories/user/user_repository.dart';
import 'package:xpider_chat/features/chat/models/thread_model.dart';
import 'package:xpider_chat/features/chat/screens/messages/image_send_screen.dart';
import 'package:xpider_chat/utils/constants/sizes.dart';
import 'package:xpider_chat/utils/helpers/helper_functions.dart';
import '../../../../../common/buttons/option_icon_button.dart';
import '../../../../../common/custom_shapes/containers/rounded_container.dart';
import '../../../../../data/user/user.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../controllers/chat_controller.dart';
import '../../../controllers/thread_controller.dart';
import '../../../controllers/user_controller.dart';
import '../thread.dart';

class TypeMessagesBar extends StatelessWidget {
  TypeMessagesBar({
    super.key,
    required this.dark,
    required this.messageController,
    this.chatController,
    this.threadController,
    required this.userModelReceiver, required this.isThread, required this.thread
  });

  final bool dark;
  final TextEditingController messageController;
  final ChatController? chatController;
  final ThreadController? threadController;
  final UserModel userModelReceiver;
  final ThreadModel thread;
  final bool isThread;
  final userRepository = UserRepository.instance;


  @override
  Widget build(BuildContext context) {
    final threadController = Get.put(ThreadController());
    final user = UserController.instance;

    return Padding(
      padding: EdgeInsets.only(left: 5, right: 5, bottom: user.showEmoji.value ? THelperFunctions.screenHeight() * 0.37 : 5),
      child: Container(
        color: Colors.black87,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RoundedContainer(
              backgroundColor: dark? Colors.white24 : TColors.grey,
              width: MediaQuery.of(context).size.width*.8,
              // padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [

                  /// Emoji Button
                  IconButton(onPressed: () {
                    user.showEmoji.value = !user.showEmoji.value;
                    FocusScope.of(context).unfocus();
                  }, icon: const Icon(Icons.emoji_emotions_outlined)),

                  /// Message Typing
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .55,
                    child: TextField(
                      controller: messageController,
                      textAlign: TextAlign.justify,
                      onTap: () {
                        user.showEmoji.value = false;
                      },
                      textInputAction: TextInputAction.newline,
                      // textAlignVertical: TextAlignVertical.center,
                      cursorColor: TColors.darkGrey,
                      cursorHeight: 18,
                      minLines: 1,
                      maxLines: 4,
                      scrollPhysics: const BouncingScrollPhysics(),
                      cursorOpacityAnimates: true,
                      decoration: InputDecoration(
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          border: InputBorder.none,
                          hintFadeDuration: const Duration(milliseconds: 500),
                          hintText: isThread ? "Send thread message..." : " Send a message...",
                          hintStyle: const TextStyle(color: TColors.darkGrey)
                      ),
                    ),
                  ),

                  /// Attachment
                  IconButton(onPressed: () async {

                    Get.bottomSheet(Container(
                      height: THelperFunctions.screenHeight() * .335,
                      decoration: const BoxDecoration(
                          color: TColors.black,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(TSizes.cardRadiusLg),
                              topRight: Radius.circular(TSizes.cardRadiusLg)
                          )
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace * 3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: TSizes.spaceBtwItems),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                OptionIconButton(onPressed: () async {
                                  final image = await ImagePicker().pickImage(
                                      source: ImageSource.camera);
                                  // Upload Image
                                  if (image != null) {
                                    Get.back();
                                    Get.to(() => ImageSendScreen(userModelReceiver: userModelReceiver, messageController: messageController, thread: thread, isThread: isThread));
                                    threadController.selectedImagePath.value = image.path;
                                    chatController?.selectedImagePath.value = image.path;
                                  }
                                },   icon: Icons.camera, backgroundColor:  Colors.red, buttonLabel: 'Camera'),
                                OptionIconButton(onPressed: () async {
                                  final image = await ImagePicker().pickImage(
                                      source: ImageSource.gallery);
                                  // Upload Image
                                  if (image != null) {
                                    Get.back();
                                    Get.to(() => ImageSendScreen(userModelReceiver: userModelReceiver, messageController: messageController, thread: thread, isThread: isThread));
                                    threadController.selectedImagePath.value = image.path;
                                    chatController?.selectedImagePath.value = image.path;
                                  }
                                },  icon: Iconsax.gallery, backgroundColor: Colors.green.shade700, buttonLabel: "Gallery"
                                ),

                                isThread ? OptionIconButton(icon: Icons.delete, backgroundColor: Colors.indigo, buttonLabel: "Delete", onPressed: () {},)
                                    : OptionIconButton(icon: Icons.bookmarks_sharp, backgroundColor: Colors.purple, buttonLabel: 'Threads',
                                    onPressed: () => Get.to(() => ThreadsScreen(receiver: userModelReceiver)))

                              ],
                            ),
                            const SizedBox(height: TSizes.spaceBtwItems * 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                OptionIconButton(onPressed: () {},  icon: Icons.person_rounded, backgroundColor:  Colors.blue, buttonLabel: "Contact",),
                                OptionIconButton(onPressed: () {},  icon: Iconsax.document, backgroundColor: Colors.deepOrange, buttonLabel: "Documents"),
                                OptionIconButton(onPressed: () {},  icon: Iconsax.headphone, backgroundColor: Colors.black, buttonLabel: "Audio"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ));


                  }, icon: const Icon(Icons.attach_file)),
                  // PopupMenuButton(
                  //     offset: Offset.fromDirection(0, 0),
                  //
                  //     icon: const Icon(Icons.attach_file),
                  //     itemBuilder: (BuildContext context) {
                  //       return {'Image', 'Video'}.map((String choice) {
                  //         return PopupMenuItem<String>(
                  //           value: choice,
                  //           child: ,
                  //         );
                  //       }).toList();
                  //     }
                  // ),
                ],
              ),
            ),
            const SizedBox(width: TSizes.spaceBtwItems / 2),

            /// Send Button
            RoundedContainer(
              backgroundColor: Colors.blue.shade900,
              radius: 15,
              height: 45,
              width: 45,
              child: IconButton(onPressed: (){
                if (messageController.text.isNotEmpty){
                  // isImage.value = false;
                  if (isThread){
                    threadController.selectedImagePath.value = '';
                    threadController.sendThreadMessage(
                        thread, userModelReceiver,
                        user.encryptor.encrypt(messageController.text, iv: user.iv).base64,
                        threadController.selectedImagePath.value);
                    messageController.clear();

                  } else {
                    chatController?.selectedImagePath.value = '';
                    chatController?.sendMessage(
                        receiver: userModelReceiver,
                        sender: user.user.value,
                        message: user.encryptor.encrypt(messageController.text, iv: user.iv).base64,
                        imgUrl: chatController?.selectedImagePath.value);
                    messageController.clear();
                  }
                }
              },
                  icon: const Icon(Icons.near_me)),
            )


          ],
        ),
      ),
    );
  }
}

