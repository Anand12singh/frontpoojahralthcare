import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:poojaheakthcare/utils/colors.dart';

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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isChecked ? AppColors.secondary : Colors.grey,
                width: 2,
              ),
              color: isChecked ? AppColors.secondary : Colors.transparent,
            ),
            child: isChecked
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            widget.label,
            style: TextStyle(
              color: isChecked ? AppColors.primary : Colors.grey[700],
              fontWeight: FontWeight.w600
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
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.secondary : Colors.grey,
                width: 2,
              ),
            ),
            child: isSelected
                ? Image.asset("assets/checkbox.png")
                : null,
          ),
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

