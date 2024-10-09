import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpider_chat/common/loaders/animation_loader.dart';

import '../constants/colors.dart';
import '../helpers/helper_functions.dart';

class FullScreenLoader{

  static void openLoadingDialog (String text, String animation){
    showDialog(
        context: Get.overlayContext!,
        barrierDismissible: false,
        builder: (_) => PopScope(
          canPop: false,
          child: Container(
            color: THelperFunctions.isDarkMode(Get.context!) ? TColors.dark : TColors.white,
            width: double.infinity,
            height: double.infinity * 0.9,
            child: Center(
              child: AnimationLoader(text: text, animation: animation),
            ),
          ),
        )
    );
  }

  static stopLoading() {
    Navigator.of(Get.overlayContext!).pop();
  }
}