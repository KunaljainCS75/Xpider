import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:xpider_chat/data/user/user.dart';
import 'package:xpider_chat/features/chat/controllers/call_controller.dart';
import 'package:xpider_chat/features/chat/controllers/chat_controller.dart';
import 'package:xpider_chat/features/chat/controllers/user_controller.dart';
import 'package:xpider_chat/features/chat/models/call_model.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class AudioCallScreen extends StatelessWidget {
  const AudioCallScreen({
    super.key,
    required this.receiver,
  });

  final UserModel receiver;
  @override
  Widget build(BuildContext context) {
    var zegoCallId = ChatController.instance.getRoomId(receiver.id);
    final controller = CallController.instance;

    final db = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    String callEndTime;
    return ZegoUIKitPrebuiltCall(
      appID: 801094160, // your AppID,
      appSign: 'b94ccb5096c61ef08342c037fb4791cdc2e116988094ab0721fc130a7b00626e',
      userID: UserController.instance.user.value.id,
      userName: UserController.instance.user.value.fullName,
      callID: zegoCallId,

      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
      onDispose: () async {
        callEndTime = DateTime.now().toString();
        await db.collection("Users").doc(auth.currentUser!.uid)
            .collection("Calls").doc(controller.currentCallId.value)
            .update({"CallEndTime" : callEndTime});
        await db.collection("Users").doc(receiver.id)
            .collection("Calls").doc(controller.currentCallId.value)
            .update({"CallEndTime" : callEndTime});

        print("kkk");
      },
    );
  }
}
