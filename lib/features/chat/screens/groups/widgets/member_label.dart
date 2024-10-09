import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:xpider_chat/data/user/user.dart';
import 'package:xpider_chat/features/chat/controllers/group_controller.dart';
import '../../../../../common/custom_shapes/containers/rounded_container.dart';
import '../../../../../common/images/circular_images.dart';
import '../../../../../utils/popups/loaders.dart';
import '../../../models/group_user_model.dart';

class MemberLabel extends StatelessWidget {
  const
  MemberLabel({
    super.key, 
    required this.user,
    this.isRemoveButton = true,
    this.defaultAdmin = false
  });

  final GroupUserModel user;
  final bool isRemoveButton, defaultAdmin;
  @override
  Widget build(BuildContext context) {
    final groupMembers = GroupController.instance.groupMembers;
    final groupAdmins = GroupController.instance.groupAdmins;
    final memberIds = GroupController.instance.memberIds;
    RxBool isAdmin = false.obs;
    groupAdmins.clear();

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [

              /// DP Image Container
             Obx(
               () => InkWell(
                    borderRadius: BorderRadius.circular(100),
                    onTap: (){
                      if (!defaultAdmin) {
                        if (groupMembers.indexOf(user) <= 3) {
                          isAdmin.value = !isAdmin.value;
                          if (isAdmin.value) {
                            groupAdmins.add(user);
                            GroupController.instance.adminSize++;
                            // GroupController.instance.groupMembers.removeWhere((person) => person.id == user.id);
                            // GroupController.instance.size--;
                          } else {
                            groupAdmins.removeWhere((person) =>
                            person.id == user.id);
                            GroupController.instance.adminSize--;
                            // groupMembers.add(user);
                            // GroupController.instance.size++;
                          }
                        }
                        print(groupAdmins.length);
                        print(groupMembers.length);
                      } else {
                        Loaders.customToast(message: "You will be Admin by default");
                      }
                    },
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        RoundedContainer(
                          radius: 50,
                          backgroundColor:   groupMembers.indexOf(user) <= 3 && (isAdmin.value || defaultAdmin) ? Colors.redAccent : Colors.white24,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularImage(image: user.profilePicture, isNetworkImage: true),
                          ),
                        ),
                        groupMembers.indexOf(user) <= 3 && (isAdmin.value || defaultAdmin)
                            ? const CircularImage(image: "assets/images/user/admin.png",
                                                  height: 25, width: 25,
                                                  backgroundColor: Colors.white, overLayColor: Colors.redAccent)
                            : const SizedBox()
                      ],
                    ),
                  ),
             ),


              /// Remove Member Button
              isRemoveButton ? InkWell(
                onTap: () {
                  GroupController.instance.size--;
                  memberIds.remove(user.id);
                  groupMembers.removeWhere((person) => person.id == user.id);
                },
                child: RoundedContainer(
                  height: 25,
                  width: 25,
                  backgroundColor: Colors.white, child: Icon(Icons.remove_circle, color: Colors.black.withOpacity(0.8))),
              ) : const SizedBox(),
            ],
          ),
        ),

        /// Name Label
        RoundedContainer(
            backgroundColor: Colors.black.withOpacity(0.8),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(user.fullName),
            ))
      ],
    );
  }
}