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
  final userRepository = UserRepository.instance;
  RxBool isLoading = true.obs;
  RxBool imageUploading = true.obs;
  var uuid = const Uuid();
  var selectedDay = DateTime.now().obs;
  var focusedDay = DateTime.now().obs;
  RxList<ChatRoomModel> chatRoomList = <ChatRoomModel>[].obs;
  RxList<ChatRoomModel> chatRoomListCopy = <ChatRoomModel>[].obs;
  RxList<ChatRoomModel> pinnedChatRoomList = <ChatRoomModel>[].obs;
  RxString selectedImagePath = ''.obs;
  XFile? selectedImage;
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



  Future<void> sendMessage ({required UserModel receiver, required UserModel sender, required String message, XFile? image}) async {
    isLoading.value = true;
    String roomId = getRoomId(receiver.id);

    String imageUrl = '';
    if (image!= null){
      // upload image
      imageUrl = await userRepository.uploadImage('Chats/Images/', image);
    }
    selectedImage = null;

      var newChatMessage = ChatMessageModel(
        id: uuid.v6(),
        chatName: receiver.fullName,
        lastMessageTime: DateTime.now().toString(),
        profileImage: receiver.profilePicture,
        imageUrl: imageUrl,
        senderId: sender.id,
        receiverId: receiver.id,
        senderName: sender.fullName,
        receiverName: receiver.fullName,
        senderMessage: message,
        isRead: false
      );

      // Fetch Room Details from both side...
      var roomSender = await getChatRoomByUserId(sender.id, receiver.id);
      var roomReceiver = await getChatRoomByUserId(receiver.id, receiver.id);

      var roomDetails1 = ChatRoomModel(
        id: roomId,
        lastMessage: message.toString(),
        lastMessageTime: DateTime.now().toString(),
        sender: sender,
        receiver: receiver,
        imgUrl: imageUrl,
        isPinned: roomSender.isPinned,
        isArchived: roomSender.isArchived,
        isFavourite: roomSender.isFavourite,
        isRead: roomSender.isRead,
        unreadMessages: roomSender.unreadMessages,
        threadCount: roomSender.threadCount
      );

      var roomDetails2 = ChatRoomModel(
          id: roomId,
          lastMessage: message.toString(),
          lastMessageTime: DateTime.now().toString(),
          sender: sender,
          receiver: receiver,
          imgUrl: imageUrl,
          isPinned: roomReceiver.isPinned,
          isArchived: roomReceiver.isArchived,
          isFavourite: roomReceiver.isFavourite,
          isRead: roomReceiver.isRead,
          unreadMessages: roomReceiver.unreadMessages,
          threadCount: roomReceiver.threadCount
      );

      // Update Messages on Both Sides
      await db.collection("Users").doc(sender.id).collection("Chats").doc(roomId)
          .collection("Messages").doc(newChatMessage.id).set(newChatMessage.toJson());

      await db.collection("Users").doc(receiver.id).collection("Chats").doc(roomId)
          .collection("Messages").doc(newChatMessage.id).set(newChatMessage.toJson());

      // Update Room Details on both sides w.r.t. sender and receiver
      await db.collection("Users").doc(sender.id).collection("Chats").doc(roomId)
          .set(roomDetails1.toJson());

      await db.collection("Users").doc(receiver.id).collection("Chats").doc(roomId)
          .set(roomDetails2.toJson());


      isLoading.value = false;

  }

  Stream<List<ChatMessageModel>> getMessages (String targetUserId){
    String roomId = getRoomId(targetUserId);
    
    return db.collection("Users").doc(auth.currentUser!.uid)
                    .collection("Chats").doc(roomId).collection("Messages")
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

  Future <ChatRoomModel> getChatRoomByUserId(String userId, String targetUserId) async {
    final room = await db.collection("Users").doc(userId).collection("Chats").doc(getRoomId(targetUserId)).get();
    final chatroom = ChatRoomModel.fromJson(room);
    return chatroom;
  }


  void getAllChatRooms() async {
    final rooms = await db.collection("Users").doc(auth.currentUser!.uid)
        .collection("Chats").orderBy("LastMessageTime", descending: true).get();
    final roomList = rooms.docs.map((room) => ChatRoomModel.fromJson(room)).toList();

    chatRoomList.clear();
    for (var chat in roomList){
      if (!chat.isArchived){
        chatRoomList.add(chat);
      }
    }
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
    for (var chat in chatRoomListCopy){
      if (!chat.isArchived) {
        chatRoomList.add(chat);
      }
    }
  }

  Future<void> showPinnedChats() async{
    List <ChatRoomModel> pinnedRooms = <ChatRoomModel>[];
    for (var chat in chatRoomListCopy) {
      if (chat.isPinned) {
        pinnedRooms.add(chat);
      }
    }
    chatRoomList.clear();
    chatRoomList.assignAll(pinnedRooms);
  }



  Future<void> showFavouriteChats() async{
    List <ChatRoomModel> favouriteRooms = <ChatRoomModel>[];
    for (var chat in chatRoomListCopy){
      if (chat.isFavourite) {
        favouriteRooms.add(chat);
      }
    }
    chatRoomList.clear();
    chatRoomList.assignAll(favouriteRooms);
  }

  Future<void> showArchivedChats() async{
    List <ChatRoomModel> archivedRooms = <ChatRoomModel>[];
    for (var chat in chatRoomListCopy){
      if (chat.isArchived){
        archivedRooms.add(chat);
      }
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