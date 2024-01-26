import 'package:flutter/material.dart';

import '../constants/colors.dart';

class CustomButton extends StatelessWidget {
  final Color colour;
  final String title;
  final VoidCallback? onPressed;
  final Color? titleColor;
  final double? minWidth;
  final EdgeInsets? padding;
  const CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.colour = kAccentRed,
    this.titleColor,
    this.minWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        color: onPressed == null ? Colors.grey : colour,
        borderRadius: BorderRadius.circular(32.0),
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
