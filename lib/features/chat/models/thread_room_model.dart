import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xpider_chat/data/user/user.dart';

class ThreadRoomModel{
  final String id;
  final String threadName;
  final UserModel sender;
  final UserModel receiver;
  bool isFavourite;
  bool isPinned;
  bool isRead;
  final String? lastMessageTime;
  final String? lastMessage;
  final String? imgUrl;
  final int? unreadMessages;

  ThreadRoomModel({
    required this.id,
    required this.threadName,
    required this.lastMessageTime,
    required this.sender,
    required this.receiver,
    this.lastMessage,
    this.isPinned = false,
    this.isRead = true,
    this.isFavourite = false,
    this.unreadMessages = 0,
    this.imgUrl = ""
  });

  /// Empty Helper Function
  static ThreadRoomModel empty() => ThreadRoomModel(id: '', lastMessageTime: '23:59', sender: UserModel.empty(), receiver: UserModel.empty(), threadName: '');

  /// Convert Model to JSON Structure to (upload) store in Firebase
  toJson(){
    return{
      'Id' : id,
      'Sender' : sender.toJson(),
      'Receiver' : receiver.toJson(),
      'IsPinned' : isPinned,
      'IsRead' : isRead,
      'ThreadName' : threadName,
      'UnreadMessages' : unreadMessages,
      'LastMessageTime' : lastMessageTime,
      'IsFavourite' : isFavourite,
      'LastMessage' : lastMessage,
      'ImageUrl' : imgUrl
    };
  }

  /// Map JSON Oriented document snapshot from FireBase to UserModel
  factory ThreadRoomModel.fromJson(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    if (data.isEmpty) return ThreadRoomModel.empty();
    return ThreadRoomModel(
      id: data['Id'] ?? '',
      threadName: data['ThreadName'] ?? '',
      sender: UserModel.fromJson(data['Sender']),
      receiver: UserModel.fromJson(data['Receiver']),
      unreadMessages: data['UnreadMessages'] ?? 0,
      isPinned: data['IsPinned'] ?? false,
      isRead: data['IsRead'] ?? true,
      isFavourite: data['IsFavourite'] ?? true,
      lastMessageTime: data['LastMessageTime'] ?? '',
      lastMessage: data["LastMessage"] ?? '',
      imgUrl: data["ImageUrl"] ?? '',
    );
  }
}