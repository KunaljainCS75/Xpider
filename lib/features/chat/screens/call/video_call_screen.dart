import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:xpider_chat/data/user/user.dart';
import 'package:xpider_chat/features/chat/controllers/chat_controller.dart';
import 'package:xpider_chat/features/chat/controllers/user_controller.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../../controllers/call_controller.dart';

class VideoCallScreen extends StatelessWidget {
  const VideoCallScreen({super.key, required this.receiver});

  final UserModel receiver;
  @override
  Widget build(BuildContext context) {
    var zegoCallId = ChatController.instance.getRoomId(receiver.id);
    final controller = CallController.instance;

    final db = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    String callEndTime;
    return ZegoUIKitPrebuiltCall(
      appID: int.tryParse(dotenv.env["API_ID"] ?? "1") ?? 1, // your AppID,
      appSign: dotenv.env["API_SIGN"] ?? '',
      userID: UserController.instance.user.value.id,
      userName: UserController.instance.user.value.fullName,
      callID: zegoCallId,
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
      onDispose: () async {
        callEndTime = DateTime.now().toString();
        await db.collection("Users").doc(auth.currentUser!.uid)
            .collection("Calls").doc(controller.currentCallId.value)
            .update({"CallEndTime" : callEndTime});

        await db.collection("Users").doc(receiver.id)
            .collection("Calls").doc(controller.currentCallId.value)
            .update({"CallEndTime" : callEndTime});
        print("kkvvvv");
      },
    );
  }
}