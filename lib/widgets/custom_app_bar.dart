import 'package:flutter/material.dart';
import 'package:minimal_player/utils/app_strings.dart';
import 'package:minimal_player/utils/text_styles.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        AppStrings.appTitle,
        style: TextStyles.primaryBold,
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}