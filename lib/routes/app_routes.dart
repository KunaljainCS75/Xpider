import 'package:get/get.dart';
import 'package:xpider_chat/features/chat/screens/chat_section/ChatSection.dart';
import 'package:xpider_chat/routes/routes.dart';

class AppRoutes{
  static final pages = [
    GetPage(name: Routes.home, page: () => const ChatSectionScreen()),
    // GetPage(name: Routes.store, page: () => const StoreScreen()),
    // // GetPage(name: Routes.favourites, page: () => const FavouritesScreen()),
    // GetPage(name: Routes.settings, page: () => const SettingScreen()),
    // GetPage(name: Routes.productReviews, page: () => const ProductReviewsScreen()),
    // GetPage(name: Routes.order, page: () => const OrderScreen()),
    // GetPage(name: Routes.checkout, page: () => const CheckOutScreen()),
    // GetPage(name: Routes.cart, page: () => const CartScreen()),
    // GetPage(name: Routes.productDetails, page: () => const ProductDetailsScreen()),
  ];
}