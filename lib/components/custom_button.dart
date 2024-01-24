import 'package:flutter/material.dart';

import '../constants/colors.dart';

class CustomButton extends StatelessWidget {
  final Color colour;
  final String title;
  final VoidCallback? onPressed;
  final Color? titleColor;
  final double? minWidth;
  CustomButton({
    Key? key,
    required this.title,
    required this.onPressed,
    this.colour = kAccentRed,
    this.titleColor,
    this.minWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        color: colour,
        borderRadius: BorderRadius.circular(12.0),
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: minWidth ?? double.infinity,
          height: 56.0,
          child: Text(
            title,
            style: TextStyle(
              color: titleColor ?? Colors.white,
              fontFamily: 'Roboto',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
