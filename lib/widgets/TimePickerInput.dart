import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/ResponsiveUtils.dart';
import '../utils/colors.dart';
import 'custom_text_field.dart';

class TimePickerInput extends StatefulWidget {
  final String label;
  final String hintlabel;
  final TimeOfDay? initialTime;
  final ValueChanged<TimeOfDay> onTimeSelected;
  final bool enabled;

  const TimePickerInput({
    Key? key,
    required this.label,
    required this.hintlabel,
    this.initialTime,
    required this.onTimeSelected,
    this.enabled = true,
  }) : super(key: key);

  @override
  _TimePickerInputState createState() => _TimePickerInputState();
}

class _TimePickerInputState extends State<TimePickerInput> {
  late TextEditingController _controller;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
    _controller = TextEditingController(
      text: _selectedTime != null ? _formatTime(_selectedTime!) : '',
    );
  }

  @override
  void didUpdateWidget(TimePickerInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTime != oldWidget.initialTime) {
      _selectedTime = widget.initialTime;
      _controller.text = _selectedTime != null ? _formatTime(_selectedTime!) : '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt); // e.g., 3:45 PM
  }

  Future<void> _selectTime(BuildContext context) async {
    if (!widget.enabled) return;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _controller.text = _formatTime(picked);
      });
      widget.onTimeSelected(picked);
    }
  }

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
          Text(widget.label,
              style:  TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.primary,fontSize: ResponsiveUtils.fontSize(context, 14))),
          const SizedBox(height: 4),
          Stack(
            children: [
              CustomTextField(
                hintText: widget.hintlabel,
                controller: _controller,
                readOnly: true,
                enabled: widget.enabled,

                onTap: () => _selectTime(context),
              ),
              Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () => _selectTime(context),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(Icons.access_time_rounded,color: AppColors.primary,size: 20,),
                    ),
                  ))
            ],
          ),
        ],
      ),
    );
  }
}
