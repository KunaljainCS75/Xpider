import 'package:cloud_firestore/cloud_firestore.dart';

class CallModel{
  final String callId;
  final String callerId;
  final String callerName;
  final String callerProfilePicture;
  final String receiverId;
  final String receiverName;
  final String receiverProfilePicture;
  String status;
  String callType;
  final String callStartTime;
  String? callEndTime;

  CallModel({
    required this.callId,
    required this.callerId,
    required this.callerName,
    required this.callerProfilePicture,
    required this.receiverId,
    required this.receiverName,
    required this.receiverProfilePicture,
    this.callType = 'audio',
    this.status = "calling",
    required this.callStartTime,
    this.callEndTime
  });

  /// Empty function
  static CallModel empty() => CallModel(callId: '', callerName: '', callerProfilePicture: '',
                                        receiverName: '', receiverProfilePicture: '', callerId: '',
                                        receiverId: '', callStartTime: '', callEndTime: '');

  /// Convert Model to JSON Structure for storing data in Firebase.
  toJson(){
    return {
      'CallId' : callId,
      'CallerName' : callerName,
      'CallerId' : callerId,
      'CallerProfilePicture' : callerProfilePicture,
      'ReceiverId' : receiverId,
      'ReceiverName' : receiverName,
      'ReceiverProfilePicture' : receiverProfilePicture,
      'Status' : status,
      'CallType' : callType,
      'CallStartTime' : callStartTime,
      'CallEndTime' : callEndTime
    };
  }

  /// Factory Method to create a UserModel from a Firebase document snapshot.
  factory CallModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document){

    if (document.data() != null){
      final data = document.data()!;
      return CallModel(
          callId : data['CallId'],
          callerId: data['CallerId'] ?? '',
          callerName: data['CallerName'] ?? '',
          callerProfilePicture: data['CallerProfilePicture'] ?? '',
          receiverId: data['ReceiverId'] ?? '',
          receiverName: data['ReceiverName'] ?? '',
          receiverProfilePicture: data['ReceiverProfilePicture'] ?? '',
          status: data["Status"] ?? 'dialing',
          callType: data["CallType"] ?? 'audio',
          callStartTime: data['CallStartTime'] ?? '',
          callEndTime: data['CallEndTime'] ?? '',
      );
    }
    throw Exception("No such call Found");
  }

  factory CallModel.fromJson(Map<String, dynamic> document){
    final data = document;
    if(data.isEmpty) return CallModel.empty();
    return CallModel(
        callId : data['CallId'],
        callerId: data['CallerId'] ?? '',
        callerName: data['CallerName'] ?? '',
        callerProfilePicture: data['CallerProfilePicture'] ?? '',
        receiverId: data['ReceiverId'] ?? '',
        receiverName: data['ReceiverName'] ?? '',
        receiverProfilePicture: data['ReceiverProfilePicture'] ?? '',
        status: data["Status"] ?? 'dialing',
        callType: data["CallType"] ?? 'audio',
        callStartTime: data['CallStartTime'] ?? '',
        callEndTime: data['CallEndTime'] ?? '',
    );
  }
}