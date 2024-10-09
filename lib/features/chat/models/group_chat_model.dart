import 'package:cloud_firestore/cloud_firestore.dart';
import 'group_user_model.dart';

class GroupRoomModel{
  final String id;
  final String groupName;
  final String? description;
  final String? groupProfilePicture;
  final List<GroupUserModel>? users;
  final List<GroupUserModel>? editors;
  final List<GroupUserModel> admins;
  final bool isRead;
  final bool isPinned;
  final bool isFavourite;
  final bool isArchived;
  final String createdAt;
  final GroupUserModel createdBy;
  final List<dynamic>? groupMessages;
  final String? lastMessage;
  final String? lastMessageTime;
  final String? lastMessageBy;
  final String status;
  final int unreadMessages;

  GroupRoomModel({
    required this.id,
    required this.groupName,
    this.description,
    this.groupProfilePicture,
    this.users,
    this.editors,
    required this.admins,
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
  static GroupRoomModel empty() => GroupRoomModel(id: '', groupName: 'Group', admins: [], createdAt: DateTime.now().toString(), status: '', createdBy: GroupUserModel.empty());

  /// Convert Model to JSON Structure to (upload) store in Firebase
  toJson(){
    return{
      'Id' : id,
      'GroupName' : groupName,
      'GroupProfilePicture' : groupProfilePicture,
      'GroupDescription' : description,
      'Admins' : admins.map((admin) => admin.toJson()).toList(),
      'Users' : users != null ? users!.map((user) => user.toJson()).toList() : [],
      'Editors' : editors != null ? editors!.map((user) => user.toJson()).toList() : [],
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
      admins: (data["Admins"] as List<dynamic>).map((admin)=> GroupUserModel.fromJson(admin)).toList(),
      users: (data["Users"] as List<dynamic>).map((user)=> GroupUserModel.fromJson(user)).toList(),
      editors: (data["Editors"] as List<dynamic>).map((user)=> GroupUserModel.fromJson(user)).toList(),
      createdAt: data['CreatedAt'] ?? '',
      createdBy: GroupUserModel.fromJson(data["CreatedBy"]),
      lastMessage: data['LastMessage'] ?? '',
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
      admins: (data["Admins"] as List<dynamic>).map((admin)=> GroupUserModel.fromJson(admin)).toList(),
      users: (data["Users"] as List<dynamic>).map((user)=> GroupUserModel.fromJson(user)).toList(),
      editors: (data["Editors"] as List<dynamic>).map((user)=> GroupUserModel.fromJson(user)).toList(),
      createdAt: data['CreatedAt'] ?? '',
      createdBy: GroupUserModel.fromJson(data["CreatedBy"]),
      lastMessage: data['LastMessage'] ?? '',
      lastMessageBy: data['LastMessageBy'] ?? '',
    );
  }
}