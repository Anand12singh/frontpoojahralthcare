import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import '../constants/ResponsiveUtils.dart';
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
  State<DropdownInput<T>> createState() => _DropdownInputState<T>();
}

class _DropdownInputState<T> extends State<DropdownInput<T>> {
  bool isHovered = false;

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

    Color borderColor = isHovered
        ? AppColors.primary
        : AppColors.textSecondary.withOpacity(0.3);

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: SizedBox(
        width: fieldWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: widget.labelStyle ??
                  TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    fontSize: ResponsiveUtils.fontSize(context, 14),
                  ),
            ),
            const SizedBox(height: 4),
            DropdownButtonFormField2<T>(
              value: widget.value,
              items: widget.items,
              onChanged: widget.onChanged,
              validator: widget.validator,
              isExpanded: widget.isExpanded,
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                widget.contentPadding ?? const EdgeInsets.symmetric(horizontal: 12),
                filled: widget.filled,
                fillColor: widget.fillColor ?? Colors.white,
                border: widget.border ??
                    OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: borderColor,
                        width: 1.5,
                      ),
                    ),
                enabledBorder: widget.enabledBorder ??
                    OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: borderColor,
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
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: ResponsiveUtils.scaleHeight(context, 250),
                elevation: widget.elevation?.toInt() ?? 8,
                decoration: BoxDecoration(
                  color: widget.dropdownColor ?? Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              buttonStyleData: ButtonStyleData(
                padding: EdgeInsets.zero,
                height: ResponsiveUtils.scaleHeight(context, 50),
                overlayColor: MaterialStateProperty.all(Colors.transparent),
              ),
              iconStyleData: IconStyleData(
                icon: widget.icon ?? const Icon(Icons.arrow_drop_down),
                iconSize: widget.iconSize ?? 24,
                iconEnabledColor:
                widget.iconEnabledColor ?? AppColors.primary,
              ),
              hint: widget.hintText != null
                  ? Text(
                widget.hintText!,
                style: widget.hintStyle ??
                    TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.6),
                    ),
              )
                  : null,
              style: widget.textStyle ??
                  TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
