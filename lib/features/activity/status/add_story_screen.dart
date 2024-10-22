import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:xpider_chat/common/appbar/appbar.dart';
import 'package:xpider_chat/features/activity/controller/status_controller.dart';
import 'package:xpider_chat/features/activity/controller/story_controller.dart';
import 'package:xpider_chat/features/activity/status/status_screen.dart';
import 'package:xpider_chat/features/activity/status/widgets/story_caption_type_bar.dart';
import 'package:xpider_chat/features/chat/controllers/user_controller.dart';
import 'package:xpider_chat/utils/constants/colors.dart';
import 'package:xpider_chat/utils/constants/sizes.dart';

import '../../../common/custom_shapes/containers/rounded_container.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../../utils/popups/loaders.dart';

class AddStoryScreen extends StatelessWidget {
  const AddStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = StoryViewController.instance;
    final statusController = StatusController.instance;

    List<Color> colors = <Color>[
      TColors.primary,
      Colors.deepOrange,
      Colors.yellow.shade700,
      Colors.red.shade800,
      Colors.black54,
      Colors.blue,
      Colors.purple,
      Colors.brown,
      Colors.pink,
    ];
    RxInt index = 0.obs;
    XFile? image;
    final captionController = TextEditingController();
    return PopScope(
      onPopInvoked: (value) {
        controller.storyViewImage.value = '';
      },
      child: Obx(
          () => Scaffold(
            backgroundColor: image != null ? Colors.black : colors[index.value],
              appBar: TAppBar(
                  title: Text("Add your Status"),
                actions: [

                  /// Photo Uploader
                  InkWell(
                    onTap: () async {
                      image = await ImagePicker().pickImage(source: ImageSource.gallery);
                      controller.storyViewImage.value = image!.path;
                    },
                    child: const Icon(Iconsax.gallery),
                  ),
                  const SizedBox(width: TSizes.spaceBtwItems * 1.5),

                  /// Color Change
                  InkWell(
                    onTap: () => index.value = (index.value + 1) % colors.length,
                    child: const Icon(Icons.color_lens_outlined),
                  ),
                  const SizedBox(width: TSizes.spaceBtwItems * 1.3),

                  /// Send Button
                  InkWell(
                    onTap: ()async{
                      Get.back();
                      Get.back();
                      String? imgUrl;
                      if (image != null) {
                        imgUrl = await statusController.uploadUserStory(image: image!, captions: captionController.text);
                          StoryItem story = StoryItem.pageImage(
                              url: imgUrl!,
                              imageFit: BoxFit.fitWidth,
                              controller: controller.storyController,
                              caption: Text(captionController.text, textAlign: TextAlign.center)
                          );
                          controller.storyViewImage.value = '';

                      } else {
                        if (captionController.text.isNotEmpty) {
                          await statusController.uploadUserStory(color: colors[index.value], captions: captionController.text);
                          StoryItem story = StoryItem.text(
                              title: captionController.text,
                              backgroundColor: colors[index.value]
                          );
                          controller.storyItems.add(story);
                        }
                        else {
                          Loaders.customToast(message: "You cannot Upload Blank Status");
                        }
                      }
                      captionController.clear();
                      print(controller.storyItems.length);
                    },
                    child: const Icon(Icons.near_me, color: Colors.white),
                  )
                ],
              ),
            body: controller.storyViewImage.value == '' ? SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  const SizedBox(height: TSizes.defaultSpace * 3),
                  StoryCaptionTypeBar(captionController: captionController)
                ],
              ),
            ) :  Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RoundedContainer(
                      radius: 0,
                      width: THelperFunctions.screenWidth(),
                        padding: const EdgeInsets.all(TSizes.defaultSpace / 3),
                        backgroundColor: TColors.black,
                        child: SizedBox(height: 300, width: THelperFunctions.screenWidth(),
                            child: Image.file(File(controller.storyViewImage.value), fit: BoxFit.fitHeight))),
                    const SizedBox(height: TSizes.defaultSpace),

                  ],
                ),
              ),
            floatingActionButton: controller.storyViewImage.value != ''
                ? StoryCaptionTypeBar(captionController: captionController, isImageStory: true)
                : const SizedBox(),
            ),
      ),
    );
  }
}
