import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel{
  final String id;
  final String chatName;
  final dynamic senderMessage;
  final String? receiverMessage;
  final String? senderName;
  final String? receiverName;
  final String? imageUrl;
  final String senderId;
  final String receiverId;
  final String profileImage;
  bool isFavourite;
  bool isPinned;
  bool isRead;
  final String lastMessageTime;
  final int? unreadMessages;
  final List<dynamic>? chatMessages;

  ChatMessageModel({
    required this.id,
    required this.chatName,
    required this.lastMessageTime,
    required this.profileImage,
    required this.senderId,
    required this.receiverId,
    this.isPinned = false,
    this.imageUrl,
    this.isRead = true,
    this.isFavourite = false,
    this.senderMessage,
    this.receiverMessage,
    this.senderName,
    this.receiverName,
    this.unreadMessages = 0,
    this.chatMessages
  });

  /// Empty Helper Function
  static ChatMessageModel empty() => ChatMessageModel(id: '', chatName: "Nobita", lastMessageTime: "11:59", profileImage: "assets/images/network/spider.png", senderId: '', receiverId: '');

  /// Convert Model to JSON Structure to (upload) store in Firebase
  toJson(){
    return{
      'Id' : id,
      'ChatName' : chatName,
      'ProfileImage' : profileImage,
      'SenderMessage' : senderMessage,
      'SenderName' : senderName,
      'ReceiverMessage' : receiverName,
      'ReceiverName' : receiverName,
      'IsPinned' : isPinned,
      'IsRead' : isRead,
      'ImageUrl' : imageUrl,
      'UnreadMessages' : unreadMessages,
      'LastMessageTime' : lastMessageTime,
      'IsFavourite' : isFavourite,
      'ChatMessages' : chatMessages,
      'SenderId' : senderId,
      'ReceiverId' : receiverId
    };
  }

  /// Map JSON Oriented document snapshot from FireBase to UserModel
  factory ChatMessageModel.fromJson(Map<String, dynamic> document) {
    final data = document;
    if (data.isEmpty) return ChatMessageModel.empty();
    return ChatMessageModel(
      id: data['Id'] ?? '',
      chatName: data['ChatName'] ?? '',
      profileImage: data['ProfileImage'] ?? '',
      senderMessage: data['SenderMessage'] ?? '',
      senderName: data['SenderName'] ?? '',
      receiverName: data['ReceiverName'] ?? '',
      receiverMessage: data['ReceiverMessage'] ?? '',
      unreadMessages: data['UnreadMessages'] ?? 0,
      isPinned: data['IsPinned'] ?? false,
      isRead: data['IsRead'] ?? true,
      imageUrl: data['ImageUrl'] ?? '',
      isFavourite: data['IsFavourite'] ?? true,
      lastMessageTime: data['LastMessageTime'] ?? "",
      chatMessages: data["ChatMessages"] ?? [],
      senderId: data["SenderId"] ?? '',
      receiverId: data["ReceiverId"] ?? '',
    );
  }

  factory ChatMessageModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    if (data.isEmpty) return ChatMessageModel.empty();
    return ChatMessageModel(
      id: data['Id'] ?? '',
      chatName: data['ChatName'] ?? '',
      profileImage: data['ProfileImage'] ?? '',
      senderMessage: data['SenderMessage'] ?? '',
      senderName: data['SenderName'] ?? '',
      receiverName: data['ReceiverName'] ?? '',
      receiverMessage: data['ReceiverMessage'] ?? '',
      unreadMessages: data['UnreadMessages'] ?? 0,
      isPinned: data['IsPinned'] ?? false,
      isRead: data['IsRead'] ?? true,
      imageUrl: data['ImageUrl'] ?? '',
      isFavourite: data['IsFavourite'] ?? true,
      lastMessageTime: data['LastMessageTime'] ?? "",
      chatMessages: data["ChatMessages"] ?? [],
      senderId: data["SenderId"] ?? '',
      receiverId: data["ReceiverId"] ?? '',
    );
  }
}