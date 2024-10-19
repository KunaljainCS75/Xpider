import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xpider_chat/common/appbar/appbar.dart';
import 'package:xpider_chat/features/activity/controller/story_controller.dart';
import 'package:xpider_chat/features/activity/status/widgets/story_caption_type_bar.dart';
import 'package:xpider_chat/utils/constants/colors.dart';
import 'package:xpider_chat/utils/constants/sizes.dart';

import '../../../common/custom_shapes/containers/rounded_container.dart';
import '../../../utils/helpers/helper_functions.dart';

class AddStoryScreen extends StatelessWidget {
  const AddStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final imageController = StoryViewController.instance;

    List<Color> colors = <Color>[
      TColors.primary,
      Colors.deepOrange,
      Colors.yellow.shade700,
      Colors.red,
      Colors.black54,
      Colors.blue,
      Colors.purple,
      Colors.brown,
      Colors.pink,
    ];
    RxInt index = 0.obs;
    final captionController = TextEditingController();
    return Obx(
        () => Scaffold(
          backgroundColor: colors[index.value],
            appBar: TAppBar(
                title: Text("Add your Status"),
              actions: [

                /// Photo Uploader
                InkWell(
                  onTap: () async {
                    final image = await ImagePicker().pickImage(
                        source: ImageSource.gallery);

                    // Upload Image
                    if (image != null) {
                      imageController.storyViewImage.value = image.path;
                    }
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
                  onTap: (){},
                  child: const Icon(Icons.near_me, color: Colors.white),
                )
              ],
            ),
          body: imageController.storyViewImage.value == '' ? SingleChildScrollView(
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
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(200)
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace*2),
                      child: RoundedContainer(
                          padding: const EdgeInsets.all(TSizes.defaultSpace / 2),
                          backgroundColor: TColors.black,
                          child: SizedBox(height: 300, width: THelperFunctions.screenWidth(),
                              child: Image.file(File(imageController.storyViewImage.value), fit: BoxFit.fitHeight)))),
                  const SizedBox(height: TSizes.defaultSpace),

                ],
              ),
            ),
          ),
    );
  }
}
