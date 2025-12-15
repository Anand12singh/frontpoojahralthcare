import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:poojaheakthcare/utils/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants/base_url.dart';
import '../../constants/ResponsiveUtils.dart';
import '../../services/auth_service.dart';
import '../../widgets/showTopSnackBar.dart';

class Formobfollowupcalendar extends StatefulWidget {
  const Formobfollowupcalendar({super.key});

  @override
  State<Formobfollowupcalendar> createState() => _FormobfollowupcalendarState();
}

class _FormobfollowupcalendarState extends State<Formobfollowupcalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<FollowUp>> _followUpsMap = {};
  Map<DateTime, List<FollowUp>> _nextFollowUpsMap = {};
  bool _isLoading = false;
  List<FollowUp> _selectedDateFollowUps = [];
  List<FollowUp> _selectedDateNextFollowUps = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _fetchFollowUpsForMonth(DateTime.now());
  }

  Future<void> _fetchFollowUpsForMonth(DateTime month) async {
    setState(() {
      _isLoading = true;
    });

    try {
      String? token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        showTopRightToast(context, 'Authentication token not found. Please login again.');
        return;
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      String monthString = DateFormat('MM-yyyy').format(month);

      final response = await http.post(
        Uri.parse('$localurl/get_all_follow_up'),
        headers: headers,
        body: json.encode({"date": monthString}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          _processFollowUpData(responseData['data']);
          _updateSelectedDateDetails();
        }
      }
    } catch (e) {
      print('Error fetching follow-ups: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _processFollowUpData(List<dynamic> data) {
    _followUpsMap.clear();
    _nextFollowUpsMap.clear();

    for (var item in data) {
      try {
        final followUp = FollowUp.fromJson(item);

        // Add to follow-ups map
        DateTime followUpDate = DateTime.parse(item['follow_up_dates']).toLocal();
        DateTime followUpKey = DateTime(followUpDate.year, followUpDate.month, followUpDate.day);

        if (!_followUpsMap.containsKey(followUpKey)) {
          _followUpsMap[followUpKey] = [];
        }
        _followUpsMap[followUpKey]!.add(followUp);

        // Add to next follow-ups map
        DateTime nextFollowUpDate = DateTime.parse(item['next_follow_up_dates']).toLocal();
        DateTime nextFollowUpKey = DateTime(nextFollowUpDate.year, nextFollowUpDate.month, nextFollowUpDate.day);

        if (!_nextFollowUpsMap.containsKey(nextFollowUpKey)) {
          _nextFollowUpsMap[nextFollowUpKey] = [];
        }
        _nextFollowUpsMap[nextFollowUpKey]!.add(followUp);
      } catch (e) {
        print('Error processing follow-up data: $e');
      }
    }

    setState(() {});
  }

  List<FollowUp> _getFollowUpsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _followUpsMap[key] ?? [];
  }

  List<FollowUp> _getNextFollowUpsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _nextFollowUpsMap[key] ?? [];
  }

  void _updateSelectedDateDetails() {
    if (_selectedDay != null) {
      setState(() {
        _selectedDateFollowUps = _getFollowUpsForDay(_selectedDay!);
        _selectedDateNextFollowUps = _getNextFollowUpsForDay(_selectedDay!);
      });
    }
  }

  void _onDateSelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedDateFollowUps = _getFollowUpsForDay(selectedDay);
      _selectedDateNextFollowUps = _getNextFollowUpsForDay(selectedDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.hinttext.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Follow Up Calendar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Calendar Section
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.hinttext.withOpacity(0.2),
                    ),
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.now().subtract(const Duration(days: 365)),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: _onDateSelected,
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                      _fetchFollowUpsForMonth(focusedDay);
                    },
                    eventLoader: (day) {
                      return _getFollowUpsForDay(day);
                    },
                    calendarStyle: CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      markerSize: 4,
                      markersAlignment: Alignment.bottomCenter,
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(color: AppColors.primary),
                      weekendStyle: TextStyle(color: AppColors.secondary),
                    ),
                  ),
                ),

          const SizedBox(height: 20),
          
          // Selected Date Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Follow Ups for ${DateFormat('MMM dd, yyyy').format(_selectedDay ?? DateTime.now())}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Today's Follow Ups Section
          if (_selectedDateFollowUps.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Today\'s Follow Ups',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_selectedDateFollowUps.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _selectedDateFollowUps.length,
                  itemBuilder: (context, index) {
                    final followUp = _selectedDateFollowUps[index];
                    final currentDateFormatted = DateFormat('MMM dd, yyyy').format(followUp.followUpDate);
                    final nextDateFormatted = DateFormat('MMM dd, yyyy').format(followUp.nextFollowUpDate);
                    final isCurrentToday = isSameDay(followUp.followUpDate, DateTime.now());

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: FollowUpItem(
                        name: followUp.name,
                        currentDate: currentDateFormatted,
                        nextDate: nextDateFormatted,
                        phone: followUp.mobileNo,
                        index: '${index + 1}',
                        isCurrentToday: isCurrentToday,
                        isNextToday: false,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),

          // Next Follow Ups Section
          if (_selectedDateNextFollowUps.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Next Follow Ups',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_selectedDateNextFollowUps.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _selectedDateNextFollowUps.length,
                  itemBuilder: (context, index) {
                    final followUp = _selectedDateNextFollowUps[index];
                    final currentDateFormatted = DateFormat('MMM dd, yyyy').format(followUp.followUpDate);
                    final nextDateFormatted = DateFormat('MMM dd, yyyy').format(followUp.nextFollowUpDate);
                    final isNextToday = isSameDay(followUp.nextFollowUpDate, DateTime.now());

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: FollowUpItem(
                        name: followUp.name,
                        currentDate: currentDateFormatted,
                        nextDate: nextDateFormatted,
                        phone: followUp.mobileNo,
                        index: '${index + 1}',
                        isCurrentToday: false,
                        isNextToday: isNextToday,
                      ),
                    );
                  },
                ),
              ],
            ),

          // Empty State
          if (_selectedDateFollowUps.isEmpty && _selectedDateNextFollowUps.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon(
                  //   Icons.calendar_today_outlined,
                  //   color: Colors.grey[400],
                  //   size: 60,
                  // ),
                  // const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'No follow ups for this date',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                  // const SizedBox(height: 8),
                  // Text(
                  //   'Select another date to view follow ups',
                  //   style: TextStyle(
                  //     color: Colors.grey[500],
                  //     fontSize: 14,
                  //   ),
                  // ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// FollowUpItem Widget - Optimized for mobile
class FollowUpItem extends StatefulWidget {
  final String name;
  final String currentDate;
  final String nextDate;
  final String phone;
  final String index;
  final bool isCurrentToday;
  final bool isNextToday;

  const FollowUpItem({
    Key? key,
    required this.name,
    required this.currentDate,
    required this.nextDate,
    required this.phone,
    required this.index,
    required this.isCurrentToday,
    required this.isNextToday,
  }) : super(key: key);

  @override
  State<FollowUpItem> createState() => _FollowUpItemState();
}

class _FollowUpItemState extends State<FollowUpItem> {
  bool isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isTapped = true),
      onTapUp: (_) => setState(() => isTapped = false),
      onTapCancel: () => setState(() => isTapped = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isTapped ? AppColors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (widget.isCurrentToday || widget.isNextToday)
                ? AppColors.primary
                : AppColors.hinttext.withOpacity(0.2),
            width: (widget.isCurrentToday || widget.isNextToday) ? 1.5 : 1.0,
          ),
          boxShadow: isTapped
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      widget.index,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.currentDate,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: widget.isCurrentToday
                            ? AppColors.primary
                            : AppColors.secondary,
                      ),
                    ),
                    if (widget.isCurrentToday)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'TODAY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.phone,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.phone,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.secondary.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: AppColors.secondary,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Next: ${widget.nextDate}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  if (widget.isNextToday)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Keep your existing FollowUp model class and other classes as they are
class FollowUp {
  final int id;
  final int patientId;
  final String name;
  final String mobileNo;
  final DateTime followUpDate;
  final DateTime nextFollowUpDate;

  FollowUp({
    required this.id,
    required this.patientId,
    required this.name,
    required this.mobileNo,
    required this.followUpDate,
    required this.nextFollowUpDate,
  });

  factory FollowUp.fromJson(Map<String, dynamic> json) {
    return FollowUp(
      id: json['id'] as int,
      patientId: json['patient_id'] as int,
      name: json['name'] as String,
      mobileNo: json['mobile_no'] as String,
      followUpDate: DateTime.parse(json['follow_up_dates'] as String).toLocal(),
      nextFollowUpDate: DateTime.parse(json['next_follow_up_dates'] as String).toLocal(),
    );
  }
}