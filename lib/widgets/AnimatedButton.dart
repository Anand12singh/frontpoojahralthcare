import 'package:flutter/material.dart';

class Animatedbutton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final String title;
  final Color backgroundColor;
  final Color titlecolor;
  final Color shadowColor;
  final Color borderColor; // New border color parameter
  final double borderWidth; // Optional border width parameter

  const Animatedbutton({
    super.key,
    this.isLoading=false,
    required this.onPressed,
    this.title = 'Login',
    this.titlecolor = Colors.white,
    required this.backgroundColor,
    required this.shadowColor,
    this.borderColor = Colors.transparent, // Default to no border
    this.borderWidth = 0.0, // Default border width
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
     // width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isLoading
            ? []
            : [
          BoxShadow(
            color: shadowColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: borderColor,
              width: borderWidth,
            ),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: Colors.white,
          ),
        )
            : Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: titlecolor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}