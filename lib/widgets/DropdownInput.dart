import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import '../constants/ResponsiveUtils.dart';
import '../utils/colors.dart';

class DropdownInput<T> extends StatelessWidget {
  final String label;
  final String? hintText;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final bool isExpanded;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final Color? fillColor;
  final bool filled;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final Widget? icon;
  final double? iconSize;
  final Color? iconEnabledColor;
  final Color? dropdownColor;
  final double? elevation;
  final bool? isDense;

  const DropdownInput({
    super.key,
    required this.label,
    required this.items,
    this.value,
    this.onChanged,
    this.validator,
    this.hintText,
    this.isExpanded = true,
    this.contentPadding,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.fillColor,
    this.filled = true,
    this.labelStyle,
    this.hintStyle,
    this.textStyle,
    this.icon,
    this.iconSize,
    this.iconEnabledColor,
    this.dropdownColor,
    this.elevation,
    this.isDense,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double fieldWidth;
    if (screenWidth < 600) {
      fieldWidth = double.infinity;
    } else if (screenWidth < 1200) {
      fieldWidth = screenWidth * 0.45;
    } else if (screenWidth == 1440) {
      fieldWidth = 250;
    } else {
      fieldWidth = 275;
    }

    return SizedBox(
      width: fieldWidth,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: labelStyle ??
                TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  fontSize: ResponsiveUtils.fontSize(context, 14),
                ),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField2<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            validator: validator,
            isExpanded: isExpanded,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 12),
              filled: filled,
              fillColor: fillColor ?? Colors.white,
              border: border ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.textSecondary.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
              enabledBorder: enabledBorder ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.textSecondary.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
              focusedBorder: focusedBorder ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
              errorBorder: errorBorder ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.error,
                      width: 1.5,
                    ),
                  ),
              focusedErrorBorder: errorBorder ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.error,
                      width: 1.5,
                    ),
                  ),
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: ResponsiveUtils.scaleHeight(context, 250),
              elevation: elevation?.toInt() ?? 8,
              decoration: BoxDecoration(
                color: dropdownColor ?? Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),

            ),
            buttonStyleData: ButtonStyleData(
              padding: EdgeInsets.zero,
              height:  ResponsiveUtils.scaleHeight(context, 50),
              overlayColor: MaterialStateProperty.all(Colors.transparent),
            ),
            iconStyleData: IconStyleData(
              icon: icon ?? Icon(Icons.arrow_drop_down),
              iconSize: iconSize ?? 24,
              iconEnabledColor: iconEnabledColor ?? AppColors.primary,
            ),
            hint: hintText != null
                ? Text(
              hintText!,
              style: hintStyle ??
                  TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.6),
                  ),
            )
                : null,
            style: textStyle ??
                TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
          ),
        ],
      ),
    );
  }
}
