import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xpider_chat/common/appbar/appbar.dart';
import 'package:xpider_chat/features/chat/controllers/chat_controller.dart';
import 'package:xpider_chat/features/chat/controllers/thread_controller.dart';
import 'package:xpider_chat/features/chat/models/thread_model.dart';
import 'package:xpider_chat/utils/constants/sizes.dart';
import 'package:xpider_chat/utils/helpers/helper_functions.dart';

import '../../../../common/custom_shapes/containers/rounded_container.dart';
import '../../../../utils/constants/colors.dart';
import '../../controllers/group_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/group_chat_model.dart';
import '../../models/group_user_model.dart';

class ImageSendGroupScreen extends StatelessWidget {
  const ImageSendGroupScreen({
    super.key,
    required this.messageController,
    required this.group,

  });

  final TextEditingController messageController;
  final GroupRoomModel group;

  @override
  Widget build(BuildContext context) {
    final groupController = GroupController.instance;
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: Colors.indigo,
      appBar: TAppBar(
        title: Text("Send Image", style: Theme.of(context).textTheme.headlineMedium),
        showBackArrow: true,
      ),
      floatingActionButton: WriteCaptionsBox(messageController: messageController, group: group),
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
                          child: Image.file(File(groupController.selectedImagePath.value), fit: BoxFit.fitHeight)
                              ))),
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
    required this.group,
  });

  final TextEditingController messageController;
  final GroupRoomModel group;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final groupController = GroupController.instance;
    final user = UserController.instance.myGroupProfile();

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
              groupController.selectedImagePath.value = image!.path;
              groupController.selectedImage = image;
            },
                icon: const Icon(Icons.image_search)),
            IconButton(onPressed: (){
              if (messageController.text == ''){
                messageController.text = "Image_Message";
              }
              groupController.sendMessage(
                group, group.createdBy, user,
                UserController.instance.encryptor.encrypt(messageController.text, iv: UserController.instance.iv).base64, groupController.selectedImage);

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
