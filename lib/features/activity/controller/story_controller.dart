import 'package:get/get.dart';
import 'package:story_view/story_view.dart';
import 'package:story_view/widgets/story_view.dart';

class StoryViewController extends GetxController{
  static StoryViewController get instance => Get.find();

  // RxList<String> imgUrl = <String>[].obs;
  // RxList<String> captions = <String>[].obs;

  RxList<StoryItem> storyItems = <StoryItem>[].obs;
  RxString storyViewImage = ''.obs;

  final storyController = StoryController();
}