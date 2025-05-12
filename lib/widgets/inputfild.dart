import 'package:flutter/material.dart';
import 'package:poojaheakthcare/utils/colors.dart';

Widget buildCustomInput({
  required TextEditingController controller,
  required String label,
  bool isRequired = false,
  TextInputType keyboardType = TextInputType.text,
  int minLines = 1,
  int maxLines = 1,
  bool enabled = true,
  bool obscureText = false,
  String? Function(String?)? validator,
  void Function(String)? onChanged,
  String? hintText,
  Widget? prefixIcon,
  Widget? suffixIcon,
  String? errorText,
  double borderRadius = 12.0,
  bool enableNewLines = false,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: RichText(
              text: TextSpan(
                text: label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                children: isRequired
                    ? [
                        const TextSpan(
                            text: ' *',
                            style: TextStyle(color: AppColors.error))
                      ]
                    : [],
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              errorText: errorText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: const BorderSide(color: AppColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide:
                    const BorderSide(color: AppColors.error, width: 1.5),
              ),
              filled: true,
              fillColor: enabled ? Colors.white : AppColors.primaryLight,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: maxLines > 1 ? 16 : 14,
              ),
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.6),
                fontSize: 16,
              ),
            ),
            keyboardType:
                enableNewLines ? TextInputType.multiline : keyboardType,
            minLines: minLines,
            maxLines: enableNewLines ? null : maxLines,
            enabled: enabled,
            validator: validator,
            onChanged: onChanged,
            style: TextStyle(
              color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ),
      ],
    ),
  );
}
