import 'package:flutter/material.dart';
import '../utils/colors.dart';

class DropdownInput<T> extends StatefulWidget {
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
    this.isExpanded = false,
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
  State<DropdownInput<T>> createState() => _DropdownInputState<T>();
}

class _DropdownInputState<T> extends State<DropdownInput<T>> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;


    double fieldWidth;

    if (screenWidth < 600) {
      // Small screens - use full width
      fieldWidth = double.infinity;
    }  else if (screenWidth < 1200) {
      // Medium screens - half screen
      fieldWidth = screenWidth * 0.45;
    } else if (screenWidth == 1440) {
      // Medium screens - half screen
      fieldWidth = 250;
    }else {
      // Large screens - fixed comfortable width
      fieldWidth = 275;
    }

    return SizedBox(
      width: fieldWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: widget.labelStyle ??
                const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<T>(
            value: widget.value,
            items: widget.items,
            onChanged: widget.onChanged,
            validator: widget.validator,
            isExpanded: widget.isExpanded,
            hint: widget.hintText != null
                ? Text(
              widget.hintText!,
              style: widget.hintStyle ??
                  TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.6),
                  ),
            )
                : null,
            decoration: InputDecoration(
              contentPadding: widget.contentPadding ??
                  const EdgeInsets.symmetric(horizontal: 12),
              border: widget.border ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.textSecondary.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
              enabledBorder: widget.enabledBorder ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.textSecondary.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
              focusedBorder: widget.focusedBorder ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
              errorBorder: widget.errorBorder ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.error,
                      width: 1.5,
                    ),
                  ),
              focusedErrorBorder: widget.errorBorder ??
                  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.error,
                      width: 1.5,
                    ),
                  ),
              filled: widget.filled,
              fillColor: widget.fillColor ?? Colors.white,
            ),
            style: widget.textStyle ??
                TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
            icon: widget.icon ??
                Icon(
                  Icons.arrow_drop_down,
                  color: widget.iconEnabledColor ?? AppColors.primary,
                  size: widget.iconSize ?? 24,
                ),
            iconSize: widget.iconSize ?? 24,
            iconEnabledColor: widget.iconEnabledColor ?? AppColors.primary,
            dropdownColor: widget.dropdownColor ?? Colors.white,
            elevation: widget.elevation?.toInt() ?? 8,
            isDense: widget.isDense ?? false,
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
    );
  }
}