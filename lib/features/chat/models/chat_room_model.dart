import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xpider_chat/data/user/user.dart';

class ChatRoomModel{
  final String id;
  final UserModel sender;
  final UserModel receiver;
  bool isFavourite;
  bool isPinned;
  bool isArchived;
  final int threadCount;
  bool isRead;
  final String? lastMessageTime;
  final String? lastMessage;
  final String? imgUrl;
  final int? unreadMessages;

  ChatRoomModel({
    required this.id,
    required this.lastMessageTime,
    required this.sender,
    required this.receiver,
    this.lastMessage,
    this.isPinned = false,
    this.isRead = true,
    this.isArchived = false,
    this.threadCount = 0,
    this.isFavourite = false,
    this.unreadMessages = 0,
    this.imgUrl = ""
  });

  /// Empty Helper Function
  static ChatRoomModel empty() => ChatRoomModel(id: '', lastMessageTime: '23:59', sender: UserModel.empty(), receiver: UserModel.empty());

  /// Convert Model to JSON Structure to (upload) store in Firebase
  toJson(){
    return{
      'Id' : id,
      'Sender' : sender.toJson(),
      'Receiver' : receiver.toJson(),
      'IsPinned' : isPinned,
      'IsRead' : isRead,
      'IsArchived' : isArchived,
      'ThreadCount' : threadCount,
      'UnreadMessages' : unreadMessages,
      'LastMessageTime' : lastMessageTime,
      'IsFavourite' : isFavourite,
      'LastMessage' : lastMessage,
      'ImageUrl' : imgUrl
    };
  }

  /// Map JSON Oriented document snapshot from FireBase to UserModel
  factory ChatRoomModel.fromJson(DocumentSnapshot<Map<String, dynamic>> document) {

    if (document.data() == null) return ChatRoomModel.empty();
    final data = document.data()!;
    return ChatRoomModel(
      id: data['Id'] ?? '',
      isArchived: data['IsArchived'] ?? false,
      threadCount: data['ThreadCount'] ?? 0,
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