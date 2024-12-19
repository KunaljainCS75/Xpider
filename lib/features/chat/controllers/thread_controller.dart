import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:xpider_chat/data/repositories/group/group_repository.dart';
import 'package:xpider_chat/data/repositories/user/user_repository.dart';
import 'package:xpider_chat/features/chat/controllers/chat_controller.dart';
import 'package:xpider_chat/features/chat/models/thread_model.dart';
import '../../../data/user/user.dart';
import '../models/thread_room_model.dart';


class ThreadController extends GetxController {
  static ThreadController get instance => Get.find();

  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  final userRepository = UserRepository.instance;
  RxBool isLoading = true.obs;
  RxBool imageUploading = true.obs;
  var uuid = const Uuid();
  RxList<ThreadMessage> threadRoomList = <ThreadMessage>[].obs;
  RxString selectedImagePath = ''.obs;
  XFile? selectedImage;



  String getThreadId(index){
    return "Thread - $index";
  }


  Future<void> addThread(UserModel receiver,
      String message, String? imgUrl, String threadName) async {

    isLoading.value = true;
    var sender = await UserRepository.instance.fetchUserDetails();
    String roomId = ChatController.instance.getRoomId(receiver.id);
    
    // Fetch threadCount
    final room = await db.collection("Users").doc(sender.id).collection("Chats").doc(roomId).get();
    final threadCount = room.get("ThreadCount");
    print(threadCount);
    final threadId = getThreadId(threadCount + 1);

    // Create Thread Id
    try {
      var threadRoomDetails = ThreadRoomModel(
          id: threadId,
          threadName: threadName,
          lastMessage: message.toString(),
          lastMessageTime: DateTime.now().toString(),
          sender: sender,
          receiver: receiver,
          imgUrl: imgUrl
      );

      // Set Thread Details in thread Room
      await db.collection("Users").doc(sender.id).collection("Chats").doc(roomId).collection("Threads").doc(threadId).set(threadRoomDetails.toJson());
      await db.collection("Users").doc(receiver.id).collection("Chats").doc(roomId).collection("Threads").doc(threadId).set(threadRoomDetails.toJson());
      
      // Update ThreadCount for both users
      await db.collection("Users").doc(sender.id).collection("Chats").doc(roomId).update({"ThreadCount" : threadCount + 1});
      await db.collection("Users").doc(receiver.id).collection("Chats").doc(roomId).update({"ThreadCount" : threadCount + 1});
    
    } catch (e) {
      print(e);
    }
    finally {
      isLoading.value = false;
    }
  }

  Future<void> sendThreadMessage(ThreadMessage thread, UserModel receiver, String? message, XFile? image) async {

    String roomId = ChatController.instance.getRoomId(receiver.id);
    var sender = await UserRepository.instance.fetchUserDetails();

    String imageUrl = '';
    if (image!= null){
      // upload image
      imageUrl = await userRepository.uploadImage('Threads/Images/${thread.threadName}/', image);
    }
    selectedImage = null;
    // Create new Thread Message
    var newThreadMessage = ThreadMessage(
      id: uuid.v6(),
      threadName: thread.threadName,
      lastMessageTime: DateTime.now().toString(),
      // profileImage: receiver.profilePicture,
      imageUrl: imageUrl,
      senderId: sender.id,
      receiverId: receiver.id,
      senderName: sender.fullName,
      receiverName: receiver.fullName,
      senderMessage: message,
    );


    // Update Message on both sides
    await db.collection("Users").doc(sender.id).collection("Chats").doc(roomId).collection("Threads").doc(thread.id)
        .collection("ThreadMessages").doc(newThreadMessage.id).set(newThreadMessage.toJson());
    await db.collection("Users").doc(receiver.id).collection("Chats").doc(roomId).collection("Threads").doc(thread.id)
        .collection("ThreadMessages").doc(newThreadMessage.id).set(newThreadMessage.toJson());


  }



  Future<List<ThreadMessage>> getThreads(String roomId) async {

      final threads =  await db.collection("Users").doc(auth.currentUser!.uid)
          .collection("Chats").doc(roomId).collection("Threads").get();
      final threadsList = threads.docs.map((thread) =>
          ThreadMessage.fromSnapshot(thread)).toList();
      threadRoomList.assignAll(threadsList);
      return threadsList;

  }

  Stream<List<ThreadMessage>> getThreadMessages (String targetUserId, String threadId){
    String roomId = ChatController.instance.getRoomId(targetUserId);

    return db.collection("Users").doc(auth.currentUser!.uid).collection("Chats").doc(roomId)
        .collection("Threads").doc(threadId).collection("ThreadMessages")
        .orderBy("LastMessageTime", descending: true)
        .snapshots().map((snapshot) => snapshot.docs.map((doc) => ThreadMessage.fromSnapshot(doc)
    ).toList());
  }


}