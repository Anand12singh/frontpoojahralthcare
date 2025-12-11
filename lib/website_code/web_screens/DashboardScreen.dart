import 'dart:convert';
import 'dart:developer';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:poojaheakthcare/utils/colors.dart';
import 'package:http/http.dart' as http;
import 'package:poojaheakthcare/widgets/showTopSnackBar.dart';
import '../../constants/ResponsiveUtils.dart';
import '../../constants/base_url.dart';
import '../../constants/global_variable.dart';
import '../../models/DashboardResponseModel.dart';
import '../../provider/PermissionService.dart';
import '../../screens/olddpatientfom.dart';
import '../../services/api_services.dart';
import '../../services/auth_service.dart';
import '../../widgets/AnimatedButton.dart';
import '../../widgets/custom_text_field.dart';
import 'CustomSidebar.dart';
import 'FollowUpCalendar.dart';
import 'Home_Screen.dart';
import 'PatientDataTabsScreen.dart';
import 'SearchBar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool isHovered = false;
  List<FollowUp> followUps = [];
  bool isLoadingFollowUps = false;
  String selectedMonth = DateFormat('MM-yyyy').format(DateTime.now());
  int _touchedIndex = -1;
  DashboardResponse? dashboard;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeData();
    _fetchFollowUps(); // Fetch follow-ups on init
    fetchDashboardData(); // Fetch follow-ups on init
  }
  Future<void> fetchDashboardData() async {
    try {
      setState(() {
        // Set loading state if you have one
      });

      await APIManager().apiRequest(
        context,
        API.getdashbord,
        params: {},
        onSuccess: (responseBody) {
          try {
            final data = json.decode(responseBody);
            if (data['status'] == true) {
              setState(() {
                dashboard = DashboardResponse.fromJson(data); // Use already decoded data
              });
            } else {
              // Handle API success but false status
              print('API returned false status: ${data['message']}');
              _showErrorSnackbar(data['message'] ?? 'Failed to load dashboard data');
            }
          } catch (e) {
            print('Error parsing response: $e');
            _showErrorSnackbar('Error parsing dashboard data');
          }
        },
        onFailure: (error) {
          print('API failure: $error');
          _showErrorSnackbar('Failed to load dashboard data: $error');
        },
      );
    } catch (e) {
      print('Unexpected error: $e');
      _showErrorSnackbar('Unexpected error loading dashboard');
    } finally {
      setState(() {
        // Reset loading state if you have one
      });
    }
  }



  Future<void> _fetchFollowUps() async {
    setState(() {
      isLoadingFollowUps = true;
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

      final response = await http.post(
        Uri.parse('$localurl/get_all_follow_up'),
        headers: headers,
        body: json.encode({
          "date": selectedMonth,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          List<FollowUp> fetchedFollowUps = [];
          for (var item in responseData['data']) {
            fetchedFollowUps.add(FollowUp.fromJson(item));
          }
          setState(() {
            followUps = fetchedFollowUps;
          });
        } else {
          print(responseData['message']);
         // showTopRightToast(context, responseData['message'] ?? 'Failed to fetch follow-ups');
        }
      } else {
        print('API Error: ${response.statusCode}');
       // showTopRightToast(context, 'API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: ${e.toString()}');
      //showTopRightToast(context, 'Error: ${e.toString()}');
    } finally {
      setState(() {
        isLoadingFollowUps = false;
      });
    }
  }

  Future<void> _initializeData() async {

    WidgetsFlutterBinding.ensureInitialized();
    PermissionService().initialize();
  }
  final List<Map<String, String>> bookmarksData = const [
    {
      'patientName': 'Gretchen O\'Kon, M/31',
      'diagnosis': 'Lorem Ipsum Lorem Ipsum',
      'summary': 'Lorem Ipsum Lorem Ipsum'
    },
    {
      'patientName': 'Whitney Hettinger, F/22',
      'diagnosis': 'Lorem Ipsum Lorem Ipsum',
      'summary': 'Lorem Ipsum Lorem Ipsum'
    },
    {
      'patientName': 'Leroy Auer, M/32',
      'diagnosis': 'Lorem Ipsum Lorem Ipsum',
      'summary': 'Lorem Ipsum Lorem Ipsum'
    },
    {
      'patientName': 'Gilbert Rogahn, F/46',
      'diagnosis': 'Lorem Ipsum Lorem Ipsum',
      'summary': 'Lorem Ipsum Lorem Ipsum'
    },
    {
      'patientName': 'Leroy Auer, M/54',
      'diagnosis': 'Lorem Ipsum Lorem Ipsum',
      'summary': 'Lorem Ipsum Lorem Ipsum'
    },
    {
      'patientName': 'Gilbert Rogahn, F/37',
      'diagnosis': 'Lorem Ipsum Lorem Ipsum',
      'summary': 'Lorem Ipsum Lorem Ipsum'
    },
    {
      'patientName': 'Ms. Luz Hueis, M/44',
      'diagnosis': 'Lorem Ipsum Lorem Ipsum',
      'summary': 'Lorem Ipsum Lorem Ipsum'
    },
  ];
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;


 void _AddPatientsubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _isSubmitting = true;
    });
    FocusScope.of(context).unfocus();

    try {
      String? token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        Navigator.of(context).pop();
        showTopRightToast(
            context, 'Authentication token not found. Please login again.');
        return;
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Cookie':
        'connect.sid=s%3AuEDYQI5oGhq5TztFK-F_ivqibtXxbspe.L65SiGdo4p4ZZY01Vnqd9tb4d64NFnzksLXndIK5zZA'
      };

      final response = await http.post(
        Uri.parse('$localurl/add_patient'),
        headers: headers,
        body: json.encode({
          "first_name": _nameController.text.trim(),
          "last_name": _lastnameController.text.trim(),
          "mobile_no": _phoneController.text.trim(),
        }),
      );

      log('API Response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          _isLoading = false;
          _handleSuccessResponse(responseData);
        } else {
          _isLoading = false;
          _showErrorSnackbar(responseData['message'] ?? 'Patient already exists.');
        }
      } else {
        _isLoading = false;
        _showErrorSnackbar('API Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isSubmitting = false;
      });
      _showErrorSnackbar('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSubmitting = false;
        });
      }
    }
  }
  void _showErrorSnackbar(String message) {
    showTopRightToast(context,message,backgroundColor: Colors.red);

  }

  ScreenSize get screenSize {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final height = mediaQuery.size.height;

    if (width <= 1366 || height <= 768) {
      return ScreenSize.small;
    } else if (width <= 1920 || height <= 1080) {
      return ScreenSize.medium;
    } else {
      return ScreenSize.large;
    }
  }

  // Get chart dimensions based on screen size
  ChartDimensions get chartDimensions {
    switch (screenSize) {
      case ScreenSize.small:
        return ChartDimensions(
          containerHeight: 230,
          centerSpaceRadius: 20,
          touchedRadius: 62,
          normalRadius: 50,
          titleFontSize: 12,
          smallFontSize: 8,
        );
      case ScreenSize.medium:
        return ChartDimensions(
          containerHeight: 250,
          centerSpaceRadius: 30,
          touchedRadius: 72,
          normalRadius: 60,
          titleFontSize: 13,
          smallFontSize: 10,
        );
      case ScreenSize.large:
        return ChartDimensions(
          containerHeight: 280,
          centerSpaceRadius: 40,
          touchedRadius: 82,
          normalRadius: 70,
          titleFontSize: 14,
          smallFontSize: 12,
        );
    }
  }


  Future<void> _handleSuccessResponse(Map<String, dynamic> responseData) async {
    try {
      final data = responseData['data'][0];
      int patientExist = data['patientExist'] ?? 0;
      String? phid = data['patient_id']?.toString() ?? 'NA';
      String? phid1 = data['phid']?.toString() ?? 'NA';

      // Update global variables
      Global.status = patientExist.toString();
      Global.patient_id = phid;
      Global.phid = phid;
      Global.phid1 = phid1;

      // Update global patient data
      GlobalPatientData.firstName = _nameController.text.trim();
      GlobalPatientData.lastName = _lastnameController.text.trim();
      GlobalPatientData.phone = _phoneController.text.trim();
      GlobalPatientData.patientExist = patientExist;
      GlobalPatientData.phid = phid1;
      GlobalPatientData.patientId = phid;
      await GlobalPatientData.saveToPrefs();
      await GlobalPatientData.loadFromPrefs();
      log('Patient Exist: $patientExist, PHID: $phid, PHID1: $phid1');

      // Verify we have a valid phid before navigation
      if (phid1 != 'NA') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PatientDataTabsScreen(),
          ),
        );
      } else {
        throw Exception('Invalid patient ID received from API');
      }
    } catch (e) {
      log('Error in _handleSuccessResponse: $e');
      showTopRightToast(
        context,
        'Error processing patient data',
        backgroundColor: Colors.red,
      );
    }
  }

  void _showAddPatientModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            child: _addPatient(
              firstNameController: _nameController,
              lastNameController: _lastnameController,
              phoneController: _phoneController,
              isLoading: _isLoading,

              onPressed: () {
            /*    Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PatientDataTabsScreen(),
                  ),
                );*/
                Navigator.pop(context); // Close the modal
              },
            ),
          ),
        ),
      ),
    );
  }
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final dimensions = chartDimensions;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      body: Row(
        children: [

          Sidebar(),
          Expanded(
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 80),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isMobile ?   Row(

                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome Back,\nDr. Pooja",
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Here's what's happening\nwith your patients today.",
                                  style: TextStyle(fontSize: 16, color: AppColors.greycolor),
                                ),
                                SizedBox(height: 20),
                              ],
                            ),

                            Container(
                              width:ResponsiveUtils.scaleWidth(context, 160),

                              child:Animatedbutton(
                                title: '+ Add Patient',
                                isLoading: _isLoading,
                                onPressed: () {
                                  _showAddPatientModal(context);
                                },
                                backgroundColor: AppColors.secondary,
                                shadowColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ):
                         Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome Back, Dr. Ramesh Punjani",
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Here's what's happening with your patients today.",
                                  style: TextStyle(fontSize: 16, color: AppColors.greycolor),
                                ),
                                SizedBox(height: 20),
                              ],
                             ),

                             Visibility(
                               visible: PermissionService().canAddPatients,
                               child: Container(
                                 width:ResponsiveUtils.scaleWidth(context, 160),

                                 child:Animatedbutton(
                                   title: '+ Add Patient',
                                   isLoading: _isLoading,
                                   onPressed: () {
                                     _showAddPatientModal(context);
                                   },
                                   backgroundColor: AppColors.secondary,
                                   shadowColor: AppColors.primary,
                                 ),
                               ),
                             ),
                           ],
                         ),

                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Expanded(
                                flex: 7,
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Stats Cards - Horizontal Scroll
                                      SizedBox(
                                        height: 120,
                                        child: ListView(
                                          scrollDirection: Axis.horizontal,
                                          children: [
                                            _buildStatCard(
                                                "Total Operations",
                                                dashboard?.data.totalOperations ?? "0",
                                                'assets/Dashboardicon1.png'
                                            ),  const SizedBox(width: 16),
                                            _buildStatCard("Todays Follow Ups", "42", 'assets/Dashboardicon5.png'),
                                            const SizedBox(width: 16),
                                          /*  _buildStatCard("New Patients", "210", 'assets/Dashboardicon4.png'),
                                            const SizedBox(width: 16),
                                            _buildStatCard("Pending Reports", "12", 'assets/Dashboardicon3.png'),
                                            const SizedBox(width: 16),
                                            _buildStatCard("Total Appointment", "879", 'assets/Dashboardicon2.png'),
                                            const SizedBox(width: 16),*/
                                            _buildStatCard("Total Patients", "1222", 'assets/Dashboardicon1.png'),
                                          ],
                                        ),
                                      ),

                                 /*     const SizedBox(height: 20),

                                      // Bookmarks Section
                                      Container(
                                        height: 400,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AppColors.hinttext.withOpacity(0.2)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Bookmarks",
                                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(height: 16),
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(color: AppColors.hinttext.withOpacity(0.2)),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      // Table Header
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          color: AppColors.primary.withOpacity(0.1),
                                                          borderRadius: const BorderRadius.only(
                                                            topRight: Radius.circular(12),
                                                            topLeft: Radius.circular(12),
                                                          ),
                                                        ),
                                                        child: const Padding(
                                                          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
                                                          child: Row(
                                                            children: [
                                                              Expanded(flex: 2, child: Text("Patient name", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                                                              Expanded(flex: 2, child: Text("Diagnosis", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                                                              Expanded(flex: 2, child: Text("Summary", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                                                              Expanded(flex: 1, child: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                                                            ],
                                                          ),
                                                        ),
                                                      ),

                                                      // Table Rows
                                                      Expanded(
                                                        child: ListView(
                                                          children: [
                                                            _buildTableRow("Gretchen O'Kon, M/31", "Lorem Ipsum Lorem Ipsum", "Lorem Ipsum Lorem Ipsum"),
                                                            _buildDivider(),
                                                            _buildTableRow("Whitney Hettinger, F/22", "Lorem Ipsum Lorem Ipsum", "Lorem Ipsum Lorem Ipsum"),
                                                            _buildDivider(),
                                                            _buildTableRow("Leroy Auer, M/32", "Lorem Ipsum Lorem Ipsum", "Lorem Ipsum Lorem Ipsum"),
                                                            _buildDivider(),
                                                            _buildTableRow("Gilbert Rogahn, F/46", "Lorem Ipsum Lorem Ipsum", "Lorem Ipsum Lorem Ipsum"),
                                                            _buildDivider(),
                                                            _buildTableRow("Leroy Auer, M/54", "Lorem Ipsum Lorem Ipsum", "Lorem Ipsum Lorem Ipsum"),
                                                            _buildDivider(),
                                                            _buildTableRow("Gilbert Rogahn, F/37", "Lorem Ipsum Lorem Ipsum", "Lorem Ipsum Lorem Ipsum"),
                                                            _buildDivider(),
                                                            _buildTableRow("Ms. Luz Hueis, M/44", "Lorem Ipsum Lorem Ipsum", "Lorem Ipsum Lorem Ipsum"),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
*/
                                      const SizedBox(height: 20),

                                      // Pie Chart + Legend Section
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.hinttext.withOpacity(0.2)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 8,
                                          offset: Offset(2, 4),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                         Text(
                                          "Total Patients Operated - ${dashboard?.data.totalOperations ??0}",
                                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          spacing: 10,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            /// ----------- PIE CHART (Locations) ----------
                                            Expanded(
                                              flex: 5,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: AppColors.hinttext.withOpacity(0.2)),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.05),
                                                      blurRadius: 8,
                                                      offset: Offset(2, 4),
                                                    ),
                                                  ],
                                                ),
                                                padding: const EdgeInsets.all(16.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      "Location-wise Operations",
                                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        /// Pie Chart
                                                        Expanded(
                                                          flex: 5,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                       
                                                              SizedBox(
                                                                height: dimensions.containerHeight,
                                                                child: dashboard != null
                                                                    ? PieChart(
                                                                  PieChartData(
                                                                    sectionsSpace: 0,
                                                                    centerSpaceRadius: dimensions.centerSpaceRadius,
                                                                    pieTouchData: PieTouchData(
                                                                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                                                        setState(() {
                                                                          if (event is FlTapUpEvent || event is FlPanEndEvent) {
                                                                            _touchedIndex = -1;
                                                                          } else if (event is FlLongPressStart || event is FlPanStartEvent) {
                                                                            if (pieTouchResponse != null && pieTouchResponse.touchedSection != null) {
                                                                              _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                                                            }
                                                                          }
                                                                        });
                                                                      },
                                                                    ),
                                                                    sections: List.generate(
                                                                      dashboard!.data.surgeryByLocation.length,
                                                                          (i) {
                                                                        final loc = dashboard!.data.surgeryByLocation[i];
                                                                        final isTouched = i == _touchedIndex;
                                                                        final double radius = isTouched
                                                                            ? dimensions.touchedRadius
                                                                            : dimensions.normalRadius;
                                                                        final value = loc.totalNumber.toDouble();
                                                                        final title = value.toInt().toString();
                                                    
                                                                        // assign colors dynamically
                                                                        final colors = [
                                                                          [Colors.orange.shade200, Colors.orange.shade700],
                                                                          [Colors.blue.shade200, Colors.blue.shade700],
                                                                          [Colors.green.shade200, Colors.green.shade700],
                                                                          [Colors.purple.shade200, Colors.purple.shade700],
                                                                          [Colors.red.shade200, Colors.red.shade700],
                                                                          [Colors.teal.shade200, Colors.teal.shade700],
                                                                          [Colors.pink.shade200, Colors.pink.shade700],
                                                                          [Colors.indigo.shade200, Colors.indigo.shade700],
                                                                          [Colors.cyan.shade200, Colors.cyan.shade700],
                                                                          [Colors.amber.shade200, Colors.amber.shade700],
                                                    
                                                                        ];
                                                    
                                                                        final colorPair = colors[i % colors.length];
                                                    
                                                                        return PieChartSectionData(
                                                                          value: value,
                                                                          title: title,
                                                                          radius: radius,
                                                                          gradient: LinearGradient(
                                                                            colors: colorPair,
                                                                            begin: Alignment.topLeft,
                                                                            end: Alignment.bottomRight,
                                                                          ),
                                                                          borderSide: isTouched
                                                                              ? BorderSide(color: AppColors.primary, width: 1)
                                                                              : BorderSide(color: Colors.transparent, width: 0),
                                                                          titleStyle: TextStyle(
                                                                            fontSize: dimensions.titleFontSize,
                                                                            fontWeight: FontWeight.bold,
                                                                            color: Colors.white,
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                )
                                                                    : Center(child: CircularProgressIndicator()),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                    
                                                        /// Legenddashboard != null
                                                        //
                                                        dashboard != null
                                                            ? Center(
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(left: 20),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: List.generate(
                                                                dashboard!.data.surgeryByLocation.length,
                                                                    (i) {
                                                                  final loc = dashboard!.data.surgeryByLocation[i];
                                                                  final colors = [
                                                                    Colors.orange,
                                                                    Colors.blue,
                                                                    Colors.green,
                                                                    Colors.purple,
                                                                    Colors.red,
                                                                    Colors.teal,
                                                                    Colors.pink,
                                                                    Colors.indigo,
                                                                    Colors.cyan,
                                                                    Colors.amber,
                                                                  ];
                                                                  return buildLegendItem(colors[i % colors.length], loc.location,dimensions.titleFontSize);
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                            : Center(child: CircularProgressIndicator()),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),

                                            /// ----------- BAR CHART (Types) ----------
                                            Expanded(
                                              flex: 5,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: AppColors.hinttext.withOpacity(0.2)),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.05),
                                                      blurRadius: 8,
                                                      offset: Offset(2, 4),
                                                    ),
                                                  ],
                                                ),
                                                padding: const EdgeInsets.all(16.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      "Surgery Type Overview",
                                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    SizedBox(
                                                      height: dimensions.containerHeight,
                                             
                                                      child:dashboard != null
                                                          ?  BarChart(
                                                        BarChartData(
                                                          alignment: BarChartAlignment.spaceEvenly,
                                                          maxY: 1000,


                                                          barTouchData: BarTouchData(
                                                            enabled: true,
                                                            touchTooltipData: BarTouchTooltipData(
                                                              tooltipBgColor: Colors.white,
                                                              tooltipPadding: const EdgeInsets.all(8),
                                                              tooltipMargin: 8,
                                                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                                                return BarTooltipItem(
                                                                  '${rod.toY.toInt()}',
                                                                  const TextStyle(
                                                                    color: Colors.black,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 14,
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                          titlesData: FlTitlesData(

                                                            leftTitles: AxisTitles(
                                                              

                                                              
                                                              axisNameWidget: Container(
                                                                padding: const EdgeInsets.only(bottom:5,), // Add space between title and axis labels
                                                                child: Text(
                                                                  'Number of Patients',
                                                                  style: TextStyle(
                                                                    fontSize: 10  ,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: Colors.black,
                                                                  ),
                                                                ),
                                                              ),

                                                              sideTitles: SideTitles(
                                                                showTitles: true,
                                                                interval: 200,
                                                                getTitlesWidget: (value, meta) {
                                                                  return Text(value.toInt().toString(), style: TextStyle(fontSize: 10));
                                                                },
                                                                reservedSize: 30, // Increase reserved size to accommodate the title
                                                              ),
                                                            ),
                                                            bottomTitles: AxisTitles(
                                                              axisNameWidget: Text(
                                                                'Surgery Types',
                                                                style: TextStyle(
                                                                  fontSize: 10,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.black,
                                                                ),
                                                              ),
                                                              sideTitles: SideTitles(
                                                                showTitles: true,
                                                                getTitlesWidget: (value, meta) {
                                                                  final types = dashboard!.data.surgeryByType;
                                                                  if (value.toInt() < types.length) {
                                                                    return Text(types[value.toInt()].name,style: TextStyle(fontSize: dimensions.smallFontSize),);
                                                                  }
                                                                  return const Text("");
                                                                },
                                                                reservedSize: 30,
                                                              ),
                                                            ),
                                                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                                          ),
                                                          gridData: FlGridData(show: true),
                                                          borderData: FlBorderData(show: false),
                                                          barGroups: List.generate(
                                                            dashboard!.data.surgeryByType.length,
                                                                (i) {
                                                              final type = dashboard!.data.surgeryByType[i];
                                                              return BarChartGroupData(
                                                                x: i,
                                                                barRods: [
                                                                  BarChartRodData(
                                                                    toY: type.totalCount.toDouble(),
                                                                    width: 50,
                                                                    borderRadius: const BorderRadius.only(
                                                                      topLeft: Radius.circular(8),
                                                                      topRight: Radius.circular(8),
                                                                    ),
                                                                    color: AppColors.secondary,
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      )  : Center(child: CircularProgressIndicator()),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )



                                  ],
                                  ),
                                ),
                              ),


                              // Sidebar Column (20% width)
                              // In your DashboardScreen class, replace the Quick Actions section with:
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  margin: const EdgeInsets.only(left: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.hinttext.withOpacity(0.2)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Quick Actions",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      // Replace the old content with the calendar
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: FollowUpCalendar(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Searchbar(),
              ],
            ),
          ),
        ],
      ),
    );


  }
  Widget buildPieChart(List<SurgeryType> surgeryByType) {
    return PieChart(
      PieChartData(
        sections: surgeryByType.map((e) {
          return PieChartSectionData(
            value: e.totalCount.toDouble(),
            title: "${e.name}\n${e.totalCount}",
            radius: 60,
          );
        }).toList(),
      ),
    );
  }
  Widget buildBarChart(List<SurgeryLocation> surgeryByLocation) {
    return BarChart(
      BarChartData(
        barGroups: surgeryByLocation.asMap().entries.map((entry) {
          int index = entry.key;
          SurgeryLocation e = entry.value;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: e.totalNumber.toDouble(),
                width: 16,
                color: Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
            showingTooltipIndicators: [0],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= surgeryByLocation.length) return const SizedBox();
                return Text(
                  surgeryByLocation[value.toInt()].location,
                  style: const TextStyle(fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _addPatient({
    required TextEditingController firstNameController,
    required TextEditingController lastNameController,
    required TextEditingController phoneController,
    required bool isLoading,  // Added this parameter
    required VoidCallback onPressed,  // Added this parameter
  })
  {
    return Container(
      width: ResponsiveUtils.scaleWidth(context, 500),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Patient Registration',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C3B70),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Quickly onboard a patient into the system.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondary),
            ),
            const SizedBox(height: 24),
            _buildField('First Name', 'Enter first name',   [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')), // Only letters allowed
            ],firstNameController,    validator: (value) => value?.isEmpty ?? true
                ? 'Please enter patient name'
                : null,),
            const SizedBox(height: 16),
            _buildField('Last Name', 'Enter last name', [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')), // Only letters allowed
            ], lastNameController,validator: (value) => value?.isEmpty ?? true
                ? 'Please enter patient name'
                : null,),
            const SizedBox(height: 16),
            _buildField('Phone Number', 'Enter Phone Number', [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), // Only letters allowed
            ], phoneController,    validator: (value) {
              if (value?.isEmpty ?? true)
                return 'Please enter phone number';
              if (!RegExp(r'^[0-9]{10}$').hasMatch(value!))
                return 'Enter a valid 10-digit number';
              return null;
            },
              isMobileNumber: true
            ),
            const SizedBox(height: 24),
            Row(
              spacing: 10,
              children: [
                Expanded(

                  child: Animatedbutton(

                    title: 'Discard',
                    isLoading: isLoading,
                    onPressed: () {
                      _nameController.clear();
                      _lastnameController.clear();
                      _phoneController.clear();
                      Navigator.pop(context);
                    },
                    titlecolor:AppColors.red,
                    backgroundColor: Colors.white,
                    borderColor: AppColors.red,

                    shadowColor: AppColors.primary,
                  ),
                ),


                Visibility(
                   visible: PermissionService().canAddPatients,
                  child: Expanded(
                    child: Animatedbutton(
                      title: 'Add Patient',
                      isLoading: isLoading,
                      onPressed: _isSubmitting ? null : () => _AddPatientsubmit(),



                      backgroundColor: AppColors.secondary,
                      shadowColor: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget buildLegendItem(Color color, String text, dynamic fontsize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: fontsize)),
        ],
      ),
    );
  }
// Example of the _buildField method (you should have this implemented)
  Widget _buildField(
      String label,
      String hint,

  final List<TextInputFormatter>? inputFormatters,
      TextEditingController controller, {
        String? Function(String?)? validator,
        bool isMobileNumber = false, // Add this parameter
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        CustomTextField(
          controller: controller,
          hintText: hint,
          maxLength: isMobileNumber ? 10 : 100, // Set length based on field type
          inputFormatters:inputFormatters,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          validator: validator,

        ),
      ],
    );
  }





  Widget _buildStatCard(String title, String count, String assetPath) {
    return Container(
      width: 170,

      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.hinttext.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                count,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Image.asset(
                assetPath,
                height: 50,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
                fontSize: 14,
                color: AppColors.secondary,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(String patientName, String diagnosis, String summary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0,horizontal: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              patientName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(diagnosis),
          ),
          Expanded(
            flex: 2,
            child: Text(summary),
          ),
          Expanded(
            flex: 2,
            child: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Action menu logic
              },
            ),
          ),
        ],
      ),
    );
  }


  List<DropdownMenuItem<String>> _generateMonthOptions() {
    List<DropdownMenuItem<String>> items = [];
    DateTime now = DateTime.now();

    for (int i = -6; i <= 6; i++) {
      DateTime date = DateTime(now.year, now.month + i, 1);
      String value = DateFormat('MM-yyyy').format(date);
      String label = DateFormat('MMMM yyyy').format(date);

      items.add(DropdownMenuItem<String>(
        value: value,
        child: Text(label),
      ));
    }

    return items;
  }

  Widget _buildFollowUpItem(FollowUp followUp) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Patient ID: ${followUp.patientId}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text("Follow-up: ${DateFormat('MMM dd, yyyy').format(followUp.followUpDate)}"),
            Text("Next: ${DateFormat('MMM dd, yyyy').format(followUp.nextFollowUpDate)}"),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.backgroundColor
    );
  }
}

class FollowUpItem extends StatefulWidget {
  final String name;
  final String date;
  final String condition;
  final String phone;
  final String index;
  final bool isToday;

  const FollowUpItem({
    super.key,
    required this.name,
    required this.date,
    required this.condition,
    required this.phone,
    required this.index,
    required this.isToday,
  });

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
              spacing: 20,
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
                  widget.date,
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
            SizedBox(height: 4,),
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
              widget.condition,
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
class FollowUp {
  final int id;
  final int patientId;
  final DateTime followUpDate;
  final DateTime nextFollowUpDate;

  FollowUp({
    required this.id,
    required this.patientId,
    required this.followUpDate,
    required this.nextFollowUpDate,
  });

  factory FollowUp.fromJson(Map<String, dynamic> json) {
    return FollowUp(
      id: json['id'],
      patientId: json['patient_id'],
      followUpDate: DateTime.parse(json['follow_up_dates']).toLocal(),
      nextFollowUpDate: DateTime.parse(json['next_follow_up_dates']).toLocal(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is FollowUp &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}