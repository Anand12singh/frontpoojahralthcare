import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:poojaheakthcare/constants/base_url.dart';
import 'package:poojaheakthcare/constants/global_variable.dart';
import 'package:poojaheakthcare/screens/patient_list.dart';
import '../utils/colors.dart';
import '../widgets/custom_text_field.dart';
import 'patient_form_screen.dart';

// Date formatting helper
String _formatLastVisitDate(String dateString) {
  try {
    final date = DateTime.parse(dateString);
    final monthNames = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return "${date.day} ${monthNames[date.month - 1]} ${date.year}";
  } catch (e) {
    return dateString;
  }
}

class PatientInfoScreen extends StatefulWidget {
  const PatientInfoScreen({Key? key}) : super(key: key);

  @override
  State<PatientInfoScreen> createState() => _PatientInfoScreenState();
}

class _PatientInfoScreenState extends State<PatientInfoScreen>
    with SingleTickerProviderStateMixin {
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // State variables
  bool _isSubmitting = false;
  bool _isLoadingPatients = true;
  List<dynamic> _recentPatients = [];
  int _selectedGender = 1;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fetchRecentPatients();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: kIsWeb ? 500 : 800),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, kIsWeb ? 0.1 : 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: kIsWeb ? 0.98 : 0.95,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0,
            curve: kIsWeb ? Curves.easeOut : Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  Future<void> _fetchRecentPatients() async {
    try {
      final headers = {
        'Accept': 'application/json',
      };

      final response = await http.get(
        Uri.parse('$localurl/get_allpatients'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _recentPatients = responseData['data'] ?? [];
          _isLoadingPatients = false;
        });
      } else {
        setState(() => _isLoadingPatients = false);
        _showErrorSnackbar('Failed to load recent patients');
      }
    } catch (e) {
      setState(() => _isLoadingPatients = false);
      _showErrorSnackbar('Error: ${e.toString()}');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      final headers = {
        'Content-Type': 'application/json',
      };

      final response = await http.post(
        Uri.parse('$localurl/checkpatientinfo'),
        headers: headers,
        body: json.encode({
          "first_name": _nameController.text.trim(),
          "last_name": _lastnameController.text.trim(),
          "mobile_no": _phoneController.text.trim(),
        }),
      );

      // log('API Response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          _handleSuccessResponse(responseData);
        } else {
          _showErrorSnackbar(responseData['message'] ?? 'Submission failed');
        }
      } else {
        _showErrorSnackbar('API Error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackbar('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _handleSuccessResponse(Map<String, dynamic> responseData) {
    final data = responseData['data'][0];
    int patientExist = data['patientExist'] ?? 0;
    String? phid = data['patient_id']?.toString() ?? 'NA';
    String? phid1 = data['phid']?.toString() ?? 'NA';

    setState(() {
      Global.status = patientExist.toString();
      Global.patient_id = phid;
      Global.phid = phid;
      Global.phid1 = phid1;
    });
    log('Patient Exist: $patientExist, PHID: $phid');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientFormScreen(
          firstName: _nameController.text.trim(),
          lastName: _lastnameController.text.trim(),
          phone: _phoneController.text.trim(),
          patientExist: patientExist,
          phid: phid,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildGenderOption(int value, String label, IconData icon) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: _selectedGender == value
                ? AppColors.primary.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _selectedGender == value
                  ? AppColors.primary
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: _selectedGender == value
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: _selectedGender == value
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: _selectedGender == value
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentPatientCard(Map<String, dynamic> patient) {
    final gender = patient['gender'] ?? 1;
    final icon = gender == 1
        ? Icons.male
        : gender == 2
            ? Icons.female
            : Icons.transgender;
    final formattedDate = _formatLastVisitDate(patient['date'] ?? '');
    final visitInfo = patient['last_visit_place']?.isNotEmpty == true
        ? '$formattedDate • ${patient['last_visit_place']}'
        : formattedDate;

    return GestureDetector(
      onTap: () {
        setState(() {
          _nameController.text = patient['first_name'] ?? '';
          _lastnameController.text = patient['last_name'] ?? '';
          _phoneController.text =
              (patient['mobile_no'] ?? '').replaceAll(RegExp(r'[^0-9]'), '');
          _selectedGender = gender;
        });
      },
      child: Container(
        // width: kIsWeb ? 280 : 180,
        width: 180,

        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, AppColors.primary.withOpacity(0.03)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ],
          border:
              Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${patient['first_name'] ?? ''} ${patient['last_name'] ?? ''}",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone,
                    size: 14, color: AppColors.textSecondary.withOpacity(0.7)),
                const SizedBox(width: 6),
                Text(
                  patient['mobile_no'] ?? '',
                  style:
                      TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 14, color: AppColors.textSecondary.withOpacity(0.7)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    visitInfo,
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary.withOpacity(0.7)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPatientsSection() {
    if (_isLoadingPatients) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_recentPatients.isEmpty) return Container();
    final patientCount = _recentPatients.length;
    final showCount = kIsWeb
        ? (patientCount > 8 ? 8 : patientCount)
        : (patientCount > 3 ? 3 : patientCount);
    final shouldCenter = kIsWeb && showCount < 6;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(Icons.history, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  'Recent Patients',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
              ],
            ),
            TextButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RecentPatientsListScreen())),
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero),
              child: Row(
                children: [
                  Text('View More',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              scrollbars: true,
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              },
            ),
            child: shouldCenter
                ? Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _recentPatients
                          .take(showCount)
                          .map((patient) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                child: _buildRecentPatientCard(patient),
                              ))
                          .toList(),
                    ),
                  )
                : ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: _recentPatients
                        .take(showCount)
                        .map((patient) => Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: _buildRecentPatientCard(patient),
                            ))
                        .toList(),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPatientFormCard() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: LayoutBuilder(builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                  // maxWidth: kIsWeb ? constraints.maxWidth * 0.5 : 600,
                  maxWidth: 600),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      AppColors.primary.withOpacity(0.03),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.person_add_alt_1,
                                  color: AppColors.primary, size: 28),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'New Patient',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        CustomTextField(
                          controller: _nameController,
                          label: 'First Name',
                          prefixIcon: Icons.person_outline,
                          textInputAction: TextInputAction.next,
                          validator: (value) => value?.isEmpty ?? true
                              ? 'Please enter patient name'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        CustomTextField(
                          controller: _lastnameController,
                          label: 'Last Name',
                          prefixIcon: Icons.person_outline,
                          textInputAction: TextInputAction.next,
                          validator: (value) => value?.isEmpty ?? true
                              ? 'Please enter patient name'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            if (value?.isEmpty ?? true)
                              return 'Please enter phone number';
                            if (!RegExp(r'^[0-9]{10}$').hasMatch(value!))
                              return 'Enter a valid 10-digit number';
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                              shadowColor: AppColors.primary.withOpacity(0.3),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 3, color: Colors.white),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Continue',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward,
                                          size: 20, color: Colors.white),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(),
                child: Padding(
                  padding: const EdgeInsets.only(right: 32),
                  child: Column(
                    children: [
                      _buildPatientFormCard(),
                      const SizedBox(height: 32),
                      _buildRecentPatientsSection(),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildPatientFormCard(),
          const SizedBox(height: 32),
          _buildRecentPatientsSection(),
          const SizedBox(height: 100),
          Align(
            alignment: Alignment.bottomCenter,
            child: Text('App Version 1.0.1', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: AppColors.medicalBlue.withOpacity(.2),
      appBar: AppBar(
        title: const Text('Patient Registration'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: kIsWeb
            ? null
            : const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Container(
                  constraints: BoxConstraints(maxHeight: constraints.maxHeight),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: kIsWeb && isLargeScreen
                      ? _buildDesktopLayout()
                      : _buildMobileLayout(),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
