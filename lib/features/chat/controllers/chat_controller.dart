import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:xpider_chat/data/repositories/user/user_repository.dart';
import 'package:xpider_chat/features/chat/controllers/user_controller.dart';
import 'package:xpider_chat/features/chat/models/chat_message_model.dart';
import 'package:xpider_chat/features/chat/models/chat_room_model.dart';
import 'package:xpider_chat/features/chat/models/thread_model.dart';
import 'package:xpider_chat/utils/constants/image_strings.dart';

import '../../../data/user/user.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/popups/loaders.dart';

class ChatController extends GetxController{
  static ChatController get instance => Get.find();

  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  RxBool isLoading = true.obs;
  RxBool imageUploading = true.obs;
  var uuid = const Uuid();
  var selectedDay = DateTime.now().obs;
  var focusedDay = DateTime.now().obs;
  RxList<ChatRoomModel> chatRoomList = <ChatRoomModel>[].obs;
  RxList<ChatRoomModel> chatRoomListCopy = <ChatRoomModel>[].obs;
  RxString selectedImagePath = ''.obs;
  final RxString selectedSortOption = 'All Chats'.obs;

  @override
  void onInit() {
    super.onInit();
    getAllChatRooms();

  }

  void onDaySelected(DateTime selectDay, DateTime focusDay) {
    selectedDay.value = selectDay;
    focusedDay.value = focusDay;
  }

  String getRoomId(String targetUserId){
    String currentUserId = auth.currentUser!.uid;
    if (currentUserId[0].codeUnitAt(0) > targetUserId[0].codeUnitAt(0)){
      return currentUserId + targetUserId;
    } else {
      return targetUserId + currentUserId;
    }
  }



  Future<void> sendMessage (String targetUserId, UserModel receiver, String message, String? imgUrl) async {
    isLoading.value = true;
    String roomId = getRoomId(targetUserId);
    try {
      var newChatMessage = ChatMessageModel(
        id: uuid.v6(),
        chatName: receiver.fullName,
        lastMessageTime: DateTime.now().toString(),
        profileImage: receiver.profilePicture,
        imageUrl: imgUrl,
        senderId: auth.currentUser!.uid,
        receiverId: targetUserId,
        senderName: auth.currentUser!.displayName.toString(),
        receiverName: receiver.fullName,
        senderMessage: message,
      );

      var sender = await UserRepository.instance.fetchUserDetails();

      var roomDetails = ChatRoomModel(
        id: roomId,
        lastMessage: message.toString(),
        lastMessageTime: DateTime.now().toString(),
        sender: sender,
        receiver: receiver,
        imgUrl: imgUrl
      );

      await db.collection("AllChats").doc(roomId).collection("Messages").doc(
          newChatMessage.id).set(newChatMessage.toJson());

      await db.collection("AllChats").doc(roomId).set(roomDetails.toJson());

    } catch (e) {
      print(e);
    }
    finally{
      isLoading.value = false;
    }
  }

  Stream<List<ChatMessageModel>> getMessages (String targetUserId){
    String roomId = getRoomId(targetUserId);
    
    return db.collection("AllChats").doc(roomId)
                    .collection("Messages")
                        .orderBy("LastMessageTime", descending: true)
                          .snapshots().map((snapshot) => snapshot.docs.map((doc) => ChatMessageModel.fromSnapshot(doc)
    ).toList());
  }

  uploadUserProfilePicture() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image != null) {
        imageUploading.value = true;

        // Upload Image
        selectedImagePath.value = image.toString();

        // // Update User Image Record
        // Map<String, dynamic> json = {'ProfilePicture': imageUrl};
        // await userRepository.updateSingleField(json);
        // user.value.profilePicture = imageUrl;
        // user.refresh();

        Loaders.successSnackBar(title: "Profile Picture Changed",
            message: "Your profile image has been updated...");
      }
    } catch (e) {
      Loaders.warningSnackBar(
          title: 'Oh Snap', message: "Something went wrong: $e");
    }
    finally {
      imageUploading.value = false;
    }
  }

  Future <ChatRoomModel> getChatRoomByUserId(String targetUserId) async {
    List<ChatRoomModel> roomList = <ChatRoomModel>[];

    final room = await db.collection("AllChats").doc(getRoomId(targetUserId)).get();
    final chatroom = ChatRoomModel.fromJson(room);
    return chatroom;
  }


  void getAllChatRooms() async {
    List<ChatRoomModel> roomList = <ChatRoomModel>[];

    final rooms = await db.collection("AllChats").where('Sender.Id', isEqualTo: auth.currentUser!.uid).get();
    roomList = rooms.docs.map((room) => ChatRoomModel.fromJson(room)).toList();

    chatRoomList.assignAll(roomList);
    chatRoomListCopy.assignAll(roomList);
  }

  Future <List<ChatRoomModel>> getChatRoomsBySearch (String name) async{
    List <ChatRoomModel> resultChatRooms = [];

    for (var chatRoom in chatRoomList) {
      if (chatRoom.receiver.fullName.toLowerCase().contains(name.toLowerCase())){
        resultChatRooms.add(chatRoom);
      }
    }
    return resultChatRooms;
  }

  /// Filter Functions
  void showAllChats(){
    chatRoomList.clear();
    chatRoomList.assignAll(chatRoomListCopy);
  }

  Future<void> showPinnedChats() async{
    List <ChatRoomModel> pinnedRooms = <ChatRoomModel>[];
    for (var chat in UserController.instance.pinnedChats){
      pinnedRooms.add(await getChatRoomByUserId(chat));
    }
    chatRoomList.clear();
    chatRoomList.assignAll(pinnedRooms);
  }

  Future<void> showFavouriteChats() async{
    List <ChatRoomModel> favouriteRooms = <ChatRoomModel>[];
    for (var chat in UserController.instance.favouriteChats){
      favouriteRooms.add(await getChatRoomByUserId(chat));
    }
    chatRoomList.clear();
    chatRoomList.assignAll(favouriteRooms);
  }

  Future<void> showArchivedChats() async{
    List <ChatRoomModel> archivedRooms = <ChatRoomModel>[];
    for (var chat in UserController.instance.archivedChats){
      archivedRooms.add(await getChatRoomByUserId(chat));
    }
    chatRoomList.clear();
    chatRoomList.assignAll(archivedRooms);
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
                child: image == TImages.user ? Image(height: 200, image: AssetImage(image)) : CachedNetworkImage(height: 200, imageUrl: image),
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

  void sortChats (String sortOption) {
    selectedSortOption.value = sortOption;

    switch (sortOption) {
      case "All Chats" :
        showAllChats();
        break;
      case "Pinned Chats" :
        showPinnedChats();
        break;
      case "Favourites" :
        showFavouriteChats();
        break;
      case "Archives" :
        showArchivedChats();
        break;
      // case "Groups" :
      //   getRoomId(auth.currentUser!.uid);
      //   break;
      default:
        getAllChatRooms();

    }
  }
}