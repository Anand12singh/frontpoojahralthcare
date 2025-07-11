import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/ResponsiveUtils.dart';
import '../utils/colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? prefix;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onEditingComplete;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool autofocus;
  final bool expands;
  final bool showCursor;
  final bool autocorrect;
  final bool enableSuggestions;
  final String? initialValue;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? contentPadding;
  final BoxConstraints? prefixIconConstraints;
  final BoxConstraints? suffixIconConstraints;
  final Color? fillColor;
  final bool? filled;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? helperStyle;
  final TextStyle? errorStyle;
  final TextStyle? style;
  final String? counterText;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final bool? isDense;
  final bool? isCollapsed;
  final Widget? icon;
  final Widget? suffix;
  final Brightness? keyboardAppearance;
  final Widget? Function(BuildContext,
      {required int currentLength,
      required bool isFocused,
      required int? maxLength})? buildCounter;
  final ScrollPhysics? scrollPhysics;
  final Iterable<String>? autofillHints;
  final MouseCursor? mouseCursor;
  final ScrollController? scrollController;
  final String? restorationId;
  final bool enableInteractiveSelection;
  final TextSelectionControls? selectionControls;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final BoxHeightStyle selectionHeightStyle;
  final BoxWidthStyle selectionWidthStyle;
  final StrutStyle? strutStyle;
  final bool obscureTextAutoToggle;
  final Duration? obscureTextToggleDelay;
  final List<TextInputFormatter>? inputFormatters;
  const CustomTextField({
    Key? key,
    this.controller,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.prefix,
    this.suffixIcon,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.onChanged,
    this.inputFormatters,
    this.onTap,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.autofocus = false,
    this.expands = false,
    this.showCursor = true,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.initialValue,
    this.focusNode,
    this.contentPadding,
    this.prefixIconConstraints,
    this.suffixIconConstraints,
    this.fillColor,
    this.filled,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.labelStyle,
    this.hintStyle,
    this.helperStyle,
    this.errorStyle,
    this.style,
    this.counterText,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.isDense,
    this.isCollapsed,
    this.icon,
    this.suffix,
    this.keyboardAppearance,
    this.buildCounter,
    this.scrollPhysics,
    this.autofillHints,
    this.mouseCursor,
    this.scrollController,
    this.restorationId,
    this.enableInteractiveSelection = true,
    this.selectionControls,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.selectionHeightStyle = BoxHeightStyle.tight,
    this.selectionWidthStyle = BoxWidthStyle.tight,
    this.strutStyle,
    this.obscureTextAutoToggle = false,
    this.obscureTextToggleDelay,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;
  late bool _obscureText;
  Timer? _obscureTextToggleTimer;
  late bool _isHovered;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _obscureText = widget.obscureText;
    _isHovered = false;

    if (widget.obscureTextAutoToggle && widget.obscureTextToggleDelay != null) {
      _startObscureTextToggleTimer();
    }
  }

  void _startObscureTextToggleTimer() {
    _obscureTextToggleTimer = Timer(widget.obscureTextToggleDelay!, () {
      if (mounted) {
        setState(() {
          _obscureText = !_obscureText;
        });
      }
    });
  }

  InputBorder _buildBorder(InputBorder baseBorder) {
    if (_isHovered) {
      if (baseBorder is OutlineInputBorder) {
        return baseBorder.copyWith(
          borderSide: BorderSide(
            color: AppColors.primary,
            width: baseBorder.borderSide.width,
          ),
        );
      }
    }
    return baseBorder;
  }


  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller =
          widget.controller ?? TextEditingController(text: widget.initialValue);
    }
    if (widget.obscureText != oldWidget.obscureText) {
      _obscureText = widget.obscureText;
    }
  }

  @override
  void dispose() {
    _obscureTextToggleTimer?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorder = widget.border ??
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.textSecondary.withOpacity(0.3),
            width: 1.5,
          ),
        );

    final effectiveEnabledBorder = widget.enabledBorder ??
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.textSecondary.withOpacity(0.3),
            width: 1.5,
          ),
        );

    final effectiveFocusedBorder = widget.focusedBorder ??
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        );

    final effectiveErrorBorder = widget.errorBorder ??
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        );

    final effectiveFocusedErrorBorder = widget.focusedErrorBorder ??
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        );

    final effectiveContentPadding = widget.contentPadding ??
        const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        );

    final effectiveFillColor = widget.fillColor ?? Colors.white;
    final effectiveFilled = widget.filled ?? true;

    final effectiveLabelStyle = widget.labelStyle ??
        TextStyle(
          color: AppColors.textPrimary,
          fontSize:  ResponsiveUtils.fontSize(context, 16)
        );

    final effectiveHintStyle = widget.hintStyle ??
        TextStyle(
          color: AppColors.hinttext,
          fontSize:    ResponsiveUtils.fontSize(context, 16)
        );

    final effectiveStyle = widget.style ??
        TextStyle(
          color: AppColors.textPrimary,
          fontSize: ResponsiveUtils.fontSize(context, 16)
        );

    final effectiveSuffixIcon = widget.obscureText
        ? IconButton(
            icon: Icon(
              _obscureText
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.primary.withOpacity(0.8),
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          )
        : widget.suffixIcon;
    String? _toCamelCase(String text) {
      if (text.isEmpty) return text;

      return text
          .split(' ')
          .map((word) =>
      word.isNotEmpty
          ? word[0].toUpperCase() + word.substring(1).toLowerCase()
          : '')
          .join(' ');
    }
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: TextFormField(
        controller: _controller,
        focusNode: widget.focusNode,
        obscureText: _obscureText,
        readOnly: widget.readOnly,
        enabled: widget.enabled,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        style: effectiveStyle,
        textAlign: widget.textAlign,
        textAlignVertical: widget.textAlignVertical ?? TextAlignVertical.center,
        autofocus: widget.autofocus,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        expands: widget.expands,
        showCursor: widget.showCursor,
        autocorrect: widget.autocorrect,
        enableSuggestions: widget.enableSuggestions,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: _toCamelCase(widget.hintText!),
          helperText: widget.helperText,
          errorText: widget.errorText,
          labelStyle: effectiveLabelStyle,
          hintStyle: effectiveHintStyle,
          helperStyle: widget.helperStyle,
          errorStyle: widget.errorStyle,
          prefixIcon: widget.prefixIcon != null
              ? Icon(
            widget.prefixIcon,
            color: AppColors.primary.withOpacity(0.8),
            size: ResponsiveUtils.fontSize(context, 20),
          )
              : null,
          prefixIconConstraints: widget.prefixIconConstraints,
          suffixIcon: effectiveSuffixIcon,
          suffixIconConstraints: widget.suffixIconConstraints,
          suffix: widget.suffix,
          icon: widget.icon,
          isDense: widget.isDense,
          isCollapsed: widget.isCollapsed,
          border: _buildBorder(effectiveBorder),
        hoverColor: Colors.white,
          enabledBorder: _buildBorder(effectiveEnabledBorder),
          focusedBorder: effectiveFocusedBorder,
          errorBorder: effectiveErrorBorder,
          focusedErrorBorder: effectiveFocusedErrorBorder,
          contentPadding: effectiveContentPadding,
          filled: effectiveFilled,
          fillColor: effectiveFillColor,
          counterText: '',
          counterStyle: widget.errorStyle,
          alignLabelWithHint: true,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          floatingLabelAlignment: FloatingLabelAlignment.start,
          floatingLabelStyle: effectiveLabelStyle.copyWith(
            color: AppColors.primary,
          ),
          errorMaxLines: 2,
          helperMaxLines: 2,
          hintMaxLines: 1,
        ),
        validator: widget.validator,
        onChanged: widget.onChanged,
        onTap: widget.onTap,
        onFieldSubmitted: widget.onFieldSubmitted,
        onEditingComplete: widget.onEditingComplete,
        keyboardAppearance: widget.keyboardAppearance,
        buildCounter: widget.buildCounter,
        scrollPhysics: widget.scrollPhysics,
        autofillHints: widget.autofillHints,
        mouseCursor: widget.mouseCursor,
        scrollController: widget.scrollController,
        restorationId: widget.restorationId,
        enableInteractiveSelection: widget.enableInteractiveSelection,
        selectionControls: widget.selectionControls,
        cursorWidth: widget.cursorWidth,
        cursorHeight: widget.cursorHeight,
        cursorRadius: widget.cursorRadius,
        cursorColor: widget.cursorColor ?? AppColors.primary,
        selectionHeightStyle: widget.selectionHeightStyle,
        selectionWidthStyle: widget.selectionWidthStyle,
        strutStyle: widget.strutStyle,
      ),
    );

  }
}
