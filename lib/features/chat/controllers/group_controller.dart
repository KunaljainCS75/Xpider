import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:xpider_chat/data/repositories/group/group_repository.dart';
import 'package:xpider_chat/features/chat/controllers/user_controller.dart';
import 'package:xpider_chat/features/chat/models/group_chat_model.dart';
import 'package:xpider_chat/features/chat/models/group_message_model.dart';
import '../../../data/user/user.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/popups/loaders.dart';
import '../models/group_user_model.dart';

class GroupController extends GetxController{
  static GroupController get instance => Get.find();

  final groupRepository = Get.put(GroupRepository());
  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  RxList<GroupUserModel> groupMembers = <GroupUserModel>[].obs;

  RxInt size = 0.obs;
  RxInt adminSize = 0.obs;
  RxBool isLoading = false.obs;
  RxList<String> memberIds = <String>[].obs;
  final RxString selectedSortOption = 'All Groups'.obs;
  RxString selectedImagePath = ''.obs;

  var uuid = const Uuid();

  RxBool imageUploading = false.obs;
  RxList<GroupRoomModel> myGroups =  <GroupRoomModel>[].obs;
  RxList<GroupRoomModel> myGroupsCopy =  <GroupRoomModel>[].obs;


  @override
  void onInit() {
    super.onInit();
    getAllGroupRooms();
    print(myGroups.length);
  }

  Future<void> addGroup({
    required String groupName, String? description, required String groupProfilePicture, required List<GroupUserModel> participants})
  async {


    final groupId = const Uuid().v6();
    var newGroup = GroupRoomModel(
        id: groupId,
        groupName: groupName,
        description: description ?? "No description has been provided",
        participants: participants,
        groupProfilePicture: groupProfilePicture,
        createdAt: DateTime.now().toString(),
        createdBy: UserController.instance.myGroupProfile(),
        status: "Active"
    );

    try {

      /// Store on Database
      for (var user in participants) {
        await db.collection("Users").doc(user.id)
            .collection("Groups").doc(groupId).set(newGroup.toJson());
      }
      await db.collection("AllGroups").doc(groupId).set(newGroup.toJson());

      /// Reset
      groupMembers.clear();
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

    // List<String> myGroupIds = snapshot.docs.map((group) => group['Id'] as String).toList();
    // QuerySnapshot myGroupsDetails = await db.collection("AllGroups").where(FieldPath.documentId, whereIn: myGroupIds).get();

    final groups = snapshot.docs.map((group) => GroupRoomModel.fromSnapshot(group)).toList();
    myGroups.assignAll(groups);
    myGroupsCopy.assignAll(groups);
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
      for (var person in group.participants) {
        await db.collection("Users").doc(person.id).collection("Groups")
            .doc(group.id).collection("Messages").doc(newGroupMessage.id)
            .set(newGroupMessage.toJson());
      }

      /// Update GroupRoom details according to to lastMessage;
      var updatedGroupRoomDetails = GroupRoomModel(
        id: group.id,
        groupName: group.groupName,
        participants: group.participants,
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
      for (var user in group.participants) {
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

  Future <void> removeUser(GroupRoomModel group, List<GroupUserModel> participants, String userId) async {

    try {
      for (var user in participants) {
        DocumentReference docRef = db.collection("Users").doc(user.id)
            .collection("Groups").doc(group.id);

        await docRef.get().then((docSnapshot) {
          List<dynamic> members = List.from(docSnapshot.get('Participants'));
          members.removeWhere((member) => member['Id'] == userId);
          docRef.update({'Participants': members});
        });

      }
      await db.collection("Users").doc(userId).collection("Groups").doc(
          group.id).delete();
      } catch (e) {
        print(e);
      }
    }

  Future <void> addParticipants({required GroupRoomModel group, required List<GroupUserModel> participants}) async {

    /// Update existing groupUsers' Data
    for (var user in group.participants){
      DocumentReference groupDocRef = db.collection("Users").doc(user.id).collection("Groups").doc(group.id);
      await groupDocRef.update({
        'Participants': FieldValue.arrayUnion(participants.map((user) => user.toJson()).toList())
      });
    }

    /// Add new participants in current (not updated) groupMembersList
    for (var user in participants){
      group.participants.add(user);
    }

    var newGroup = GroupRoomModel(
        id: group.id,
        groupName: group.groupName,
        description: group.description ?? "No description has been provided",
        participants: group.participants,
        groupProfilePicture: group.groupProfilePicture,
        createdAt: group.createdAt,
        createdBy: group.createdBy,
        status: "Active"
    );

    /// Update Group Room Details
    for (var user in participants) {
      await db.collection("Users").doc(user.id)
          .collection("Groups").doc(group.id).set(newGroup.toJson());
    }

  }

  int getGroupParticipantsLength(GroupRoomModel group){
    return group.participants.length;
  }

  Future <GroupRoomModel> getGroupById(String id) async {
    final group = await db.collection("Users").doc(UserController.instance.user.value.id)
        .collection("Groups").doc(id).get();
    return GroupRoomModel.fromSnapshot(group);
  }
/// ---------------------------------------------------------------------------------///
  /// Filter Functions
  void showAllGroups(){
    myGroups.clear();
    myGroups.assignAll(myGroupsCopy);
  }

  Future<void> showPinnedGroups() async{
    List <GroupRoomModel> pinnedRooms = <GroupRoomModel>[];
    for (var group in UserController.instance.pinnedGroups){
      pinnedRooms.add(await getGroupById(group));
    }
    myGroups.clear();
    myGroups.assignAll(pinnedRooms);
  }

  Future<void> showFavouriteGroups() async{
    List <GroupRoomModel> favouriteRooms = <GroupRoomModel>[];
    for (var group in UserController.instance.favouriteGroups){
      favouriteRooms.add(await getGroupById(group));
    }
    myGroups.clear();
    myGroups.assignAll(favouriteRooms);
  }

  Future<void> showArchivedGroups() async{
    List <GroupRoomModel> archivedRooms = <GroupRoomModel>[];
    for (var group in UserController.instance.archivedGroups){
      archivedRooms.add(await getGroupById(group));
    }
    myGroups.clear();
    myGroups.assignAll(archivedRooms);
  }

  void sortChats (String sortOption) {
    selectedSortOption.value = sortOption;

    switch (sortOption) {
      case "All Groups" :
        showAllGroups();
        break;
      case "Pinned Groups" :
        showPinnedGroups();
        break;
      case "Favourite Groups" :
        showFavouriteGroups();
        break;
      case "Archived Groups" :
        showArchivedGroups();
        break;
      default:
        showAllGroups();
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
  uploadGroupProfilePicture({required GroupRoomModel group}) async {

    try{
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image != null) {
        imageUploading.value = true;

        // Upload Image
        final imageUrl = await groupRepository.uploadImage('Groups/Images/Profile/', image);

        // Iterate over each document and update the profile picture
        for (var user in group.participants) {
          final groupRoom = await db.collection("Users").doc(user.id)
              .collection("Groups").doc(group.id).get();
          await groupRoom.reference.update({"GroupProfilePicture" : imageUrl});
        }

        // Completion Message
        group.groupProfilePicture = imageUrl;
        Loaders.successSnackBar(title: "Profile Picture Changed", message: "Group profile image has been updated...");

      }
    }
    catch (e) {
      Loaders.warningSnackBar(title: 'Oh Snap', message: "Something went wrong: $e");
    }
    finally {
      imageUploading.value = false;
    }
  }

}