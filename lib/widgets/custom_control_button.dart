import 'package:flutter/material.dart';
import 'package:minimal_player/utils/app_colors.dart';

class CustomControlButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onPressed;

  const CustomControlButton({ Key? key, required this.icon, required this.onPressed, this.color }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      iconSize: 32.0,
      color: color ?? AppColors.primaryAccent,
      onPressed: onPressed,
    );
  }
}