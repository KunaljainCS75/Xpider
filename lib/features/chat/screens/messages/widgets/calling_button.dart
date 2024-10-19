import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../common/custom_shapes/containers/rounded_container.dart';
import '../../../../../data/user/user.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/call_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../call/audio_call_screen.dart';
import '../../call/video_call_screen.dart';

class CallingButton extends StatelessWidget {
  const CallingButton({
    super.key,
    required this.userModelReceiver,
    required this.callController,
  });

  final UserModel userModelReceiver;
  final CallController callController;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      radius: 50,
      onTap: () {

        Get.defaultDialog(
            title: "Choose calling type",
            middleText: "Call via Video or Audio",
            onConfirm: () {
              Get.back();
            },
            confirm: RoundedContainer(
              backgroundColor: Colors.black87,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
                child: IconButton(
                    onPressed: () {
                      Get.to(() =>
                          AudioCallScreen(receiver: userModelReceiver));
                      callController.callUser(UserController.instance.user.value, userModelReceiver, "audio");
                    },
                    icon: const Icon(Icons.call, color: Colors.green)),
              ),
            ),
            cancel: RoundedContainer(
              backgroundColor: Colors.black87,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
                child: IconButton(
                    onPressed: () {
                      Get.to(() =>
                          VideoCallScreen(receiver: userModelReceiver));
                      callController.callUser(UserController.instance.user.value, userModelReceiver, "video");
                    },
                    icon: const Icon(Icons.videocam, color: Colors.blue)),
              ),
            ),
            onCancel: () => () => Get.back()
        );
      },
      child: const Icon(Icons.call, color: Colors.green),
    );
  }
}