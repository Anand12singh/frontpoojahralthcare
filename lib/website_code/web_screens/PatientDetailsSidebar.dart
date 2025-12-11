import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:hugeicons/hugeicons.dart';
import 'package:poojaheakthcare/widgets/AnimatedButton.dart';
import 'package:poojaheakthcare/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../constants/ResponsiveUtils.dart';
import '../../constants/base_url.dart';
import '../../constants/global_variable.dart';
import '../../provider/PermissionService.dart';
import '../../services/api_services.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';
import '../../widgets/showTopSnackBar.dart';
import 'Patient_Registration.dart';

class PatientDetailsSidebar extends StatefulWidget {
  final String patientId; // Add patientId parameter
  const PatientDetailsSidebar({super.key, required this.patientId});

  @override
  State<PatientDetailsSidebar> createState() => _PatientDetailsSidebarState();
}

class _PatientDetailsSidebarState extends State<PatientDetailsSidebar> {
  Map<String, dynamic>? patientData;
  bool isLoading = true;
  bool isCancleLoading = false;
  String errorMessage = '';
  String _basePhId = '';
  String _phIdYear = '';
  String _fullPhId = ''; // This will be PHID/YEAR

  // Summary controllers
  TextEditingController summaryController_A = TextEditingController(); // Plan A
  TextEditingController summaryController_B = TextEditingController(); // Plan B

  bool isAddingSummary = false;
  bool isEditingSummary = false;
  bool isEditingPlanA = false;
  bool isEditingPlanB = false;

  @override
  void initState() {
    super.initState();
    fetchPatientData();
    _initializePhId();
    WidgetsFlutterBinding.ensureInitialized();
    PermissionService().initialize();
  }

  void _initializeData() {
    fetchPatientData();
  }
  void _initializePhId() {
    // Get base PH ID
    _basePhId = '${GlobalPatientData.patientId == "NA" ? GlobalPatientData.phid : GlobalPatientData.patientId}';

    // Default to current year initially
    _phIdYear = DateTime.now().year.toString();

    // Create full PH ID
    _fullPhId = '$_basePhId/$_phIdYear';

    // Set controller text

  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final patientProvider = Provider.of<PatientProvider>(context, listen: true);

    if (patientProvider.needsRefresh) {
      patientProvider.clearRefresh();
      _initializeData();
    }
  }

  void refreshAll() {
    fetchPatientData();
    WidgetsFlutterBinding.ensureInitialized();
    PermissionService().initialize();
  }

  Future<void> fetchPatientData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    String? token = await AuthService.getToken();
    await APIManager().apiRequest(
      context,
      API.frontpatientbyid,
      params: {'id': widget.patientId},
      token: token,
      onSuccess: (responseBody) {
        final data = json.decode(responseBody);

        if (data['status'] == true && data['data'].isNotEmpty) {
          setState(() {
            patientData = data['data'][0];
            debugPrint("patientData: $patientData");
            print("patient Data");
            print(patientData);

            // Safely initialize summary controllers
            if (patientData!['summary'] != null && patientData!['summary'].isNotEmpty) {
              final summaryData = patientData!['summary'][0];
              summaryController_A.text = summaryData['summary_a'] ?? "";
              summaryController_B.text = summaryData['summary_b'] ?? "";
            } else {
              summaryController_A.text = "";
              summaryController_B.text = "";
            }

            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = data['message'] ?? 'Patient not found';
          });
        }
      },
      onFailure: (error) {
        setState(() {
          isLoading = false;
          errorMessage = 'Error: $error';
        });
      },
    );
  }

  String _getGenderText(int? genderCode) {
    switch (genderCode) {
      case 1:
        return 'Male';  // Changed from 'M'
      case 2:
        return 'Female'; // Changed from 'F'
      case 3:
        return 'Other';
      default:
        return '';
    }
  }

  String _getHistoryText() {
    if (patientData == null || patientData!['PatientVisitInfo'].isEmpty) {
      return 'No history';
    }

    final visitInfo = patientData!['PatientVisitInfo'][0];
    List<String> historyParts = [];

    if (visitInfo['history_of_dm_status'] == 1) {
      historyParts.add('DM');
    }
    if (visitInfo['hypertension_status'] == 1) {
      historyParts.add('Hypertension');
    }
    if (visitInfo['IHD_status'] == 1) {
      historyParts.add('IHD');
    }
    if (visitInfo['COPD_status'] == 1) {
      historyParts.add('COPD');
    }

    return historyParts.isEmpty ? 'No significant history' : historyParts.join(' | ');
  }

  String _getLocationText() {
    if (patientData == null || patientData!['patient'].isEmpty) return 'Unknown';

    final patient = patientData!['patient'][0];
    if (patient['location'] != null && patient['location'].isNotEmpty) {
      return patient['location'];
    }

    switch (patient['location']) {
      case 1:
        return 'Pooja Nursing Home';
      default:
        return 'Not specified';
    }
  }

  Future<void> addSummary() async {
    // Check if at least one summary is filled
    if (summaryController_A.text.isEmpty && summaryController_B.text.isEmpty) {
      showTopRightToast(
        context,
        'Please enter at least one summary',
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() => isAddingSummary = true);

    try {
      String? token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        Navigator.of(context).pop();
        showTopRightToast(
          context,
          'Authentication token not found. Please login again.',
          backgroundColor: Colors.red,
        );
        return;
      }

      await APIManager().apiRequest(
        context,
        API.summaryadd,
        params: {
          'patient_id': widget.patientId,
          "summary":" ",
          'summary_a': summaryController_A.text,
          'summary_b': summaryController_B.text,
        },
        token: token,
        onSuccess: (responseBody) {
          final data = json.decode(responseBody);
          if (data['status'] == true) {
            showTopRightToast(
              context,
              data['message'] ?? 'Summary added successfully',
              backgroundColor: Colors.green,
            );
            setState(() {
              isEditingSummary = false;
              isEditingPlanA = false;
              isEditingPlanB = false;
            });
            fetchPatientData();
          } else {
            showTopRightToast(
              context,
              data['message'] ?? 'Failed to add summary',
              backgroundColor: Colors.red,
            );
          }
        },
        onFailure: (error) {
          showTopRightToast(
            context,
            'Failed to add summary: $error',
            backgroundColor: Colors.red,
          );
        },
      );
    } catch (e) {
      showTopRightToast(
        context,
        'Error: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() {
        isAddingSummary = false;
      });
    }
  }

  String _getDisplayText(dynamic value) {
    return (value == null || value.toString().isEmpty)
        ? 'Not specified'
        : value.toString();
  }
  String _getFormattedPhId() {
    if (patientData == null || patientData!['patient'].isEmpty) {
      return 'Not specified';
    }

    final patient = patientData!['patient'][0];
    final phid = patient['phid']?.toString() ?? '';

    if (phid.isEmpty) return 'Not specified';

    // Extract year from created_at
    String year = '';
    if (patient['created_at'] != null) {
      try {
        final createdAt = DateTime.parse(patient['created_at'].toString());
        year = createdAt.year.toString();
      } catch (e) {
        print('Error parsing created_at: $e');
        year = DateTime.now().year.toString(); // fallback to current year
      }
    } else {
      year = DateTime.now().year.toString(); // fallback to current year
    }

    return '$phid/$year';
  }
  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator(
        color: AppColors.primary,
      ));
    }

    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage));
    }

    if (patientData == null) {
      return const Center(child: Text('No patient data available'));
    }

    final patient = patientData!['patient'][0];
    final roleList = patientData?['role'];
    final role = (roleList != null && roleList.isNotEmpty)
        ? roleList[0]
        : null;

    final dischargeInfo = patientData!['discharge_info'].isNotEmpty
        ? patientData!['discharge_info'][0]
        : null;
    final visitInfo = patientData!['PatientVisitInfo'].isNotEmpty
        ? patientData!['PatientVisitInfo'][0]
        : null;

    final summaryData = patientData!['summary'] != null &&
        patientData!['summary'].isNotEmpty
        ? patientData!['summary'][0]
        : null;

    return isMobile
        ? _buildMobileView(patient, role, dischargeInfo, visitInfo, summaryData, isMobile)
        : _buildDesktopView(patient, role, dischargeInfo, visitInfo, summaryData, isMobile);
  }

  Widget _buildMobileView(Map<String, dynamic> patient, Map<String, dynamic>? role,
      Map<String, dynamic>? dischargeInfo, Map<String, dynamic>? visitInfo,
      Map<String, dynamic>? summaryData, bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _sidebarCard(
            child: _buildPatientInfoSection(patient, role, dischargeInfo, visitInfo, summaryData, isMobile, true),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _sidebarCard(
            child: _buildContactSection(patient, isMobile),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopView(Map<String, dynamic> patient, Map<String, dynamic>? role,
      Map<String, dynamic>? dischargeInfo, Map<String, dynamic>? visitInfo,
      Map<String, dynamic>? summaryData, bool isMobile) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sidebarCard(
            child: _buildPatientInfoSection(patient, role, dischargeInfo, visitInfo, summaryData, isMobile, false),
          ),
          const SizedBox(height: 20),
          _sidebarCard(
            child: _buildContactSection(patient, isMobile),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Tooltip(
                decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(8)),
                message: 'Tap to print Patient Summary',
                child: IconButton(
                  icon: Icon(Icons.print, color: AppColors.primary),
                  onPressed: () => _printPatientDetails(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfoSection(Map<String, dynamic> patient, Map<String, dynamic>? role,
      Map<String, dynamic>? dischargeInfo, Map<String, dynamic>? visitInfo,
      Map<String, dynamic>? summaryData, bool isMobile, bool isCompact) {

    // Get age value safely
    dynamic ageValue;
    bool hasValidAge = false;
    String ageText = '';

    if (visitInfo != null && visitInfo['age'] != null) {
      ageValue = visitInfo['age'];
      if (ageValue is num && ageValue > 0) {
        hasValidAge = true;
        ageText = '$ageValue years';
      } else if (ageValue is String && ageValue.isNotEmpty && ageValue != "0" && ageValue != "0.0") {
        hasValidAge = true;
        ageText = '$ageValue years';
      }
    }

    // Get gender text - updated to show full text
    String getFullGenderText(int? genderCode) {
      switch (genderCode) {
        case 1:
          return 'Male';
        case 2:
          return 'Female';
        case 3:
          return 'Other';
        default:
          return '';
      }
    }

    final genderText = getFullGenderText(patient['gender']);

    // Get full name
    final fullName = "${patient['first_name']} ${patient['last_name']}";

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: buildInfoBlock(
                    "Patient Name",
                    fullName,
                  ),
                ),
                if (genderText.isNotEmpty) ...[
                  SizedBox(width: 16),
                  Expanded(
                    child: buildInfoBlock(
                      "Gender",
                      genderText,
                    ),
                  ),
                ],
                if (hasValidAge) ...[
                  SizedBox(width: 16),
                  Expanded(
                    child: buildInfoBlock(
                      "Age",
                      ageText,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 8),

            // Diagnosis in the format you want
            if (!isCompact)
              _buildDiagnosisRow(dischargeInfo, isMobile),

            // Summary Plan A
            const SizedBox(height: 16),
            _buildSummarySection(
              title: "Summary Plan A",
              controller: summaryController_A,
              isEditing: isEditingPlanA,
              summaryData: summaryData,
              fieldName: 'summary_a',
              role: role,
              onCopy: () {
                final text = summaryData?['summary_a']?.toString() ?? '';
                if (text.isNotEmpty) {
                  _copyToClipboard(text, 'Summary Plan A');
                }
              },
            ),

            // Summary Plan B
            const SizedBox(height: 16),
            _buildSummarySection(
              title: "Summary Plan B",
              controller: summaryController_B,
              isEditing: isEditingPlanB,
              summaryData: summaryData,
              fieldName: 'summary_b',
              role: role,
              onCopy: () {
                final text = summaryData?['summary_b']?.toString() ?? '';
                if (text.isNotEmpty) {
                  _copyToClipboard(text, 'Summary Plan B');
                }
              },
            ),
          ],
        ),

        // Copy button positioned at top right corner
        if (role?['role'] == 1 && PermissionService().canEditPatients)
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.copy_outlined, color: AppColors.primary, size: 20),
              padding: EdgeInsets.all(4),
              constraints: BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
              onPressed: () => _copyAllPatientInfo(
                  patient,
                  dischargeInfo,
                  visitInfo,
                  summaryData,
                  hasValidAge ? ageValue : null
              ),
              tooltip: 'Copy all patient information',
            ),
          ),
      ],
    );
  }
  Widget _buildDiagnosisRow(Map<String, dynamic>? dischargeInfo, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          buildInfoBlock(
              "Diagnosis",
              dischargeInfo != null ? _getDisplayText(dischargeInfo['diagnosis']) : 'Not specified'
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: buildInfoBlock(
                "Diagnosis",
                dischargeInfo != null ? _getDisplayText(dischargeInfo['diagnosis']) : 'Not specified'
            ),
          ),
        ],
      );
    }
  }

  void _copyAllPatientInfo(
      Map<String, dynamic> patient,
      Map<String, dynamic>? dischargeInfo,
      Map<String, dynamic>? visitInfo,
      Map<String, dynamic>? summaryData,
      dynamic ageValue
      )
  {
    try {
      // Build formatted text
      final lines = <String>[];
      // Get formatted PH ID
      final formattedPhId = _getFormattedPhId();

      // Header
      lines.add('PATIENT INFORMATION');
      lines.add('-------------------');

      // Basic info
      lines.add('Name: ${patient['first_name']} ${patient['last_name']}');
      lines.add('Gender: ${_getGenderText(patient['gender'])}');
      if (ageValue != null) {
        lines.add('Age: $ageValue');
      }
      lines.add('PH ID: $formattedPhId'); // Updated line
      if (patient['mobile_no'] != null) {
        lines.add('Mobile Number: ${patient['mobile_no']}');
      }

      // Diagnosis
      if (dischargeInfo != null &&
          dischargeInfo['diagnosis'] != null &&
          dischargeInfo['diagnosis'].toString().isNotEmpty) {
        lines.add('');
        lines.add('Diagnosis: ${dischargeInfo['diagnosis']}');

      }

      // Summary A
      lines.add('');
      lines.add('SUMMARY PLAN A');
      lines.add('--------------');
      if (summaryData != null && summaryData['summary_a'] != null) {
        lines.add(summaryData['summary_a']);
      } else {
        lines.add('No summary available');
      }

      // Summary B
      lines.add('');
      lines.add('SUMMARY PLAN B');
      lines.add('--------------');
      if (summaryData != null && summaryData['summary_b'] != null) {
        lines.add(summaryData['summary_b']);
      } else {
        lines.add('No summary available');
      }



      final textToCopy = lines.join('\n');

      Clipboard.setData(ClipboardData(text: textToCopy)).then((_) {
        showTopRightToast(
          context,
          'Information copied!',
          backgroundColor: Colors.green,
        );
      });

    } catch (e) {
      showTopRightToast(
        context,
        'Failed to copy: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  void _copyToClipboard(String text, [String? source]) async {
    if (text.isEmpty) return;

    try {
      await Clipboard.setData(ClipboardData(text: text));

      // Show success message
      final message = source != null
          ? '$source copied to clipboard'
          : 'Copied to clipboard';

      showTopRightToast(
        context,
        message,
        backgroundColor: Colors.green,
      );
    } catch (e) {
      showTopRightToast(
        context,
        'Failed to copy: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  Widget _buildSummarySection({
    required String title,
    required TextEditingController controller,
    required bool isEditing,
    required Map<String, dynamic>? summaryData,
    required String fieldName,
    required Map<String, dynamic>? role,
    required VoidCallback onCopy,
  })
  {
    final hasData = summaryData != null && summaryData[fieldName] != null && summaryData[fieldName].toString().isNotEmpty;
    final summaryText = hasData ? summaryData![fieldName] ?? '' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary text block with fixed width
            Expanded(
              child: buildInfoBlock(
                title,
                hasData && !isEditing
                    ? summaryData![fieldName] ?? 'Not specified'
                    : '',
              ),
            ),
            SizedBox(width: 8), // Small spacing

            // Copy button (only when not editing and has data)

            // Edit button (only when not editing)
            if (!isEditing && role?['role'] == 1)
              Visibility(
                visible: PermissionService().canEditPatients,
                child: SizedBox(
                  width: 40,
                  child: IconButton(
                    icon: Icon(Icons.edit_outlined, color: AppColors.primary),
                    iconSize: 20,
                    padding: EdgeInsets.all(4),
                    constraints: BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    onPressed: () {
                      setState(() {
                        if (fieldName == 'summary_a') {
                          isEditingPlanA = true;
                        } else {
                          isEditingPlanB = true;
                        }
                        controller.text = summaryText;
                      });
                    },
                    tooltip: 'Edit $title',
                  ),
                ),
              ),

            // Save/Cancel buttons (only when editing)
            if (isEditing)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 40,
                    child: IconButton(
                      onPressed: isAddingSummary ? null : addSummary,
                      icon: Icon(Icons.check_rounded, color: AppColors.primary, size: 20),
                      padding: EdgeInsets.all(4),
                      constraints: BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      tooltip: 'Save changes',
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: IconButton(
                      icon: Icon(Icons.close_rounded, color: Colors.red, size: 20),
                      padding: EdgeInsets.all(4),
                      constraints: BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      onPressed: () {
                        setState(() {
                          if (fieldName == 'summary_a') {
                            isEditingPlanA = false;
                          } else {
                            isEditingPlanB = false;
                          }
                          controller.text = summaryText;
                        });
                      },
                      tooltip: 'Cancel editing',
                    ),
                  ),
                ],
              ),
          ],
        ),

        if (isEditing)
          Column(
            children: [
              const SizedBox(height: 8),
              CustomTextField(
                controller: controller,
                hintText: title,
                multiline: true,
                maxLines: 2,
              ),
              const SizedBox(height: 8),
            ],
          ),
      ],
    );
  }

  Widget _buildContactSection(Map<String, dynamic> patient, bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Contact Patient",
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 14),
              fontWeight: FontWeight.w500,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 8),

          // WhatsApp
          InkWell(
            onTap: () async {
              final phone = patient['mobile_no'];
              final whatsappUrl = Uri.parse("https://wa.me/$phone");
              if (await canLaunchUrl(whatsappUrl)) {
                await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
              } else {
                showTopRightToast(
                  context,
                  "Could not open WhatsApp",
                  backgroundColor: Colors.red,
                );
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    "assets/whatsapp.png",
                    height: ResponsiveUtils.scaleHeight(context, 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connect on Whatsapp',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 14),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Call
          InkWell(
            onTap: () async {
              final phone = patient['mobile_no'];
              final callUri = Uri(scheme: 'tel', path: phone);
              if (await canLaunchUrl(callUri)) {
                await launchUrl(callUri);
              } else {
                showTopRightToast(
                  context,
                  "Could not launch dialer",
                  backgroundColor: Colors.red,
                );
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    "assets/call.png",
                    height: ResponsiveUtils.scaleHeight(context, 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connect on Call\n${patient['mobile_no']}',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 14),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Contact Patient",
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 14),
              fontWeight: FontWeight.w500,
              color: AppColors.secondary,
            ),
          ),
          ListTile(
            leading: Image.asset(
                "assets/whatsapp.png",
                height: ResponsiveUtils.scaleHeight(context, 22)
            ),
            title: Text('+91-${patient['mobile_no']}'),
            onTap: () async {
              final phone = patient['mobile_no'];
              final whatsappUrl = Uri.parse("https://wa.me/$phone");
              if (await canLaunchUrl(whatsappUrl)) {
                await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
              } else {
                showTopRightToast(
                  context,
                  "Could not open WhatsApp",
                  backgroundColor: Colors.red,
                );
              }
            },
          ),
          ListTile(
            leading: Image.asset(
                "assets/call.png",
                height: ResponsiveUtils.scaleHeight(context, 22)
            ),
            title: Text('+91-${patient['mobile_no']}'),
            onTap: () async {
              final phone = patient['mobile_no'];
              final callUri = Uri(scheme: 'tel', path: phone);
              if (await canLaunchUrl(callUri)) {
                await launchUrl(callUri);
              } else {
                showTopRightToast(
                  context,
                  "Could not launch dialer",
                  backgroundColor: Colors.red,
                );
              }
            },
          ),
        ],
      );
    }
  }

  Future<void> _printPatientDetails() async {
    final patient = patientData!['patient'][0];
    final roleList = patientData?['role'];
    final role = (roleList != null && roleList.isNotEmpty) ? roleList[0] : null;
    final dischargeInfo = patientData!['discharge_info'].isNotEmpty
        ? patientData!['discharge_info'][0]
        : null;
    final visitInfo = patientData!['PatientVisitInfo'].isNotEmpty
        ? patientData!['PatientVisitInfo'][0]
        : null;
    final summaryData = patientData!['summary'] != null &&
        patientData!['summary'].isNotEmpty
        ? patientData!['summary'][0]
        : null;

    final pdf = pw.Document();
    final formattedPhId = _getFormattedPhId();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Patient Details',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),

              // Patient Basic Info
              pw.Text('Basic Information',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              _buildPdfRow('Name', '${patient['first_name']} ${patient['last_name']}'),
              _buildPdfRow('Gender', _getGenderText(patient['gender'])),
              _buildPdfRow('PH ID', formattedPhId),
              _buildPdfRow('Mobile', patient['mobile_no']),
              pw.SizedBox(height: 10),

              // Medical History
              pw.Text('Medical History',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              _buildPdfRow('Diagnosis', _getDisplayText(dischargeInfo?['diagnosis'])),
              _buildPdfRow('Surgery Name', _getDisplayText(dischargeInfo?['operation_type'])),
              _buildPdfRow('Chief Complaints', _getDisplayText(visitInfo?['chief_complaints'])),
              _buildPdfRow('Clinical Diagnosis', _getDisplayText(visitInfo?['clinical_diagnosis'])),
              pw.SizedBox(height: 10),

              // Summary Plan A
              pw.Text('Summary Plan A',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.Text(
                summaryData?['summary_a']?.toString() ?? 'No summary available for Plan A',
              ),
              pw.SizedBox(height: 10),

              // Summary Plan B
              pw.Text('Summary Plan B',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.Text(
                summaryData?['summary_b']?.toString() ?? 'No summary available for Plan B',
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
    );
  }

  pw.Widget _buildPdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value),
          ),
        ],
      ),
    );
  }

  Widget buildInfoBlock(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: RichText(
        text: TextSpan(
          style:  TextStyle(fontSize:  ResponsiveUtils.fontSize(context, 14), color: Colors.black,fontWeight: FontWeight.w300),
          children: [
            TextSpan(
              text: '$title\n',
              style:  TextStyle(
                fontSize:  ResponsiveUtils.fontSize(context, 14),
                fontWeight: FontWeight.w400,
                color: Color(0xFF666666),
              ),
            ),
            TextSpan(
              text: content,
              style:  TextStyle(
                fontWeight: FontWeight.w300,
                fontSize:  ResponsiveUtils.fontSize(context, 18),
                color: Color(0xFF232323),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sidebarCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  @override
  void dispose() {
    summaryController_A.dispose();
    summaryController_B.dispose();
    super.dispose();
  }
}

class PatientProvider with ChangeNotifier {
  bool _needsRefresh = false;

  bool get needsRefresh => _needsRefresh;

  void markForRefresh() {
    _needsRefresh = true;
    notifyListeners();
  }

  void clearRefresh() {
    _needsRefresh = false;
  }
}