

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:xpider_chat/common/sort/sort_options.dart';
import 'package:xpider_chat/features/chat/controllers/call_controller.dart';
import 'package:xpider_chat/features/chat/models/chat_room_model.dart';
import 'package:xpider_chat/features/chat/screens/chat_section/widgets/home_appbar.dart';
import 'package:xpider_chat/features/chat/screens/chat_section/widgets/single_chat.dart';
import 'package:xpider_chat/features/chat/screens/messages/message_screen.dart';
import '../../../../common/custom_shapes/containers/primary_header_container.dart';
import '../../../../common/custom_shapes/containers/rounded_container.dart';
import '../../../../common/custom_shapes/containers/search_container.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/user_controller.dart';



class ChatSectionScreen extends StatelessWidget {
  const ChatSectionScreen({super.key});


  @override
  Widget build(BuildContext context) {

    UserController.instance.getAllPinnedChats();
    UserController.instance.getAllArchivedChats();
    UserController.instance.getAllFavouriteChats();

    final controller = Get.put(ChatController());
    final dark = THelperFunctions.isDarkMode(context);
    final textController = TextEditingController();
    List <ChatRoomModel> searchesChatRooms = controller.chatRoomList;

    final callController = Get.put(CallController());

    RxList <ChatRoomModel> chatRooms = <ChatRoomModel>[].obs;
    controller.getAllChatRooms();
    chatRooms.assignAll(controller.chatRoomList);
    // final text = UserController.instance.encryptor.encrypt("i am k😍unal jain from ses", iv : UserController.instance.iv);
    // final text2 = UserController.instance.encryptor.decrypt(text, iv : UserController.instance.iv);
    // print(text.base64);
    // print(text.runtimeType);
    // print(text2);
    return Scaffold
      (
        body: Stack(
          children: [
            RoundedContainer(
              backgroundColor: Colors.transparent,
              child: Image(
                image: const AssetImage("assets/images/network/spiweb.png"),
                color: dark? Colors.white10 : TColors.grey,
                height: MediaQuery.of(context).size.height,
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [

                  /// Header--->
                  PrimaryHeaderContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// AppBar
                        const ThemeAppBar(),
                        const SizedBox(height: TSizes.spaceBtwItems / 2),

                        /// SearchBar
                        SearchBarContainer(text: "Search for messages", textController: textController,
                        onChanged: (value) async {
                          searchesChatRooms = controller.chatRoomList;
                          searchesChatRooms = await controller.getChatRoomsBySearch(textController.text);
                          chatRooms.clear();
                          chatRooms.assignAll(searchesChatRooms);
                        },),
                        const SizedBox(height: TSizes.spaceBtwItems),

                        /// Chat Filters
                        SortOptions(
                            controller: controller,
                            list: const ["All Chats", "Pinned Chats", "Favourites", "Archives"]
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems * 3)
                      ],
                    ),
                  ),


                  /// Body (List of Chats)
                  Obx(
                      () => ListView.builder(
                      shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.chatRoomList.length,
                        itemBuilder: (_, index){
                        return Column(
                          children: [
                            InkWell(
                              highlightColor: Colors.blueAccent.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(100),
                              onTap: () {
                                if (controller.chatRoomList[index].sender.id == UserController.instance.user.value.id){
                                  Get.to(() => MessageScreen(userModelReceiver: controller.chatRoomList[index].receiver));
                                }
                                else{
                                  Get.to(() => MessageScreen(userModelReceiver: controller.chatRoomList[index].sender));
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: TSizes.spaceBtwItems, vertical: 5),
                                child: SingleChat(chatRoom: controller.chatRoomList[index]),
                              ),

                            ),
                          ],
                        );}
                    ),
                  ),

                  /// End Section
                  const Divider(thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outline),
                      const SizedBox(width: TSizes.sm),
                      Text(TTexts.securityStatement, style: Theme.of(context).textTheme.labelLarge)
                    ],
                  ),
                  const SizedBox(height: TSizes.defaultSpace),
                  // Padding(padding: const EdgeInsets.all(TSizes.defaultSpace),
                  //   child: Column(
                  //     children: [
                  //
                  //       /// Promo_Slider
                  //       const PromoSlider(),
                  //       const SizedBox(height: TSizes.spaceBtwItems),
                  //
                  //       /// Heading
                  //       SectionHeading(title: 'Trending Products',textColor: dark? TColors.light: TColors.black,
                  //           onPressed: () =>
                  //               Get.to(() => AllProducts
                  //                 (title: "Trending Products",
                  //                 futureMethod: controller.fetchAllFeaturedProducts(),
                  //               ))
                  //       ),
                  //       const SizedBox(height: TSizes.spaceBtwItems),
                  //
                  //       /// Popular_Products (GridView)
                  //       Obx(() {
                  //         if (controller.isLoading.value) return const VerticalProductShimmer();
                  //
                  //         if (controller.featuredProducts.isEmpty){
                  //           return Center(child: Text('No Data Found!', style: Theme.of(context).textTheme.bodyMedium));
                  //         }
                  //         return GridLayout(
                  //             itemCount: controller.featuredProducts.length,
                  //             itemBuilder: (_, index) =>
                  //                 ProductCardVertical(product: controller.featuredProducts[index])
                  //         );
                  //       }),
                  //     ],
                  //   ),
                  // )
                ],
              ),
            ),
          ],
        )
    );
  }
}


