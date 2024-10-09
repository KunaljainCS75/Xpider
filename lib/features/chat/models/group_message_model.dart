import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMessageModel{
  final String id;
  final String groupName;
  final dynamic senderMessage;
  final String? senderName;
  final String? senderUserName;
  final String? senderPhoneNo;
  final String? imageUrl;
  final String senderId;
  final String profileImage;
  bool isFavourite;
  bool isPinned;
  bool isRead;
  final String lastMessageTime;
  final int? unreadMessages;
  final List<dynamic>? groupMessages;

  GroupMessageModel({
    required this.id,
    required this.groupName,
    required this.lastMessageTime,
    required this.profileImage,
    required this.senderPhoneNo,
    required this.senderUserName,
    required this.senderId,
    this.isPinned = false,
    this.imageUrl,
    this.isRead = true,
    this.isFavourite = false,
    this.senderMessage,
    this.senderName,
    this.unreadMessages = 0,
    this.groupMessages
  });

  /// Empty Helper Function
  static GroupMessageModel empty() => GroupMessageModel(id: '', groupName: "Nobita", lastMessageTime: "11:59", profileImage: "assets/images/network/spider.png", senderId: '', senderPhoneNo: '', senderUserName: '');

  /// Convert Model to JSON Structure to (upload) store in Firebase
  toJson(){
    return{
      'Id' : id,
      'GroupName' : groupName,
      'SenderPhoneNo' : senderPhoneNo,
      'SenderUserName' : senderUserName,
      'ProfileImage' : profileImage,
      'SenderMessage' : senderMessage,
      'SenderName' : senderName,
      'IsPinned' : isPinned,
      'IsRead' : isRead,
      'ImageUrl' : imageUrl,
      'UnreadMessages' : unreadMessages,
      'LastMessageTime' : lastMessageTime,
      'IsFavourite' : isFavourite,
      'GroupMessages' : groupMessages,
      'SenderId' : senderId,
    };
  }

  /// Map JSON Oriented document snapshot from FireBase to UserModel
  factory GroupMessageModel.fromJson(Map<String, dynamic> document) {
    final data = document;
    if (data.isEmpty) return GroupMessageModel.empty();
    return GroupMessageModel(
      id: data['Id'] ?? '',
      groupName: data['GroupName'] ?? '',
      profileImage: data['ProfileImage'] ?? '',
      senderMessage: data['SenderMessage'] ?? '',
      senderName: data['SenderName'] ?? '',
      senderPhoneNo: data['SenderPhoneNo'] ?? '',
      senderUserName: data['SenderUserName'],
      unreadMessages: data['UnreadMessages'] ?? 0,
      isPinned: data['IsPinned'] ?? false,
      isRead: data['IsRead'] ?? true,
      imageUrl: data['ImageUrl'] ?? '',
      isFavourite: data['IsFavourite'] ?? true,
      lastMessageTime: data['LastMessageTime'] ?? "",
      groupMessages: data["GroupMessages"] ?? [],
      senderId: data["SenderId"] ?? '',
    );
  }

  factory GroupMessageModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    if (data.isEmpty) return GroupMessageModel.empty();
    return GroupMessageModel(
      id: data['Id'] ?? '',
      groupName: data['GroupName'] ?? '',
      profileImage: data['ProfileImage'] ?? '',
      senderMessage: data['SenderMessage'] ?? '',
      senderName: data['SenderName'] ?? '',
      senderPhoneNo: data['SenderPhoneNo'] ?? '',
      senderUserName: data['SenderUserName'],
      unreadMessages: data['UnreadMessages'] ?? 0,
      isPinned: data['IsPinned'] ?? false,
      isRead: data['IsRead'] ?? true,
      imageUrl: data['ImageUrl'] ?? '',
      isFavourite: data['IsFavourite'] ?? true,
      lastMessageTime: data['LastMessageTime'] ?? "",
      groupMessages: data["GroupMessages"] ?? [],
      senderId: data["SenderId"] ?? '',
    );
  }
}