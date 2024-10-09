import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:xpider_chat/features/chat/controllers/user_controller.dart';
import 'package:xpider_chat/features/chat/models/group_chat_model.dart';
import 'package:xpider_chat/features/chat/models/group_message_model.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
import '../models/group_user_model.dart';

class GroupController extends GetxController{
  static GroupController get instance => Get.find();

  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  RxList<GroupUserModel> groupMembers = <GroupUserModel>[].obs;
  RxList<GroupUserModel> groupAdmins = <GroupUserModel>[].obs;


  RxInt size = 0.obs;
  RxInt adminSize = 0.obs;
  RxBool isLoading = true.obs;
  RxList<String> memberIds = <String>[].obs;
  final RxString selectedSortOption = 'All Groups'.obs;
  RxString selectedImagePath = ''.obs;

  var uuid = const Uuid();

  RxBool imageUploading = true.obs;
  RxList<GroupRoomModel> myGroups =  <GroupRoomModel>[].obs;


  @override
  void onInit() {
    super.onInit();
    getAllGroupRooms();
    print(myGroups.length);
  }

  Future<void> addGroup({
    required String groupName, String? description, required String groupProfilePicture, required List<GroupUserModel> users, required List<GroupUserModel> admins})
  async {
    for (var user in admins){
        users.removeWhere((person) => user.id == person.id);
      }

    final groupId = const Uuid().v6();
    var newGroup = GroupRoomModel(
        id: groupId,
        groupName: groupName,
        description: description ?? "No description has been provided",
        admins: admins,
        users: users,
        groupProfilePicture: groupProfilePicture,
        createdAt: DateTime.now().toString(),
        createdBy: UserController.instance.myGroupProfile(),
        status: "Active"
    );

    try {

      /// Store on Database
      for (var user in admins) {
        await db.collection("Users").doc(user.id)
            .collection("Groups").doc(groupId).set(newGroup.toJson());
      }

      for (var user in users) {
        await db.collection("Users").doc(user.id)
            .collection("Groups").doc(groupId).set(newGroup.toJson());
      }

      /// Reset
      groupMembers.clear();
      groupAdmins.clear();
      size.value = 0;
      adminSize.value = 0;
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch Groups
  void getAllGroupRooms() async {
    final snapshot = await db.collection("Users").doc(auth.currentUser!.uid)
        .collection("Groups").get();

    final groups = snapshot.docs.map((group) => GroupRoomModel.fromSnapshot(group)).toList();
    myGroups.assignAll(groups);
  }

    Stream<List<GroupMessageModel>> getGroupMessages ({required String memberId, required String groupId}){

    final messages =  db.collection("Users").doc(memberId)
        .collection("Groups").doc(groupId).collection("Messages")
        .orderBy("LastMessageTime", descending: true)
        .snapshots().map((snapshot) => snapshot.docs.map((doc) => GroupMessageModel.fromSnapshot(doc)
    ).toList());
    return messages;
  }
  /// ---------------------------------------------------------------------------------///
  /// Send Messages (Group)
  Future<void> sendMessage (GroupRoomModel group, GroupUserModel createdBy, GroupUserModel sender, String message, String? imgUrl) async {
    isLoading.value = true;
    try {

      /// Store Message on database:
      var newGroupMessage = GroupMessageModel(
        id: uuid.v6(), // Message Id
        groupName: group.groupName,
        lastMessageTime: DateTime.now().toString(),
        profileImage: sender.profilePicture,
        imageUrl: imgUrl,
        senderId: sender.id,
        senderName: sender.fullName,
        senderMessage: message,
        senderPhoneNo: sender.phoneNumber,
        senderUserName: sender.username,
      );

      /// Update Message record in all member's database
      for (var person in group.admins) {
        await db.collection("Users").doc(person.id).collection("Groups")
            .doc(group.id).collection("Messages").doc(newGroupMessage.id)
            .set(newGroupMessage.toJson());
      }
      for (var person in group.editors!) {
        await db.collection("Users").doc(person.id).collection("Groups")
            .doc(group.id).collection("Messages").doc(newGroupMessage.id)
            .set(newGroupMessage.toJson());
      }
      for (var person in group.users!) {
        await db.collection("Users").doc(person.id).collection("Groups")
            .doc(group.id).collection("Messages").doc(newGroupMessage.id)
            .set(newGroupMessage.toJson());
      }


      /// Update GroupRoom details according to to lastMessage;
      var updatedGroupRoomDetails = GroupRoomModel(
        id: group.id,
        groupName: group.groupName,
        admins: group.admins,
        editors: group.editors,
        users: group.users,
        createdAt: group.createdAt,
        createdBy: group.createdBy,
        status: group.status,
        lastMessage: message,
        lastMessageTime: DateTime.now().toString(),
        lastMessageBy: sender.fullName,
        isArchived: group.isArchived,
        isPinned: group.isPinned,
        isRead: group.isRead,
        isFavourite: group.isFavourite,
        groupProfilePicture: group.groupProfilePicture,
        unreadMessages: group.unreadMessages,
        groupMessages: group.groupMessages,
        description: group.description
      );

      /// Update Group Room Details
      for (var user in group.admins) {
        await db.collection("Users").doc(user.id)
            .collection("Groups").doc(group.id).update(updatedGroupRoomDetails.toJson());
      }
      for (var user in group.editors!) {
        await db.collection("Users").doc(user.id)
            .collection("Groups").doc(group.id).update(updatedGroupRoomDetails.toJson());
      }
      for (var user in group.users!) {
        await db.collection("Users").doc(user.id)
            .collection("Groups").doc(group.id).update(updatedGroupRoomDetails.toJson());
      }

    } catch (e) {
      rethrow;
    }
    finally{
      isLoading.value = false;
    }
  }
/// ---------------------------------------------------------------------------------///
  void sortChats (String sortOption) {
    selectedSortOption.value = sortOption;

    switch (sortOption) {
      case "All Groups" :
        // s.value++;
        // showAllChats();
        break;
      case "Pinned Groups" :
        // s.value = 9;
        // showPinnedChats();
        break;
      case "Favourite Groups" :
        // s.value = 8;
        // showFavouriteChats();
        break;
      case "Archived Groups" :
        // s.value = 1;
        // showArchivedChats();
        break;
    // case "Groups" :
    //   getRoomId(auth.currentUser!.uid);
    //   break;
      default:
        // getAllChatRooms();

    }
  }

  /// Profile Picture open
  void showEnlargedImage(String image) {
    Get.to(
        fullscreenDialog: true,
            () => Dialog.fullscreen(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: TSizes.defaultSpace * 2, horizontal: TSizes.defaultSpace * 2),
                child: image == TImages.group? Image(height: 200, image: AssetImage(image)) : CachedNetworkImage(height: 200, imageUrl: image),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: 150,
                  child: OutlinedButton(onPressed: () => Get.back(), child: const Text('Close')),
                ),
              )
            ],
          ),
        )
    );
  }


/// Update User Profile picture
  // uploadUserProfilePicture() async {
  //   try{
  //
  //     final image = await ImagePicker().pickImage(source: ImageSource.gallery);
  //
  //     if (image != null) {
  //       imageUploading.value = true;
  //
  //       // Upload Image
  //       final imageUrl = await UserRepository.instance.uploadImage('Groups/Images/', image);
  //
  //       QuerySnapshot snapshot = await db.collection("AllChats").where('Receiver.Email', isEqualTo: user.value.email).get();
  //
  //
  //       // Logging the number of documents returned
  //       // print("Number of chat rooms found: ${snapshot.docs.length}");
  //
  //       // Iterate over each document and update the profile picture
  //       for (var chatRoom in snapshot.docs) {
  //         await chatRoom.reference.update({"Receiver.ProfilePicture": imageUrl});
  //       }
  //
  //       // Update User Image Record
  //       Map<String, dynamic> json = {'ProfilePicture': imageUrl};
  //       await userRepository.updateSingleField(json);
  //       user.value.profilePicture = imageUrl;
  //       user.refresh();
  //
  //       Loaders.successSnackBar(title: "Profile Picture Changed", message: "Your profile image has been updated...");}
  //   }
  //   catch (e) {
  //     Loaders.warningSnackBar(title: 'Oh Snap', message: "Something went wrong: $e");
  //   }
  //   finally {
  //     imageUploading.value = false;
  //   }
  // }

}