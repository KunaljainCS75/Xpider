import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:xpider_chat/common/custom_shapes/containers/rounded_container.dart';
import 'package:xpider_chat/utils/constants/sizes.dart';
import 'package:xpider_chat/utils/helpers/helper_functions.dart';

import '../../../../../utils/constants/colors.dart';


class StoryCaptionTypeBar extends StatelessWidget {
  const StoryCaptionTypeBar({super.key, required this.captionController, this.isImageStory = false});

  final TextEditingController captionController;

  final bool isImageStory;
  @override
  Widget build(BuildContext context) {
    RxInt size = (captionController.text.length).obs;
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: isImageStory ?
        Padding(
          padding: EdgeInsets.only(left: TSizes.defaultSpace),
          child: RoundedContainer(
            width: THelperFunctions.screenWidth(),
            backgroundColor: Colors.black26,
            showBorder: true,
            borderColor: Colors.white,
            child: TextField(
              controller: captionController,
              textAlign: TextAlign.center,
              textInputAction: TextInputAction.newline,
              // textAlignVertical: TextAlignVertical.center,
              cursorColor: TColors.white,
              minLines: 1,
              maxLines: 3,
              onChanged: (value) {
                size.value = captionController.text.length;
              },
              scrollPhysics: const BouncingScrollPhysics(),
              cursorOpacityAnimates: true,
              decoration: const InputDecoration(
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  border: InputBorder.none,
                  hintFadeDuration: Duration(milliseconds: 500),
                  hintText: "Type Captions...",
                  hintStyle: TextStyle(color: Colors.white54)
              ),
            ),
          ),
        )
            : Center(
              child: Obx(
                () => TextField(
                          controller: captionController,
                          textAlign: TextAlign.center,
                          textInputAction: TextInputAction.newline,
                          // textAlignVertical: TextAlignVertical.center,
                          cursorColor: TColors.white,
                          minLines: 1,
                          maxLines: 20,
                          maxLength: 1000,
                          style: TextStyle(
                  fontSize: size > 100 ? 20 : 30
                          ),
                          onChanged: (value) {
                size.value = captionController.text.length;
                          },
                          scrollPhysics: const BouncingScrollPhysics(),
                          cursorOpacityAnimates: true,
                          decoration: const InputDecoration(
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  border: InputBorder.none,
                  hintFadeDuration: Duration(milliseconds: 500),
                  hintText: "Type Captions...",
                  hintStyle: TextStyle(color: Colors.white54)
                          ),
                        ),
              ),

      ),
    );
  }
}
