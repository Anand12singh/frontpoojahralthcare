import 'package:flutter/material.dart';

import '../constants/ResponsiveUtils.dart';
import '../utils/colors.dart';
class HistoryYesNoField extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget? extraField;

  const HistoryYesNoField({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.extraField,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "$label :",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),

              // Radio buttons
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: value,
                      activeColor: AppColors.secondary, // ✅ custom color
                      onChanged: (val) => onChanged(val!),
                    ),
                    const Text("Yes"),
                    Radio<bool>(
                      value: false,
                      groupValue: value,
                      activeColor: Colors.red, // ✅ custom color
                      onChanged: (val) => onChanged(val!),
                    ),
                    const Text("No"),
                  ],
                ),
              ),


            ],
          ),


          // Extra field (enabled only if "No")
          if (extraField != null)
            AbsorbPointer(
              absorbing: !value, // ✅ disables when value == true ("Yes")
              child: Opacity(
                opacity: !value ? 0.4 : 1.0, // ✅ faded if disabled
                child: extraField,
              ),
            ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                "$label :",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            // Radio buttons
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Radio<bool>(
                    value: true,
                    groupValue: value,
                    activeColor: AppColors.secondary, // ✅ custom color
                    onChanged: (val) => onChanged(val!),
                  ),
                  const Text("Yes"),
                  Radio<bool>(
                    value: false,
                    groupValue: value,
                    activeColor: Colors.red, // ✅ custom color
                    onChanged: (val) => onChanged(val!),
                  ),
                  const Text("No"),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Extra field (enabled only if "No")
            if (extraField != null)
              Expanded(
                flex: 3,
                child: AbsorbPointer(
                  absorbing: !value, // ✅ disables when value == true ("Yes")
                  child: Opacity(
                    opacity: !value ? 0.4 : 1.0, // ✅ faded if disabled
                    child: extraField,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
