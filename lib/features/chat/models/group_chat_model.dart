import 'package:cloud_firestore/cloud_firestore.dart';
import 'group_user_model.dart';

class GroupRoomModel{
  final String id;
  String groupName;
  String? description;
  String? groupProfilePicture;
  List<GroupUserModel> participants;
  bool isRead;
  bool isPinned;
  bool isFavourite;
  bool isArchived;
  final String createdAt;
  final GroupUserModel createdBy;
  List<dynamic>? groupMessages;
  String? lastMessage;
  String? lastMessageTime;
  String? lastMessageBy;
  String status;
  int unreadMessages;

  GroupRoomModel({
    required this.id,
    required this.groupName,
    this.description,
    this.groupProfilePicture,
    required this.participants,
    required this.createdAt,
    required this.createdBy,
    this.groupMessages,
    this.isPinned = false,
    this.isRead = true,
    this.isFavourite = false,
    this.isArchived = false,
    required this.status,
    this.lastMessage,
    this.unreadMessages = 0,
    this.lastMessageTime = '',
    this.lastMessageBy = ''
  });

  /// Empty Model
  static GroupRoomModel empty() => GroupRoomModel(id: '', groupName: 'Group', createdAt: DateTime.now().toString(), status: '', createdBy: GroupUserModel.empty(), participants: []);

  /// Convert Model to JSON Structure to (upload) store in Firebase
  toJson(){
    return{
      'Id' : id,
      'GroupName' : groupName,
      'GroupProfilePicture' : groupProfilePicture,
      'GroupDescription' : description,
      'Participants' : participants.map((user) => user.toJson()).toList(),
      'IsPinned' : isPinned,
      'IsRead' : isRead,
      'IsArchived' : isArchived,
      'CreatedBy' : createdBy.toJson(),
      'UnreadMessages' : unreadMessages,
      'LastMessageTime' : lastMessageTime,
      'IsFavourite' : isFavourite,
      'GroupMessages' : groupMessages,
      'LastMessageBy' : lastMessageBy,
      'LastMessage' : lastMessage,
      'Status' : status,
      'CreatedAt' : createdAt
    };
  }

  /// Map JSON Oriented document snapshot from FireBase to GroupUserModel
  factory GroupRoomModel.fromJson(Map<String, dynamic> document) {
    final data = document;
    if (data.isEmpty) return GroupRoomModel.empty();
    return GroupRoomModel(
      id: data['Id'] ?? '',
      groupName: data['GroupName'] ?? '',
      groupProfilePicture: data['GroupProfilePicture'] ?? '',
      description: data['GroupDescription'] ?? 'No description has been provided',
      status: data['Status'] ?? 'Active',
      unreadMessages: data['UnreadMessages'] ?? 0,
      isPinned: data['IsPinned'] ?? false,
      isRead: data['IsRead'] ?? true,
      isArchived: data['IsArchived'] ?? false,
      isFavourite: data['IsFavourite'] ?? true,
      lastMessageTime: data['LastMessageTime'] ?? "",
      groupMessages: data["GroupMessages"] ?? [],
      participants: (data["Participants"] as List<dynamic>).map((user)=> GroupUserModel.fromJson(user)).toList(),
      createdAt: data['CreatedAt'] ?? '',
      createdBy: GroupUserModel.fromJson(data["CreatedBy"]),
      lastMessage: data['LastMessage'] ?? 'group_created',
      lastMessageBy: data['LastMessageBy'] ?? '',
    );
  }

  /// Map JSON Oriented document snapshot from FireBase to GroupUserModel
  factory GroupRoomModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    if (data.isEmpty) return GroupRoomModel.empty();
    return GroupRoomModel(
      id: data['Id'] ?? '',
      groupName: data['GroupName'] ?? '',
      groupProfilePicture: data['GroupProfilePicture'] ?? '',
      description: data['GroupDescription'] ?? 'No description has been provided',
      status: data['Status'] ?? 'Active',
      unreadMessages: data['UnreadMessages'] ?? 0,
      isPinned: data['IsPinned'] ?? false,
      isRead: data['IsRead'] ?? true,
      isArchived: data['IsArchived'] ?? false,
      isFavourite: data['IsFavourite'] ?? true,
      lastMessageTime: data['LastMessageTime'] ?? "",
      groupMessages: data["GroupMessages"] ?? [],
      participants: (data["Participants"] as List<dynamic>).map((user)=> GroupUserModel.fromJson(user)).toList(),
      createdAt: data['CreatedAt'] ?? '',
      createdBy: GroupUserModel.fromJson(data["CreatedBy"]),
      lastMessage: data['LastMessage'] ?? 'group_created',
      lastMessageBy: data['LastMessageBy'] ?? '',
    );
  }
}