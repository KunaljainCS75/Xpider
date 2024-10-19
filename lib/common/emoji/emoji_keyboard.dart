import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

class EmojiKeyboard extends StatelessWidget {
  const EmojiKeyboard({
    super.key,
    required this.messageController,
    required this.dark,
  });

  final TextEditingController messageController;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return EmojiPicker(
      textEditingController: messageController,
      onBackspacePressed: () {},
      config: Config(
        height: 256,
        emojiViewConfig: EmojiViewConfig(
          backgroundColor: dark ? Colors.blueGrey.shade900 : Colors.white70,
          columns: 7,
          // Issue: https://github.com/flutter/flutter/issues/28894
          emojiSizeMax: 28 *
              (Platform.isIOS
                  ?  1.20
                  :  1.0),
        ),
        viewOrderConfig: const ViewOrderConfig(
          top: EmojiPickerItem.categoryBar,
          middle: EmojiPickerItem.emojiView,
          bottom: EmojiPickerItem.searchBar,
        ),
        skinToneConfig: const SkinToneConfig(),
        categoryViewConfig: CategoryViewConfig(
          backgroundColor: dark ? Colors.blueGrey.shade900 : Colors.white70,
          extraTab: CategoryExtraTab.BACKSPACE,
        ),
        bottomActionBarConfig: const BottomActionBarConfig(
            showBackspaceButton: false,
            showSearchViewButton: false
        ),
        searchViewConfig: const SearchViewConfig(),
      ),

    );
  }
}