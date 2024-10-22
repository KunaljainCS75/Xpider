import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/constants/image_strings.dart';

class StatusUserModel{
  final String senderName;
  final String senderProfilePicture;
  int seenIndex;
  final String imageUrl;
  final String lastUpdateTime;

  StatusUserModel({
    required this.senderName,
    required this.senderProfilePicture,
    required this.imageUrl,
    required this.seenIndex,
    required this.lastUpdateTime
  });

  toJson() {
    return {
      "SenderName" : senderName,
      "SeenIndex" : seenIndex,
      "SenderProfilePicture" : senderProfilePicture,
      "ImageUrl" : imageUrl,
      "LastUpdateTime" : lastUpdateTime
    };
  }

  /// Empty
  static StatusUserModel empty() => StatusUserModel(senderName: '', imageUrl: '', seenIndex: 0, lastUpdateTime: '', senderProfilePicture: TImages.user);

  /// Map JSON Oriented document snapshot from FireBase to UserModel
  factory StatusUserModel.fromJson(Map<String, dynamic> document) {
    final data = document;
    if (data.isEmpty) return StatusUserModel.empty();
    return StatusUserModel(
        senderName: data["SenderName"] ?? '',
        senderProfilePicture: data["SenderProfilePicture"],
        imageUrl: data["ImageUrl"] ?? '',
        seenIndex: data["SeenIndex"] ?? 0,
        lastUpdateTime: data["LastUpdateTime"] ?? '',
    );
  }

  /// Map JSON Oriented document snapshot from FireBase to UserModel
  factory StatusUserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return StatusUserModel(
        senderName: data["SenderName"] ?? '',
        senderProfilePicture: data["SenderProfilePicture"],
        imageUrl: data["ImageUrl"] ?? '',
        seenIndex: data["SeenIndex"] ?? 0,
        lastUpdateTime: data["LastUpdateTime"] ?? '',
      );
    }
    throw Exception("No such UserStatus Found");
  }
}