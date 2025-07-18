import 'package:flutter/material.dart';
import '../constants/ResponsiveUtils.dart';
import '../utils/colors.dart';
import '../widgets/AnimatedButton.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Color confirmColor;
  final Color cancelColor;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.onCancel,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.confirmColor = AppColors.secondary,
    this.cancelColor = AppColors.red,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    String? confirmText,
    String? cancelText,
    Color? confirmColor,
    Color? cancelColor,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        onConfirm: onConfirm,
        onCancel: onCancel,
        confirmText: confirmText ?? 'Confirm',
        cancelText: cancelText ?? 'Cancel',
        confirmColor: confirmColor ?? AppColors.secondary,
        cancelColor: cancelColor ?? AppColors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: ResponsiveUtils.scaleWidth(context, 450),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 20),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.scaleHeight(context, 20)),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 16),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveUtils.scaleHeight(context, 30)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: ResponsiveUtils.scaleWidth(context, 120),
                      child: Animatedbutton(
                        title: cancelText,
                        onPressed: () {
                          Navigator.of(context).pop();
                          onCancel?.call();
                        },
                        titlecolor: cancelColor,
                        backgroundColor: Colors.white,
                        shadowColor: Colors.white,
                        borderColor: cancelColor,
                      ),
                    ),
                    SizedBox(
                      width: ResponsiveUtils.scaleWidth(context, 120),
                      child: Animatedbutton(
                        backgroundColor: confirmColor,
                        shadowColor: Colors.white,
                        title: confirmText,
                        onPressed: () {
                          Navigator.of(context).pop();
                          onConfirm();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}