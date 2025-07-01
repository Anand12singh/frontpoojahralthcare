import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/colors.dart';
import 'custom_text_field.dart';

class DatePickerInput extends StatefulWidget {
  final String label;
  final String hintlabel;
  final DateTime? initialDate;
  final ValueChanged<DateTime> onDateSelected;
  final bool enabled;

  const DatePickerInput({
    Key? key,
    required this.label,
    required this.hintlabel,
    this.initialDate,
    required this.onDateSelected,
    this.enabled = true,
  }) : super(key: key);

  @override
  _DatePickerInputState createState() => _DatePickerInputState();
}

class _DatePickerInputState extends State<DatePickerInput> {
  late TextEditingController _controller;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _controller = TextEditingController(
      text: _selectedDate != null ? _formatDate(_selectedDate!) : '',
    );
  }

  @override
  void didUpdateWidget(DatePickerInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != oldWidget.initialDate) {
      _selectedDate = widget.initialDate;
      _controller.text = _selectedDate != null ? _formatDate(_selectedDate!) : '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  Future<void> _selectDate(BuildContext context) async {
    if (!widget.enabled) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _controller.text = _formatDate(picked);
      });
      widget.onDateSelected(picked);
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
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.primary)),
          const SizedBox(height: 4),
          Stack(
            children: [
              CustomTextField(
                hintText: widget.hintlabel,
                  controller: _controller,
                  readOnly: true,
                  enabled: widget.enabled,
              
              onTap: () => _selectDate(context),
              ),
              
              Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(Icons.calendar_month_outlined,color: AppColors.primary,size: 20,),
                  ))
            ],
          ),
        ],
      ),
    );
  }
}