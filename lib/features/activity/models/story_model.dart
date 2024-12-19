import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StoryModel{
  final String? captions;
  final int? color;
  final String? imageUrl;
  final String type;
  final String createdAt;
  
  StoryModel({
    this.captions,
    this.color,
    this.imageUrl,
    required this.type,
    required this.createdAt
  });
  
  toJson() {
    return {
      "Captions" : captions,
      "Color" : color,
      "ImageUrl" : imageUrl,
      "Type" : type,
      "CreatedAt" : createdAt
    };
  }

  /// Empty
  static StoryModel empty() => StoryModel(type: "Image", createdAt: "");

  /// Map JSON Oriented document snapshot from FireBase to UserModel
  factory StoryModel.fromJson(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    if (data.isEmpty) return StoryModel.empty();
    return StoryModel(
      captions: data["Captions"] ?? '',
      imageUrl: data["ImageUrl"] ?? '',
      color: data["Color"] ?? 0,
      createdAt: data["CreatedAt"] ?? '',
      type: data["Type"] ?? ''
    );
  }
}