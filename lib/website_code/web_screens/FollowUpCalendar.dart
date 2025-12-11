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
import 'DashboardScreen.dart';

class FollowUpCalendar extends StatefulWidget {
  const FollowUpCalendar({super.key});

  @override
  State<FollowUpCalendar> createState() => _FollowUpCalendarState();
}

class _FollowUpCalendarState extends State<FollowUpCalendar> with SingleTickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<FollowUp>> _followUpsMap = {};
  Map<DateTime, List<FollowUp>> _nextFollowUpsMap = {};
  bool _isLoading = false;
  late TabController _tabController;
  List<FollowUp> _selectedDateFollowUps = [];
  List<FollowUp> _selectedDateNextFollowUps = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _tabController = TabController(length: 2, vsync: this);
    _fetchFollowUpsForMonth(DateTime.now());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          // After loading data, update selected date details
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

        // Add to follow-ups map (ONLY THIS ONE WILL BE USED FOR CALENDAR EVENTS)
        DateTime followUpDate = DateTime.parse(item['follow_up_dates']).toLocal();
        DateTime followUpKey = DateTime(followUpDate.year, followUpDate.month, followUpDate.day);

        if (!_followUpsMap.containsKey(followUpKey)) {
          _followUpsMap[followUpKey] = [];
        }
        _followUpsMap[followUpKey]!.add(followUp);

        // Add to next follow-ups map (FOR TAB VIEW ONLY)
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
        mainAxisSize: MainAxisSize.min, // Changed to min to avoid infinite height
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
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary,))
              : TableCalendar(
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
              // ONLY SHOW FOLLOW-UPS, NOT NEXT FOLLOW-UPS
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

          // Selected Date Details Section
          const SizedBox(height: 20),
          Text(
            'Details for ${DateFormat('MMM dd, yyyy').format(_selectedDay ?? DateTime.now())}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),

          // Tab Bar for Follow Ups and Next Follow Ups
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey[600],
              indicator: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              tabs: const [
                Tab(text: 'Follow Ups'),
                //   Tab(text: 'Next Follow Ups'),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Tab Bar View Content - Added constrained height
          SizedBox(
            height: 500, // Fixed height for the tab content
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFollowUpList(_selectedDateFollowUps, true),
                _buildFollowUpList(_selectedDateNextFollowUps, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpList(List<FollowUp> followUps, bool isCurrent) {
    if (followUps.isEmpty) {
      return Center(
        child: Text(
          'No ${isCurrent ? 'follow ups' : 'next follow ups'} for this date',
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return // Alternative: Single item showing both dates
      ListView.builder(
        itemCount: followUps.length,
        itemBuilder: (context, index) {
          final followUp = followUps[index];

          final currentDateFormatted = DateFormat('MMM dd, yyyy').format(followUp.followUpDate);
          final nextDateFormatted = DateFormat('MMM dd, yyyy').format(followUp.nextFollowUpDate);

          final isCurrentToday = isSameDay(followUp.followUpDate, DateTime.now());
          final isNextToday = isSameDay(followUp.nextFollowUpDate, DateTime.now());

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: FollowUpItem(
              name: followUp.name,
              currentDate: currentDateFormatted,
              nextDate: nextDateFormatted,
              phone: followUp.mobileNo,
              index: '${index + 1}',
              isCurrentToday: isCurrentToday,
              isNextToday: isNextToday,
            ),
          );
        },
      );
  }
}

class FollowUpDetailsDialog extends StatefulWidget {
  final DateTime selectedDate;
  final List<FollowUp> followUps;
  final List<FollowUp> nextFollowUps;

  const FollowUpDetailsDialog({
    super.key,
    required this.selectedDate,
    required this.followUps,
    required this.nextFollowUps,
  });

  @override
  State<FollowUpDetailsDialog> createState() => _FollowUpDetailsDialogState();
}

class _FollowUpDetailsDialogState extends State<FollowUpDetailsDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Follow Ups - ${DateFormat('MMM dd, yyyy').format(widget.selectedDate)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Follow Ups'),
                Tab(text: 'Next Follow Ups'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDialogFollowUpList(widget.followUps, true),
                  _buildDialogFollowUpList(widget.nextFollowUps, false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogFollowUpList(List<FollowUp> followUps, bool isCurrent) {
    if (followUps.isEmpty) {
      return Center(
        child: Text(
          'No ${isCurrent ? 'follow ups' : 'next follow ups'} for this date',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: followUps.length,
      itemBuilder: (context, index) {
        final followUp = followUps[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isCurrent ? AppColors.primary : AppColors.secondary,
              child: Text(
                '${index + 1}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              'Patient ID: ${followUp.patientId}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Follow-up: ${DateFormat('MMM dd, yyyy').format(followUp.followUpDate)}'),
                Text('Next: ${DateFormat('MMM dd, yyyy').format(followUp.nextFollowUpDate)}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: () {
                _showPatientDetails(followUp);
              },
            ),
          ),
        );
      },
    );
  }

  void _showPatientDetails(FollowUp followUp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Patient ID: ${followUp.patientId}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Follow-up Date: ${DateFormat('MMM dd, yyyy').format(followUp.followUpDate)}'),
            Text('Next Follow-up: ${DateFormat('MMM dd, yyyy').format(followUp.nextFollowUpDate)}'),
            const SizedBox(height: 16),
            Text('Status: ${followUp.followUpDate.isBefore(DateTime.now()) ? 'Completed' : 'Upcoming'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// FollowUpItem Widget (as per your design)
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
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHovered
                ? AppColors.primary
                : AppColors.hinttext.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'FollowUp ${widget.index}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveUtils.fontSize(context, 16),
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  textAlign: TextAlign.center,
                  widget.currentDate,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isHovered
                        ? AppColors.primary
                        : AppColors.secondary,
                    fontSize: ResponsiveUtils.fontSize(context, 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveUtils.fontSize(context, 14),
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Next Follow Up Scheduled: ${widget.nextDate}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveUtils.fontSize(context, 12),
                color: isHovered
                    ? AppColors.primary
                    : AppColors.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.call,
                  color: AppColors.primary,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.phone,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveUtils.fontSize(context, 12),
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// FollowUp Model Class
// follow_up_model.dart

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'name': name,
      'mobile_no': mobileNo,
      'follow_up_dates': followUpDate.toUtc().toIso8601String(),
      'next_follow_up_dates': nextFollowUpDate.toUtc().toIso8601String(),
    };
  }

  FollowUp copyWith({
    int? id,
    int? patientId,
    String? name,
    String? mobileNo,
    DateTime? followUpDate,
    DateTime? nextFollowUpDate,
  }) {
    return FollowUp(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      name: name ?? this.name,
      mobileNo: mobileNo ?? this.mobileNo,
      followUpDate: followUpDate ?? this.followUpDate,
      nextFollowUpDate: nextFollowUpDate ?? this.nextFollowUpDate,
    );
  }

  @override
  String toString() {
    return 'FollowUp(id: $id, patientId: $patientId, name: $name, mobileNo: $mobileNo, followUpDate: $followUpDate, nextFollowUpDate: $nextFollowUpDate)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is FollowUp &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              patientId == other.patientId &&
              name == other.name &&
              mobileNo == other.mobileNo &&
              followUpDate == other.followUpDate &&
              nextFollowUpDate == other.nextFollowUpDate;

  @override
  int get hashCode =>
      id.hashCode ^
      patientId.hashCode ^
      name.hashCode ^
      mobileNo.hashCode ^
      followUpDate.hashCode ^
      nextFollowUpDate.hashCode;
}

class FollowUpResponse {
  final bool status;
  final String message;
  final List<FollowUp> data;

  FollowUpResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory FollowUpResponse.fromJson(Map<String, dynamic> json) {
    return FollowUpResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((item) => FollowUp.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'FollowUpResponse(status: $status, message: $message, data: $data)';
  }
}