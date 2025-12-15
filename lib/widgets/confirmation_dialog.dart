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
  final IconData? icon;
  final Color? iconColor;

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
    this.icon,
    this.iconColor,
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
    IconData? icon,
    Color? iconColor,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        onConfirm: onConfirm,
        onCancel: onCancel,
        confirmText: confirmText ?? 'Confirm',
        cancelText: cancelText ?? 'Cancel',
        confirmColor: confirmColor ?? AppColors.secondary,
        cancelColor: cancelColor ?? AppColors.red,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    
    if (isMobile) {
      return _buildMobileDialog(context);
    }
    
    return _buildWebDialog(context);
  }

  Widget _buildMobileDialog(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
          width: screenWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon (optional)
              if (icon != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 32, bottom: 16),
                  decoration: BoxDecoration(
                    color: (iconColor ?? cancelColor).withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 48,
                    color: iconColor ?? cancelColor,
                  ),
                ),
              
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    
                    // Message
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    // Buttons (Stacked vertically on mobile)
                    Column(
                      children: [
                        // Confirm Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: confirmColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              shadowColor: confirmColor.withOpacity(0.3),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              onConfirm();
                            },
                            child: Text(
                              confirmText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Cancel Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: cancelColor,
                              side: BorderSide(color: cancelColor, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.transparent,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              onCancel?.call();
                            },
                            child: Text(
                              cancelText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebDialog(BuildContext context) {
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