import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:story_view/story_view.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:xpider_chat/features/activity/controller/status_controller.dart';
import 'package:xpider_chat/features/activity/models/story_model.dart';
import 'package:xpider_chat/features/chat/controllers/user_controller.dart';

class StoryViewController extends GetxController{
  static StoryViewController get instance => Get.find();

  // RxList<String> imgUrl = <String>[].obs;
  // RxList<String> captions = <String>[].obs;

  RxList<StoryItem> storyItems = <StoryItem>[].obs;
  RxString storyViewImage = ''.obs;
  RxInt seen = 0.obs;
  final db = UserController.instance.db;
  final user = UserController.instance.user;
  final storyController = StoryController();

  RxList friendStoriesList = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyStories();
  }

  Future<void> fetchMyStories() async {
    final userStories = await db.collection("Status").doc(user.value.id)
        .collection("Stories").orderBy("CreatedAt").get();

    final List<StoryModel> stories = userStories.docs.map((story) => StoryModel.fromJson(story)).toList();

    for (var story in stories){
      if (story.type == "Image") {
        storyItems.add(
            StoryItem.pageImage(
                url: story.imageUrl!,
                caption: Text(story.captions!, textAlign: TextAlign.center),
                imageFit: BoxFit.fitWidth,
                controller: storyController
            )
        );
      } else {
        storyItems.add(
            StoryItem.text(
                title: story.captions!,
                backgroundColor: Color(int.parse(story.color!.substring(
                    story.color!.indexOf('0x'),
                    story.color!.indexOf(')'))))
            )
        );
      }
    }
  }

  Future <void> fetchFriendStories() async {
    final List friendIds = StatusController.instance.friendsStatusId;
    friendStoriesList.clear();
    print("y00 ${friendIds.length}");
    for (var id in friendIds) {

      if (id != user.value.id){
      final friendStories = await db.collection("Status").doc(id)
          .collection("Stories").orderBy("CreatedAt").get();

      final List<StoryModel> stories = friendStories.docs.map((story) => StoryModel.fromJson(story)).toList();
      final List<StoryItem> storyList = [];

        for (var story in stories) {
          if (story.type == "Image") {
            storyList.add(
                StoryItem.pageImage(
                    url: story.imageUrl!,
                    caption: Text(story.captions!, textAlign: TextAlign.center),
                    imageFit: BoxFit.fitWidth,
                    controller: storyController
                )
            );
            // print(friendStoriesList.length + 1000000000);
          }
          else {
            storyList.add(StoryItem.text(
                title: story.captions!,
                backgroundColor: Color(int.parse(story.color!.substring(
                  story.color!.indexOf('0x'),
                  story.color!.indexOf(')')))))
            );
          }
        }
      friendStoriesList.add(storyList);
      }
    }
  }

}