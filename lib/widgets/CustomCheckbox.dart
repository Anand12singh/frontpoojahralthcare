import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:poojaheakthcare/utils/colors.dart';

import '../constants/ResponsiveUtils.dart';

// Custom Checkbox Widget
class CustomCheckbox extends StatefulWidget {
  final String label;
  final bool initialValue;
  final ValueChanged<bool>? onChanged;

  const CustomCheckbox({
    super.key,
    required this.label,
    required this.initialValue, // Make this required
    this.onChanged,
  });

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  late bool isChecked;

  @override
  void initState() {
    super.initState();
    isChecked = widget.initialValue;
  }

  @override
  void didUpdateWidget(CustomCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        isChecked = widget.initialValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isChecked = !isChecked;
          widget.onChanged?.call(isChecked);
        });
      },
      child: Row(

        children: [
          Container(
            width: ResponsiveUtils.scaleWidth(context, 24),
            height: ResponsiveUtils.scaleHeight(context, 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isChecked ? AppColors.secondary : Colors.grey,
                width: 2,
              ),
              color: isChecked ? AppColors.secondary : Colors.transparent,
            ),
            child: isChecked
                ?  Icon(Icons.check, size:  ResponsiveUtils.fontSize(context, 16), color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            widget.label,
            style: TextStyle(
              color: isChecked ? AppColors.primary : Colors.grey[700],
              fontWeight: FontWeight.w600,fontSize:  ResponsiveUtils.fontSize(context, 14)
            ),
          ),
        ],
      ),
    );
  }
}
// Custom Radio Button Widget
class CustomRadioButton<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T?> onChanged;
  final String label;

  const CustomRadioButton({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.label,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          isSelected
              ?Center(child: Icon(

            Icons.check_circle_rounded,color: AppColors.secondary,size:  ResponsiveUtils.fontSize(context, 24),)) //Image.asset("assets/checkbox.png")
              : Icon(

            Icons.circle_outlined,color: Colors.grey,size:  ResponsiveUtils.fontSize(context, 24),),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

