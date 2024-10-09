import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xpider_chat/features/chat/models/chat_message_model.dart';

import '../../utils/formatters/formatter.dart';

class UserModel{

  final String id;
  String firstName;
  String lastName;
  final String username;
  final String email;
  String phoneNumber;
  String profilePicture;
  String about;
  List<String>? favourites;
  List<String>? pinnedChats;
  List<String>? archivedChats;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.phoneNumber,
    required this.email,
    required this.profilePicture,
    this.favourites,
    this.pinnedChats,
    this.archivedChats,
    this.about = "I am Busy"

  });

  /// Helper function to get the full name.
  String get fullName => '$firstName $lastName';

  /// Helper function to format phoneNo.
  String get formattedPhoneNo => TFormatter.formatPhoneNumber(phoneNumber);

  /// Static function to split full name
  static List <String> nameParts(fullName) => fullName.split(" ");

  /// Static function to generate username from full name
  static String generateUsername(fullName) {
    List <String> nameParts = fullName.split(" ");
    String firstName = nameParts[0].toLowerCase();
    String lastName = nameParts.length > 1 ? nameParts[1].toLowerCase() : "";

    String camelCaseUsername = '$firstName$lastName';
    String usernameWithPrefix = 'cwt_$camelCaseUsername';
    return usernameWithPrefix;
  }

  /// Static function to create an empty user model.
  static UserModel empty() => UserModel(id: '', firstName: '', lastName: '', username: '', phoneNumber: '', email: '', profilePicture: 'assets/images/network/spider.png', about: "Let's Xpider the community");

  /// Convert Model to JSON Structure for storing data in Firebase.
  toJson(){
    return {
      'Id' : id,
      'FirstName' : firstName,
      'LastName' : lastName,
      'Username' : username,
      'Email' : email,
      'PhoneNumber' : phoneNumber,
      'ProfilePicture' : profilePicture,
      'About' : about,
      'Favourites' : favourites ?? [],
      'PinnedChats' : pinnedChats ?? [],
      'ArchivedChats' : archivedChats ?? []
    };
  }

  /// Factory Method to create a UserModel from a Firebase document snapshot.
  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document){

    if (document.data() != null){
      final data = document.data()!;
    return UserModel(
        id: document.id,
        firstName: data['FirstName'] ?? '',
        lastName: data['LastName'] ?? '',
        username: data['Username'] ?? '',
        phoneNumber: data['PhoneNumber'] ?? '',
        email: data['Email'] ?? '',
        profilePicture: data['ProfilePicture'] ?? 'assets/images/user/user.png',
        about: data["About"] ?? 'I am busy',
        favourites:  List<String>.from(data['Favourites']),
        pinnedChats:  List<String>.from(data['PinnedChats']),
        archivedChats:  List<String>.from(data['ArchivedChats'])
      );
    }
    throw Exception("No such User Found");
  }

  factory UserModel.fromJson(Map<String, dynamic> document){
    final data = document;
    if(data.isEmpty) return UserModel.empty();
    return UserModel(
        id: data['Id'] ?? '',
        firstName: data['FirstName'] ?? '',
        lastName: data['LastName'] ?? '',
        username: data['Username'] ?? '',
        phoneNumber: data['PhoneNumber'] ?? '',
        email: data['Email'] ?? '',
        profilePicture: data['ProfilePicture'] ?? 'assets/images/user/user.png',
        about: data["About"] ?? 'I am busy',
        favourites:  List<String>.from(data['Favourites']),
        pinnedChats:  List<String>.from(data['PinnedChats']),
        archivedChats:  List<String>.from(data['ArchivedChats'])
    );
  }
}