import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:xpider_chat/data/user/user.dart';
import 'package:xpider_chat/features/chat/models/call_model.dart';
import 'package:xpider_chat/features/chat/screens/call/audio_call_screen.dart';

import '../screens/call/video_call_screen.dart';

class CallController extends GetxController{
  static CallController get instance => Get.find();

  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  RxString currentCallId = ''.obs;
  RxList<CallModel> callLogs = <CallModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    getAllCalls();
    getNotificationStream().listen(
        (List<CallModel> callList) {
          if (callList.isNotEmpty){
            var callData = callList[0];
            if (callData.callType == 'audio'){
              audioCallNotification(callData);
            } else {
              videoCallNotification(callData);
            }
          }
        }
    );
  }

  Future<void> audioCallNotification(CallModel callData) async {
    Get.snackbar(
        backgroundColor: Colors.black54,
        barBlur: 5,
        isDismissible: false,
        icon: const Icon(Icons.call),
        animationDuration: const Duration(milliseconds: 400),
        duration: const Duration(days: 1),
        onTap: (snack){
          Get.to(() => AudioCallScreen(
            receiver: UserModel(
                id: callData.callerId,
                firstName: callData.callerName,
                lastName: '',
                email: "",
                profilePicture: callData.callerProfilePicture, username: '', phoneNumber: ''
            ),
          ));
          Get.back();
        },
        callData.callerName, "Incoming audio call",
        mainButton: TextButton(
            onPressed: () async {
              Get.snackbar(
                  animationDuration: const Duration(milliseconds: 400),
                  duration: const Duration(seconds: 3),
                  "Call Ended", "You have ended the call");
              Get.back();
            },
            child: const Text("End Call")
        )
    );
  }

  Future<void> videoCallNotification(CallModel callData) async {
    Get.snackbar(
        backgroundColor: Colors.black54,
        animationDuration: const Duration(milliseconds: 400),
        barBlur: 5,
        isDismissible: false,
        icon: const Icon(Icons.videocam),
        duration: const Duration(days: 1),
        onTap: (snack){
          Get.to(() => VideoCallScreen(
            receiver: UserModel(
                id: callData.callerId,
                firstName: callData.callerName,
                lastName: '',
                email: "",
                profilePicture: callData.callerProfilePicture, username: '', phoneNumber: ''
            ),
          ));
          Get.back();
        },
        callData.callerName, "Incoming video call",
        mainButton: TextButton(
            onPressed: () async {
              Get.snackbar(
                  animationDuration: const Duration(milliseconds: 400),
                  duration: const Duration(seconds: 3),
                  "Call Ended", "You have ended the video call");
              Get.back();
            },
            child: const Text("End Call")
        )
    );
  }

  Future <void> callUser(UserModel caller, UserModel receiver, String type) async {
    String callId = const Uuid().v4();
    currentCallId.value = callId;
    var newCall = CallModel(
      callId: callId,
      callerId: caller.id,
      callerName: caller.fullName,
      callerProfilePicture: caller.profilePicture,
      receiverId: receiver.id,
      receiverName: receiver.fullName,
      receiverProfilePicture: receiver.profilePicture,
      status: "dialing",
      callType: type,
      callStartTime: DateTime.now().toString(),
    );

    try {
      await db.collection("Notification").doc(receiver.id)
          .collection("Calls").doc(callId).set(newCall.toJson());
      await db.collection("Users").doc(auth.currentUser!.uid)
          .collection("Calls").doc(callId).set(newCall.toJson());
      await db.collection("Users").doc(receiver.id)
          .collection("Calls").doc(callId).set(newCall.toJson());

      Future.delayed(const Duration(seconds: 15), () {
        endCall(newCall);
      });
    } catch (e) {
      rethrow;
    }
  }

  Future <void> endCall(CallModel call) async {
    try {
      await db.collection("Notification").doc(call.receiverId)
          .collection("Calls").doc(call.callId).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getAllCalls() async {
    final calls = await db.collection("Users").doc(auth.currentUser!.uid)
        .collection("Calls").orderBy("CallStartTime", descending: true).get();

    callLogs.assignAll(calls.docs.map((call) => CallModel.fromSnapshot(call)).toList());
  }

  Stream<List<CallModel>> getNotificationStream() {
    return db.collection("Notification").doc(auth.currentUser!.uid)
        .collection("Calls").snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => CallModel.fromJson(doc.data())).toList());
  }
}