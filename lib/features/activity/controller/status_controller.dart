import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:uuid/uuid.dart';
import 'package:xpider_chat/features/activity/controller/story_controller.dart';
import 'package:xpider_chat/features/chat/controllers/user_controller.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/popups/loaders.dart';
import '../models/status_model.dart';
import '../models/story_model.dart';

class StatusController extends GetxController{
  static StatusController get instance => Get.find();

  RxList<StatusUserModel> friends = <StatusUserModel>[].obs;

  final user = UserController.instance.user;
  final db = UserController.instance.db;
  Rx<StatusUserModel> status = StatusUserModel.empty().obs;
  RxList<String> friendsStatusId = <String>[].obs;
  RxList<StatusUserModel> friendsStatusList = <StatusUserModel>[].obs;
  RxBool isStatusLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getStatusUpdates(user.value.id);

  }

  /// Fetch Status Info
  Future<void> getStatusUpdates(String id) async {
    try {
      final document = await db.collection("Status").doc(id).get();
      // Or can be written as:->
      // DocumentSnapshot<Map<String, dynamic>> doc = await db.collection("Status").doc(id).get();
      status(StatusUserModel.fromSnapshot(document));
    } catch (e) {
      print (e);
    }
  }

  /// Update User Status picture
  Future<String?> uploadUserStory({XFile? image, String? captions, int? color}) async {
    try{
      isStatusLoading.value = true;
      final String imageUrl;
      // Upload Image
      if (image != null) {
       imageUrl = await UserRepository.instance.uploadImage('Users/Images/Status/', image);
      } else {
        imageUrl = TImages.status;
      }
      final statusId = const Uuid().v4();

      StatusUserModel status = StatusUserModel(
          senderName: user.value.fullName,
          senderProfilePicture: user.value.profilePicture,
          seenIndex: 0,
          imageUrl: imageUrl,
          lastUpdateTime: DateTime.now().toString()
      );

      StoryModel story = StoryModel(
          captions: captions,
          imageUrl: imageUrl,
          color: color,
          type: color == null ? "Image" : "Text",
          createdAt: DateTime.now().toString());

      // Upload Status details on FireBase
      await db.collection("Status").doc(user.value.id).set(status.toJson());

      // Upload Story details on FireBase
      await db.collection("Status").doc(user.value.id).collection("Stories").doc(statusId).set(story.toJson());
      getStatusUpdates(user.value.id);
      Loaders.successSnackBar(title: "Status Uploaded", message: "Your Status image has been uploaded...");

      // Set Deletion Timer:
      Future.delayed(const Duration(hours: 24), () {
        deleteStatus(statusId);
      });
      return imageUrl;
    }
    catch (e) {
      Loaders.warningSnackBar(title: 'Oh Snap', message: "Something went wrong: $e");
    }
    finally{
      isStatusLoading.value = false;
      StoryViewController.instance.fetchMyStories();
    }
    return null;
  }

  Future<void> deleteStatus(String statusId) async {
    await db.collection('Status').doc(user.value.id).collection("Stories").doc(statusId).delete();
  }

  Future<void> getReceiverIdFromChatId() async {
    final myRooms = await db.collection("Users").doc(user.value.id)
        .collection("Chats").get();
    List<String> ids = myRooms.docs.map((doc) => doc.id).toList();
    for (var id in ids){
      final statusId = id.replaceFirst(user.value.id, '');
      if  (!friendsStatusId.contains(statusId)) {
        friendsStatusId.add(statusId);
      }
    }
  }
  Future<void> fetchMyFriendsStatus() async {
    await getReceiverIdFromChatId();
    friendsStatusList.clear();
    for (var id in friendsStatusId) {
      if (id != user.value.id) {
        final document = await db.collection("Status").doc(id).get();
        if (document.exists) {
          final friendStatus = StatusUserModel.fromSnapshot(document);
          friendsStatusList.add(friendStatus);
        }
      }
    }
    print(friendsStatusList.length);
  }


}