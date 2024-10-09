import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xpider_chat/data/repositories/user/user_repository.dart';
import 'package:xpider_chat/features/chat/controllers/user_controller.dart';
import 'package:xpider_chat/features/chat/models/group_user_model.dart';
import 'package:xpider_chat/features/chat/models/thread_model.dart';
import 'package:xpider_chat/features/chat/screens/messages/image_send_screen.dart';
import 'package:xpider_chat/utils/constants/sizes.dart';
import 'package:xpider_chat/utils/helpers/helper_functions.dart';
import '../../../../../common/buttons/option_icon_button.dart';
import '../../../../../common/custom_shapes/containers/rounded_container.dart';
import '../../../../../data/user/user.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../controllers/chat_controller.dart';
import '../../../controllers/group_controller.dart';
import '../../../controllers/thread_controller.dart';
import '../../../models/group_chat_model.dart';
import 'image_send_group_screen.dart';

class TypeMessagesBarGroup extends StatelessWidget {
  TypeMessagesBarGroup({
    super.key,
    required this.dark,
    required this.messageController,
    required this.groupController,
    required this.group

  });

  final bool dark;
  final TextEditingController messageController;
  final GroupController groupController;
  final GroupRoomModel group;
  final userRepository = UserRepository.instance;


  @override
  Widget build(BuildContext context) {
    final user = UserController.instance.myGroupProfile();
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: RoundedContainer(
            backgroundColor: dark? Colors.white24 : TColors.grey,
            width: MediaQuery.of(context).size.width*.9,
            height: 55,
            // padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Row(
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
                            hintText: "Send message in group...",
                            hintStyle: TextStyle(color: TColors.darkGrey)
                        ),
                      ),
                    ),
                  ],
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
                                  Get.to(() => ImageSendGroupScreen(messageController: messageController, group: group));
                                  groupController.selectedImagePath.value = image.path;
                                }
                              },   icon: Icons.camera, backgroundColor:  Colors.red, buttonLabel: 'Camera'),
                              OptionIconButton(onPressed: () async {
                                final image = await ImagePicker().pickImage(
                                    source: ImageSource.gallery);
                                // Upload Image
                                if (image != null) {
                                  Get.back();
                                  Get.to(() =>  ImageSendGroupScreen(messageController: messageController, group: group));
                                  groupController.selectedImagePath.value = image.path;
                                }
                              },  icon: Iconsax.gallery, backgroundColor: Colors.green.shade700, buttonLabel: "Gallery"),
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

                /// Send Button
                IconButton(onPressed: (){
                  if (messageController.text.isNotEmpty){
                    // isImage.value = false;
                      groupController.selectedImagePath.value = '';
                      groupController.sendMessage(group, group.createdBy, user, messageController.text, '');
                      messageController.clear();

                  }
                },
                    icon: const Icon(Icons.send))
              ],
            ),
          ),
        ),


      ],
    );
  }
}