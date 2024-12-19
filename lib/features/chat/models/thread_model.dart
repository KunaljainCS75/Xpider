import 'package:cloud_firestore/cloud_firestore.dart';

class ThreadMessage{
  final String? id;
  final String threadName;
  final String? senderMessage;
  // // final ThreadMessage? thread;
  // final String? receiverMessage;
  final String? senderName;
  final String? receiverName;
  final String? imageUrl;
  final String senderId;
  final String receiverId;
  // final String profileImage;
  // bool isFavourite;
  // bool isPinned;
  // bool isRead;
  final String lastMessageTime;
  final int? unreadMessages;
  final int threadCount;
  final List<dynamic>? threadMessages;

  ThreadMessage({
    required this.id,
    required this.threadName,
    required this.lastMessageTime,
    // required this.profileImage,
    required this.senderId,
    required this.receiverId,
    // this.isPinned = false,
    // // this.thread,
    this.imageUrl,
    // this.isRead = true,
    // this.isFavourite = false,
    this.senderMessage,
    this.threadCount = 0,
    // this.receiverMessage,
    this.senderName,
    this.receiverName,
    this.unreadMessages = 0,
    this.threadMessages
  });

  /// Empty Helper Function
  static ThreadMessage empty() => ThreadMessage(id: 'example',lastMessageTime: '', senderId: '', receiverId: '', threadName: '');

  /// Convert Model to JSON Structure to (upload) store in Firebase
  toJson(){
    return{
      'Id' : id,
      'ThreadName' : threadName,
      // 'ProfileImage' : profileImage,
      'SenderMessage' : senderMessage,
      'SenderName' : senderName,
      // 'ReceiverMessage' : receiverName,
      'ReceiverName' : receiverName,
      // // 'Thread' : thread!.toJson(),
      // 'IsPinned' : isPinned,
      // 'IsRead' : isRead,
      'ImageUrl' : imageUrl,
      'UnreadMessages' : unreadMessages,
      'LastMessageTime' : lastMessageTime,
      'ThreadCount' : threadCount,
      // 'IsFavourite' : isFavourite,
      'ThreadMessages' : threadMessages,
      'SenderId' : senderId,
      'ReceiverId' : receiverId
    };
  }

  /// Map JSON Oriented document snapshot from FireBase to UserModel
  factory ThreadMessage.fromJson(Map<String, dynamic> document) {
    final data = document;
    if (data.isEmpty) return ThreadMessage.empty();
    return ThreadMessage(
      id: data['Id'] ?? 'example',
      threadName: data['ThreadName'] ?? '',
      // thread: ThreadMessage.fromJson(data["Thread"]),
      // profileImage: data['ProfileImage'] ?? '',
      threadCount: data["ThreadCount"] ?? 0,
      senderMessage: data['SenderMessage'] ?? '',
      senderName: data['SenderName'] ?? '',
      receiverName: data['ReceiverName'] ?? '',
      // receiverMessage: data['ReceiverMessage'] ?? '',
      unreadMessages: data['UnreadMessages'] ?? 0,
      // isPinned: data['IsPinned'] ?? false,
      // isRead: data['IsRead'] ?? true,
      imageUrl: data['ImageUrl'] ?? '',
      // isFavourite: data['IsFavourite'] ?? true,
      lastMessageTime: data['LastMessageTime'] ?? "",
      threadMessages: data["ThreadMessages"] ?? [],
      senderId: data["SenderId"] ?? '',
      receiverId: data["ReceiverId"] ?? '',
    );


  }

  /// Map JSON Oriented document snapshot from FireBase to UserModel
  factory ThreadMessage.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    if (data.isEmpty) return ThreadMessage.empty();
    return ThreadMessage(
      id: data['Id'] ?? 'example',
      threadName: data['ThreadName'] ?? '',
      // thread: ThreadMessage.fromJson(data["Thread"]),
      // profileImage: data['ProfileImage'] ?? '',
      senderMessage: data['SenderMessage'] ?? '',
      senderName: data['SenderName'] ?? '',
      receiverName: data['ReceiverName'] ?? '',
      // receiverMessage: data['ReceiverMessage'] ?? '',
      unreadMessages: data['UnreadMessages'] ?? 0,
      // isPinned: data['IsPinned'] ?? false,
      // isRead: data['IsRead'] ?? true,
      imageUrl: data['ImageUrl'] ?? '',
      threadCount: data["ThreadCount"] ?? 0,
      // isFavourite: data['IsFavourite'] ?? true,
      lastMessageTime: data['LastMessageTime'] ?? "",
      threadMessages: data["ThreadMessages"] ?? [],
      senderId: data["SenderId"] ?? '',
      receiverId: data["ReceiverId"] ?? '',
    );
  }
}