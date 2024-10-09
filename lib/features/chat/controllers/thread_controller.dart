import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:xpider_chat/data/repositories/user/user_repository.dart';
import 'package:xpider_chat/features/chat/controllers/chat_controller.dart';
import 'package:xpider_chat/features/chat/models/chat_room_model.dart';
import 'package:xpider_chat/features/chat/models/thread_model.dart';
import '../../../data/user/user.dart';
import '../models/thread_room_model.dart';


class ThreadController extends GetxController {
  static ThreadController get instance => Get.find();

  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  RxBool isLoading = true.obs;
  RxBool imageUploading = true.obs;
  var uuid = const Uuid();
  RxList<ThreadModel> threadRoomList = <ThreadModel>[].obs;
  RxString selectedImagePath = ''.obs;



  String getThreadId(index){
    return "Thread - $index";
  }


  Future<void> addThread(UserModel receiver,
      String message, String? imgUrl, String threadName) async {

    isLoading.value = true;
    String roomId = ChatController.instance.getRoomId(receiver.id);
    final room = await db.collection("AllChats").doc(roomId).get();
    final threadCount = room.get("ThreadCount");
    print(threadCount);
    final threadId = getThreadId(threadCount);

    try {


      var sender = await UserRepository.instance.fetchUserDetails();


      var threadRoomDetails = ThreadRoomModel(
          id: threadId,
          threadName: threadName,
          lastMessage: message.toString(),
          lastMessageTime: DateTime.now().toString(),
          sender: sender,
          receiver: receiver,
          imgUrl: imgUrl
      );

      await db.collection("AllChats").doc(roomId).collection("Threads").doc(threadId).set(threadRoomDetails.toJson());

      var roomDetails = ChatRoomModel(
          id: roomId,
          threadCount: threadCount + 1,
          lastMessage: message.toString(),
          lastMessageTime: DateTime.now().toString(),
          sender: sender,
          receiver: receiver,
          imgUrl: imgUrl
      );


      await db.collection("AllChats").doc(roomId).set(roomDetails.toJson());
    } catch (e) {
      print(e);
    }
    finally {
      isLoading.value = false;
    }
  }

  Future<void> sendThreadMessage(ThreadModel thread, UserModel receiver, String? message, String? imgUrl) async {

    String roomId = ChatController.instance.getRoomId(receiver.id);

    var newThreadModel = ThreadModel(
      id: uuid.v6(),
      threadName: thread.threadName,
      lastMessageTime: DateTime.now().toString(),
      // profileImage: receiver.profilePicture,
      imageUrl: selectedImagePath.value,
      senderId: auth.currentUser!.uid,
      receiverId: receiver.id,
      senderName: auth.currentUser!.displayName.toString(),
      receiverName: receiver.fullName,
      senderMessage: message,
    );
    var sender = await UserRepository.instance.fetchUserDetails();

    await db.collection("AllChats").doc(roomId).collection("Threads").doc(thread.id)
        .collection("ThreadMessages").doc(newThreadModel.id).set(newThreadModel.toJson());


  }



  Future<List<ThreadModel>> getThreads(String roomId) async {

      final threads = await db.collection("AllChats").doc(roomId).collection(
          "Threads").get();
      final threadsList = threads.docs.map((thread) =>
          ThreadModel.fromSnapshot(thread)).toList();
      threadRoomList.assignAll(threadsList);
      return threadsList;

  }

  Stream<List<ThreadModel>> getThreadMessages (String targetUserId, String threadId){
    String roomId = ChatController.instance.getRoomId(targetUserId);

    return db.collection("AllChats").doc(roomId)
        .collection("Threads").doc(threadId).collection("ThreadMessages")
        .orderBy("LastMessageTime", descending: true)
        .snapshots().map((snapshot) => snapshot.docs.map((doc) => ThreadModel.fromSnapshot(doc)
    ).toList());
  }


}