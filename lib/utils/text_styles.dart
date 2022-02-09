import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minimal_player/utils/app_colors.dart';

class TextStyles {

  static TextStyle primaryRegular = GoogleFonts.ubuntu(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryAccent,
  );

  static TextStyle primaryBold = GoogleFonts.ubuntu(
    fontSize: 22.0,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryAccent,
  );

  static TextStyle artistText = GoogleFonts.ubuntu(
    fontSize: 12.0,
    color: AppColors.greyColor,
  );

  static TextStyle currentPlaying = GoogleFonts.ubuntu(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: AppColors.currentSongColor,
  );

}