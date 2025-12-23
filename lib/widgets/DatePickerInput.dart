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
    final isMobile = ResponsiveUtils.isMobile(context);
    if (!widget.enabled) return;



    DateTime? pickedDate = _selectedDate ?? DateTime.now(); // 👈 default to current date

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        final isMobile = MediaQuery.of(context).size.width < 600;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: isMobile ? MediaQuery.of(context).size.width * 0.95 : 700,
                  height: isMobile ? 450 : 500,
                  child: Column(
                    children: [
                      // ✅ Responsive Custom Calendar Header
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 8 : 12,
                          vertical: isMobile ? 6 : 8,
                        ),
                        color: AppColors.primary.withOpacity(0.1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Year Back Button
                            IconButton(
                              padding: EdgeInsets.only(right: isMobile ? 0 : 4),
                              constraints: BoxConstraints(
                                minWidth: isMobile ? 36 : 48,
                                minHeight: isMobile ? 36 : 48,
                              ),
                              icon: isMobile
                                  ? Icon(Icons.skip_previous, size: 20)
                                  : Text("<<", style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isMobile ? 14 : 18,
                              )),
                              onPressed: () {
                                setDialogState(() {
                                  _displayDate = DateTime(_displayDate.year - 1, _displayDate.month);
                                  _datePickerController.displayDate = _displayDate;
                                });
                              },
                            ),

                            // Month Back Button
                            IconButton(
                              padding: EdgeInsets.only(right: isMobile ? 0 : 4),
                              constraints: BoxConstraints(
                                minWidth: isMobile ? 36 : 48,
                                minHeight: isMobile ? 36 : 48,
                              ),
                              icon: isMobile
                                  ? Icon(Icons.chevron_left, size: 24)
                                  : Text("<", style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isMobile ? 14 : 18,
                              )),
                              onPressed: () {
                                setDialogState(() {
                                  _displayDate = DateTime(_displayDate.year, _displayDate.month - 1);
                                  _datePickerController.displayDate = _displayDate;
                                });
                              },
                            ),

                            // Month-Year Display
                            Expanded(
                              child: Center(
                                child: Text(
                                  DateFormat('MMMM yyyy').format(_displayDate),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isMobile ? 14 : 16,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),

                            // Month Forward Button
                            IconButton(
                              padding: EdgeInsets.only(left: isMobile ? 0 : 4),
                              constraints: BoxConstraints(
                                minWidth: isMobile ? 36 : 48,
                                minHeight: isMobile ? 36 : 48,
                              ),
                              icon: isMobile
                                  ? Icon(Icons.chevron_right, size: 24)
                                  : Text(">", style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isMobile ? 14 : 18,
                              )),
                              onPressed: () {
                                setDialogState(() {
                                  _displayDate = DateTime(_displayDate.year, _displayDate.month + 1);
                                  _datePickerController.displayDate = _displayDate;
                                });
                              },
                            ),

                            // Year Forward Button
                            IconButton(
                              padding: EdgeInsets.only(left: isMobile ? 0 : 4),
                              constraints: BoxConstraints(
                                minWidth: isMobile ? 36 : 48,
                                minHeight: isMobile ? 36 : 48,
                              ),
                              icon: isMobile
                                  ? Icon(Icons.skip_next, size: 20)
                                  : Text(">>", style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isMobile ? 14 : 18,
                              )),
                              onPressed: () {
                                setDialogState(() {
                                  _displayDate = DateTime(_displayDate.year + 1, _displayDate.month);
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
                          headerHeight: 0,
                          selectionMode: DateRangePickerSelectionMode.single,
                          initialSelectedDate: pickedDate,
                          showActionButtons: true,
                          controller: _datePickerController,
                          selectionColor: AppColors.secondary,
                          todayHighlightColor: AppColors.primary,
                          showNavigationArrow: false, // Hide default arrows since we have custom ones
                          monthViewSettings: DateRangePickerMonthViewSettings(
                            dayFormat: isMobile ? 'E' : 'EEE', // Shorter day names on mobile
                          ),

                          onSelectionChanged: (args) {
                            pickedDate = args.value as DateTime?;
                          },
                          onSubmit: (Object? val) {
                            if (pickedDate == null) {
                              pickedDate = DateTime.now();
                            }
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