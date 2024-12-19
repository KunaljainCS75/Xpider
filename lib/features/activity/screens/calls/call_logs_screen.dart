import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';
import 'package:xpider_chat/common/images/circular_images.dart';
import 'package:xpider_chat/features/chat/controllers/call_controller.dart';
import 'package:xpider_chat/features/chat/controllers/user_controller.dart';

import '../../../../common/custom_shapes/containers/rounded_container.dart';
import '../../../../utils/constants/sizes.dart';

class CallLogs extends StatelessWidget {
  const CallLogs({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final callController = CallController.instance;
    // print(callController.callLogs[0].callerName);
    print(UserController.instance.user.value.fullName);
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: TSizes.md, vertical: 0),
      child: Obx(
          () => (callController.callLogs.isNotEmpty) ? ListView.separated(
            shrinkWrap: true,
            separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems * 1.5),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: callController.callLogs.length,
            itemBuilder: (_, index) {

              final call = callController.callLogs[index];
              DateTime startTime = DateTime.parse(call.callStartTime);
              DateTime endTime = DateTime.parse(call.callEndTime!);

              var timeElapsed = endTime.difference(startTime);
              var duration = [
                timeElapsed.inHours,
                timeElapsed.inMinutes,
                timeElapsed.inSeconds
              ];

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircularImage(
                        height: 50,
                        width: 50,
                        image: call.receiverProfilePicture,
                        isNetworkImage: true,
                      ),
                      const SizedBox(width: TSizes.spaceBtwItems * 2),

                      if (call.callerName == UserController.instance.user.value.fullName)
                        Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(call.receiverName, style: Theme.of(context).textTheme.titleSmall!.apply(fontSizeFactor: 1.2)),
                          Text(DateFormat('MMMM d, yyyy, hh:mm a').format(startTime)),
                          Row(
                            children: [
                              const Text("Call duration: ", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
                              if (duration[0] != 0)
                                Text("${duration[0]} hr"),
                              if (duration[1] != 0)
                                Text("${duration[1]} min"),
                              if (duration[2] != 0)
                                Text("${duration[2]} sec"),
                            ],
                          )
                        ],
                      ),
                      if (call.callerName != UserController.instance.user.value.fullName)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(call.callerName, style: Theme.of(context).textTheme.titleSmall!.apply(fontSizeFactor: 1.2)),
                            Text(DateFormat('MMMM d, yyyy, hh:mm a').format(startTime)),
                            Row(
                              children: [
                                const Text("Call duration: ", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
                                if (duration[0] != 0)
                                  Text("${duration[0]} hr"),
                                if (duration[1] != 0)
                                  Text("${duration[1]} min"),
                                if (duration[2] != 0)
                                  Text("${duration[2]} sec"),
                              ],
                            )
                          ],
                        ),
                    ],
                  ),
                  if (call.callType == "audio")
                    Icon(Icons.phone),
                  if (call.callType == "video")
                    Icon(Icons.videocam),
                  (call.callerName == UserController.instance.user.value.fullName)
                      ? const RoundedContainer(backgroundColor: Colors.green,child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.call_made_sharp),
                      ))
                      : const RoundedContainer(backgroundColor: Colors.blue, child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.call_received),
                      ))
                ],
              );
            }
        ) : SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Center(child: Text("Call logs are empty", style: Theme.of(context).textTheme.titleLarge)))
      )
    );
  }
}