import 'dart:math';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:xpider_chat/common/appbar/appbar.dart';
import 'package:xpider_chat/common/custom_shapes/containers/rounded_container.dart';
import 'package:xpider_chat/common/custom_shapes/containers/search_container.dart';
import 'package:xpider_chat/data/contacts/contacts_controller.dart';
import 'package:xpider_chat/data/user/user.dart';
import 'package:xpider_chat/features/chat/controllers/user_controller.dart';
import 'package:xpider_chat/features/chat/screens/groups/create_groups.dart';
import 'package:xpider_chat/features/chat/screens/contacts/add_contacts.dart';
import 'package:xpider_chat/features/chat/screens/messages/message_screen.dart';
import 'package:xpider_chat/utils/constants/colors.dart';
import 'package:xpider_chat/utils/constants/sizes.dart';
import 'package:xpider_chat/utils/helpers/helper_functions.dart';
import '../../../../common/images/circular_images.dart';
import '../../../../common/loaders/shimmer_loader.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/popups/loaders.dart';

class Contacts extends StatelessWidget {
  const Contacts({super.key});


  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    RxBool isSearchEnable = false.obs;
    final controller = Get.put(ContactsController());
    final searchName = TextEditingController();

    /// Contact Variables
    RxList <Contact> contacts = <Contact>[].obs;
    contacts.assignAll(controller.contacts);

    /// Xpider Contact Record
    List <Contact> xpiderContacts = [];
    for (var user in UserController.instance.users){
      for (var contact in controller.contacts) {
        if (user.phoneNumber == contact.phones![0].value?.replaceAll(" ", '').substring(3)){
          xpiderContacts.add(contact);

        }
      }
    }
    final userController = UserController.instance;

    List<Color> colorList = [
      Colors.red,
      Colors.green,
      Colors.brown,
      Colors.blue.shade400,
      Colors.black
    ];

    final random = Random();

    return  Scaffold(
        appBar: TAppBar(
          title: Text("Select a Contact", style: Theme.of(context).textTheme.headlineMedium,),
          actions: [
            Obx(() =>  IconButton(
              icon: isSearchEnable.value ? const Icon(Iconsax.close_circle) : const Icon(Iconsax.search_normal),
              onPressed: () {
                isSearchEnable.value = !isSearchEnable.value;
              }
            ))
          ],
        ),
        body: SingleChildScrollView(

          /// Add
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
            child: Column(
              children: [
                Obx ( () => !isSearchEnable.value ? Column(
                  children: [
                    const SizedBox(height: TSizes.spaceBtwItems),
                    InkWell(
                      onTap: () => Get.to(() => const AddContacts()),
                      child: RoundedContainer(
                        backgroundColor: TColors.darkerGrey,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RoundedContainer(
                                backgroundColor: dark? TColors.primary : Colors.indigo,
                                child: const Padding(
                                  padding: EdgeInsets.all(TSizes.defaultSpace / 1.5),
                                  child: Icon(Icons.person_add, size: TSizes.iconLg, color: TColors.white,),
                                ),
                              ),
                            ),
                            const SizedBox(width: TSizes.spaceBtwItems / 2),
                            Text("Add new Contact", style: Theme.of(context).textTheme.titleLarge!.apply(color: TColors.white))
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems / 2),
                    InkWell(
                      onTap: () => Get.to(() => const CreateGroupsScreen()),
                      child: RoundedContainer(
                        backgroundColor: TColors.darkerGrey,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RoundedContainer(
                                backgroundColor: dark? TColors.primary : Colors.indigo,
                                child: const Padding(
                                  padding: EdgeInsets.all(TSizes.defaultSpace / 1.5),
                                  child: Icon(Icons.people_alt, size: TSizes.iconLg, color: TColors.white,),
                                ),
                              ),
                            ),
                            const SizedBox(width: TSizes.spaceBtwItems / 2),
                            Text("Add new Group", style: Theme.of(context).textTheme.titleLarge!.apply(color: TColors.white))
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems / 2),
                    const Divider(),
                  ],
                ) : Column(
                  children: [
                    const SizedBox(height: TSizes.spaceBtwItems),
                    SearchBarContainer(text: "Search people...", textController: searchName,
                      onChanged: (value) async {
                        final searchesContacts = await ContactsController.instance.getContactBySearch(searchName.text);
                        contacts.clear();
                        contacts.assignAll(searchesContacts);
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                  ],
                )
                ),

                /// Contacts List
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Obx(() =>
                      controller.isLoading.value? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: contacts.length,
                          itemBuilder: (_, index) {
                            final contact = contacts[index];
                            var image = contact.avatar;


                            // final isPersonOnXpider;
                            // if(userController.users.map((user) => user.formattedPhoneNo).toString() == contact.phones![0].value!.toString()){
                            //   isPersonOnXpider = true;
                            // }
                            // else {
                            //   isPersonOnXpider = false;
                            // }
                            // print(userController.users.map((user) => user.formattedPhoneNo).toString());
                            // print(contact.phones![0].value!);
                            return Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    bool invite = true;
                                    UserModel? receiver;
                                    if (xpiderContacts.contains(contact)){
                                      for (var user in userController.users){
                                        if (user.phoneNumber == contact.phones![0].value?.replaceAll(" ", '').substring(3)){
                                          receiver = user;
                                        }
                                      }

                                        // Get.defaultDialog(
                                        //     title: "Send Invite",
                                        //     onConfirm: () {
                                        //       Loaders.customToast(message: "Invite Sent");
                                        //     },
                                        //     content: RoundedContainer(
                                        //       backgroundColor: TColors.grey,
                                        //       child: Row(
                                        //         children: [
                                        //           IconButton(onPressed: () {}, icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.black26,)),
                                        //           SizedBox(
                                        //               width: MediaQuery.of(context).size.width * .55,
                                        //               child: const Text(
                                        //                   "Hey, feeling alone? Let's find your friends and family..."
                                        //               )
                                        //           ),
                                        //         ],
                                        //       ),
                                        //     ),
                                        //     onCancel: () => () => Get.back()
                                        // );
                                      invite = false;
                                      if (!invite) {
                                        Get.to(() => MessageScreen(userModelReceiver: receiver!));
                                      }

                                    }
                                    // final chatController = ChatController.instance;
                                    // // Get RoomId
                                    // final String roomId = chatController.getRoomId();
                                    // Get.to(() => MessageScreen(name: contact.displayName!, image: image));
                                    },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: TSizes.defaultSpace / 4),
                                    child: RoundedContainer(
                                      showBorder: true,
                                      borderColor: Colors.white12,
                                      backgroundColor: Colors.blue.withOpacity(0.2),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child:
                                            Row(

                                              children: [
                                                userController.imageUploading.value
                                                    ? const ShimmerLoader(height: 80, width: 80, radius: 80)
                                                    : CircleAvatar(
                                                  backgroundColor: colorList[random.nextInt(colorList.length)],
                                                            child: (image != null && image.isNotEmpty)
                                                                ? ClipOval(child: Image.memory(image))
                                                                : Text(contact.displayName!.substring(0, 1))
                                                ),
                                                const SizedBox(width: TSizes.spaceBtwItems),
                                                Flexible(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(contact.displayName!, style: Theme.of(context).textTheme.titleLarge),
                                                          const SizedBox(width: TSizes.spaceBtwItems / 2),
                                                          if (!xpiderContacts.contains(contact))
                                                            Text("(Invite)", style: Theme.of(context).textTheme.titleMedium!.apply(color: TColors.primary))

                                                        ],
                                                      ),
                                                      Text(contact.phones![0].value!),
                                                      // isPersonOnXpider? Text("") : Text("Invite")
                                                    ],
                                                  ),
                                                ),

                                              ],
                                            ),


                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        ),
                      ),
                      const SizedBox(height: TSizes.spaceBtwSections)
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}
