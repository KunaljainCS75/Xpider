
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:xpider_chat/common/appbar/appbar.dart';
import 'package:xpider_chat/common/texts/date_time_tag.dart';
import 'package:xpider_chat/data/user/user.dart';
import 'package:xpider_chat/utils/constants/sizes.dart';
import 'package:xpider_chat/utils/helpers/helper_functions.dart';
import '../../../../common/custom_shapes/containers/rounded_container.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/chat_message_model.dart';
import '../messages/widgets/chat_bubble.dart';

class CalenderScreen extends StatelessWidget {
  const CalenderScreen({super.key, required this.userModelReceiver});

  final UserModel userModelReceiver;
  @override
  Widget build(BuildContext context) {
    bool isEmpty = true;
    final chatController = ChatController.instance;
    final userController = UserController.instance;
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: const TAppBar(
        title: Text("Calender Messages"),
      ),
      body:  Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: RoundedContainer(
                borderColor: TColors.darkerGrey,
                showBorder: true,
                backgroundColor: Colors.transparent,
                child:  Obx(
                      () => TableCalendar(
                      locale: "en_US",
                      rowHeight: 43,
                      onDaySelected: (selectedDay, focusedDay) {
                        isEmpty = true;
                        chatController.onDaySelected(selectedDay, focusedDay);
                      },
                      availableGestures: AvailableGestures.all,
                      selectedDayPredicate: (day) => isSameDay(chatController.selectedDay.value, day),
                      headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                      focusedDay: chatController.focusedDay.value,
                      firstDay: DateTime.utc(2024, 7, 16),
                      lastDay: DateTime.utc(2075, 7, 16),
                    ),
                  ),
              ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
            child: Divider(thickness: 2),
          ),
          Flexible(
            child: StreamBuilder<List<ChatMessageModel>>(
                stream: chatController.getMessages(userModelReceiver.id),
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if(snapshot.hasError || snapshot.data == null){
                    return const Center(child: Text("No messages"));
                  }
                  else {
                    return  ListView.builder(
                        reverse: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final message = snapshot.data![index];
                          final encryptedMessageString = snapshot.data![index].senderMessage;
                          final encryptedMessage = userController.stringToEncrypted(encryptedMessageString);

                          return Obx(() {

                            if (message.lastMessageTime.substring(0, 10) == chatController.selectedDay.value.toString().substring(0, 10)) {
                              isEmpty = false;
                              return ChatBubble(
                                message: userController.encryptor.decrypt(encryptedMessage, iv: userController.iv),
                                imageUrl: message.imageUrl!,
                                // isThread: message.thread != ThreadModel.empty(),
                                time: DateFormat("hh:mm a").format(DateTime.parse(message.lastMessageTime)),
                                status: Status.read.toString(),
                                senderName: message.senderName!,
                                isRead: true,
                                isComing: !(chatController.auth.currentUser!
                                    .uid == message.senderId),
                              );
                            } else if (isEmpty)  {
                              isEmpty = false;
                                return Column(
                                  children: [
                                      RoundedContainer(
                                      backgroundColor: Colors.transparent,
                                      showBorder: true,
                                      borderColor: Colors.redAccent,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                              Text("See above for Messages found on Date:",style: Theme.of(context).textTheme.titleMedium),
                                            Text(DateFormat("d MMMM, yyyy").format(chatController.selectedDay.value)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: THelperFunctions.screenHeight() * .25)
                                  ],
                                );
                            }else {
                              return const SizedBox();
                            }
                          });

                        },
                    );
                  }
                }

            ),
          ),
        ],
      ),
    );
  }
}
