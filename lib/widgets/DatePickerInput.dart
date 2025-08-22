import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../constants/ResponsiveUtils.dart';
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
  late DateTime _displayDate; // Track current displayed month
  late DateRangePickerController _datePickerController;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _controller = TextEditingController(
      text: _selectedDate != null ? _formatDate(_selectedDate!) : '',
    );
    _displayDate = _selectedDate ?? DateTime.now();
    _datePickerController = DateRangePickerController();
    _datePickerController.displayDate = _displayDate;
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  Future<void> _selectDate(BuildContext context) async {
    if (!widget.enabled) return;

    DateTime? pickedDate;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // ✅ To manage local state inside dialog
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 700,
                  height: 500,
                  child: Column(
                    children: [
                      // ✅ Custom Calendar Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        color: AppColors.primary.withOpacity(0.1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon:  Text("<<",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                              onPressed: () {
                                setDialogState(() {
                                  _displayDate =
                                      DateTime(_displayDate.year - 1, _displayDate.month);
                                  _datePickerController.displayDate = _displayDate;
                                });
                              },
                            ),
                            IconButton(
                              icon: const Text("<",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                              onPressed: () {
                                setDialogState(() {
                                  _displayDate =
                                      DateTime(_displayDate.year, _displayDate.month - 1);
                                  _datePickerController.displayDate = _displayDate;
                                });
                              },
                            ),
                            Text(
                              DateFormat('MMMM yyyy').format(_displayDate),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            IconButton(
                              icon: const Text(">",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                              onPressed: () {
                                setDialogState(() {
                                  _displayDate =
                                      DateTime(_displayDate.year, _displayDate.month + 1);
                                  _datePickerController.displayDate = _displayDate;
                                });
                              },
                            ),
                            IconButton(
                              icon:  Text(">>",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                              onPressed: () {
                                setDialogState(() {
                                  _displayDate =
                                      DateTime(_displayDate.year + 1, _displayDate.month);
                                  _datePickerController.displayDate = _displayDate;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      // ✅ Calendar with custom navigation
                      Expanded(
                        child: SfDateRangePicker(
                          headerHeight: 0, // Hide default header
                          selectionMode: DateRangePickerSelectionMode.single,
                          initialSelectedDate: _selectedDate ?? DateTime.now(),
                          showActionButtons: true,
                          controller: _datePickerController, // ✅ Persistent controller
                          selectionColor: AppColors.secondary,
                          todayHighlightColor: AppColors.primary,
                          onSelectionChanged:
                              (DateRangePickerSelectionChangedArgs args) {
                            pickedDate = args.value as DateTime?;
                          },
                          onSubmit: (Object? val) {
                            Navigator.of(context).pop();
                          },
                          onCancel: () {
                            pickedDate = null;
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _controller.text = _formatDate(pickedDate!);
      });
      widget.onDateSelected(pickedDate!);
    }
  }



/*
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
              primary: AppColors.secondary, // Header background color
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
*/

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
    String _toCamelCase(String text) {
      if (text.isEmpty) return text;

      return text
          .split(' ')
          .map((word) =>
      word.isNotEmpty
          ? word[0].toUpperCase() + word.substring(1).toLowerCase()
          : '')
          .join(' ');
    }
    return SizedBox(
      width: fieldWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_toCamelCase(widget.label),
              style:  TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.primary
              ,  fontSize: ResponsiveUtils.fontSize(context, 14)
              )),
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
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Tooltip(
                      message: 'Tap to select Date.',
                      decoration: BoxDecoration(color: AppColors.secondary,borderRadius: BorderRadius.circular( 8)),

                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(Icons.calendar_month_outlined,color: AppColors.primary,size: 20,),
                      ),
                    ),
                  ))
            ],
          ),
        ],
      ),
    );
  }
}