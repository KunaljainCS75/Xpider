import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xpider_chat/common/appbar/appbar.dart';
import 'package:xpider_chat/common/custom_shapes/containers/rounded_container.dart';
import 'package:xpider_chat/common/images/circular_images.dart';
import 'package:xpider_chat/features/chat/controllers/group_controller.dart';
import 'package:xpider_chat/features/chat/controllers/user_controller.dart';
import 'package:xpider_chat/features/chat/models/group_user_model.dart';
import 'package:xpider_chat/features/chat/screens/groups/create_groups.dart';
import 'package:xpider_chat/features/chat/screens/groups/widgets/list_with_heading.dart';
import 'package:xpider_chat/navigation_menu.dart';
import 'package:xpider_chat/utils/constants/colors.dart';
import 'package:xpider_chat/utils/constants/sizes.dart';
import 'package:xpider_chat/utils/helpers/helper_functions.dart';

import '../../../../common/loaders/shimmer_loader.dart';
import '../../../../data/repositories/user/user_repository.dart';
import '../../../../utils/popups/loaders.dart';
import '../contacts/contacts.dart';

class GroupFillDetailsScreen extends StatelessWidget {
  const GroupFillDetailsScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    final groupController = GroupController.instance;
    final groupMembers = groupController.groupMembers;
    final groupMemberIds = groupController.memberIds;

    Rx<String> imageUrl = "assets/images/user/group.png".obs;
    RxBool isNetworkImage = false.obs;
    RxBool isImageUploading = false.obs;


    final myProfile = UserController.instance.user.value;

    return PopScope(
      onPopInvoked: (value) {
        groupMembers.removeWhere((person) => person.id == myProfile.id);
        for (var person in groupMembers){
          if (person.position == "Admin"){
            person.position = "Member";
          }
        }
      },
      child: Scaffold(
        appBar: TAppBar(
          title: const Text("New Group Details"),
          showBackArrow: false,
          actions: [
            IconButton(onPressed: () {

              try {
                if (nameController.text.isNotEmpty) {
                  GroupController.instance.addGroup(
                      groupName: nameController.text,
                      groupProfilePicture: imageUrl.value,
                      participants: groupMembers.toList(),
                      description: descriptionController.text
                  );
                  groupMemberIds.clear();
                  groupMembers.clear();
                  Get.back();
                  Get.back();
                  Get.back();
                } else {
                  Loaders.warningSnackBar(title: "No group name",
                      message: "Write a name for your group");
                  print("${groupMembers.length}");
                }
              } catch (e) {
                rethrow;
              }
            }, icon: const RoundedContainer(
              radius: 40,
                backgroundColor: TColors.primary, height: 40, width: 40,
                child: Icon(Icons.send))),
          ],
        ),

        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: TSizes.spaceBtwItems * 2),
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    /// Group Image
                    Obx(
                      () => isImageUploading.value ?
                      const ShimmerLoader(height: 120, width: 120, radius: 120, color: Colors.blue,)
                          :  CircularImage(
                          isNetworkImage: isNetworkImage.value, fit: BoxFit.cover,
                          height: 120, width: 120,
                          image: imageUrl.value
                      )
                    ),

                    /// Edit Image Button
                    RoundedContainer(
                      radius: 100,
                      height: 35, width: 35,
                      backgroundColor: TColors.darkerGrey,
                      child: IconButton(
                        onPressed: () async {
                          final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            isImageUploading.value = true;
                            isNetworkImage.value = true;
                          }
                          final newImageUrl = await UserRepository.instance.uploadImage('Groups/Images/', image!);
                          imageUrl.value = newImageUrl;
                          isImageUploading.value = false;
                        },
                        icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      maxLength: 20,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.group),
                        labelText: "Name",
                        hintText: "Group Name...",
                        hintStyle: TextStyle(color: Colors.white24)
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    TextField(
                      controller: descriptionController,
                      maxLength: 200,
                      minLines: 1,
                      maxLines: 10,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.group),
                        labelText: "Description",
                        hintStyle: TextStyle(color: Colors.white24),
                        hintText: "Group Description...",
                      ),
                    ),
                  ],
                ),
              ),

              /// Group Admins
              ListWithHeading(
                heading: 'Admins',
                overLayColor: Colors.redAccent,
                imageUrl: "assets/images/user/admin.png", list: groupMembers.where((person) => person.position == 'Admin').toList()),

              /// Group Members
              ListWithHeading(
                heading: 'Members',
                imageUrl: "assets/images/user/admin.png",
                list: groupMembers.where((person) => person.position == "Member").toList()),
            ],
          ),
        ),


      ),
    );
  }
}

