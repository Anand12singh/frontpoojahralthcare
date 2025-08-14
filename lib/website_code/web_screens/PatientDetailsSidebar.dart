import 'package:flutter/material.dart';
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
  TextEditingController summaryController = TextEditingController(); // Add this
  bool isAddingSummary = false;
  bool isEditingSummary = false;

  @override
  void initState() {
    super.initState();
    fetchPatientData();
    WidgetsFlutterBinding.ensureInitialized();
    PermissionService().initialize();
  }
  void _initializeData() {
    fetchPatientData();
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
            // Safely initialize summaryController
            if (patientData!['summary'] != null &&
                patientData!['summary'].isNotEmpty) {
              summaryController.text =
                  patientData!['summary'][0]['summary'] ?? "";
            } else {
              summaryController.text = "";
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

/*
  Future<void> fetchPatientData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('$localurl/front_patient_by_id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': widget.patientId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'].isNotEmpty) {
          setState(() {
            patientData = data['data'][0];
            print("patientData");
            print(patientData);
            // Safely initialize summaryController
            if (patientData!['summary'] != null && patientData!['summary'].isNotEmpty) {
              summaryController.text = patientData!['summary'][0]['summary'] ?? "";
            } else {
              summaryController.text = "";
            }
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = data['message'] ?? 'Patient not found';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Patient data not found.';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }
*/

  String _getGenderText(int? genderCode) {
    switch (genderCode) {
      case 1:
        return 'M';
      case 2:
        return 'F';
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
    // Add other location cases as needed
      default:
        return 'Not specified';
    }
  }

  Future<void> addSummary() async {
    if (summaryController.text.isEmpty) {
      showTopRightToast(
        context,
        'Please enter a summary',
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
          'summary': summaryController.text,
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
        summaryController.clear();
      });
    }
  }

 /* Future<void> addSummary() async {
    if (summaryController.text.isEmpty) {
      showTopRightToast(context,'Please enter a summary',backgroundColor: Colors.red);


      return;
    }

    setState(() => isAddingSummary = true);

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
        'Cookie': 'connect.sid=s%3AuEDYQI5oGhq5TztFK-F_ivqibtXxbspe.L65SiGdo4p4ZZY01Vnqd9tb4d64NFnzksLXndIK5zZA',
        'Authorization': 'Bearer $token',
      };

      final response = await http.post(
        Uri.parse('$localurl/summary_add'),
        headers: headers,
        body: json.encode({
          'patient_id': widget.patientId,
          'summary': summaryController.text,
        }),

      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {

          showTopRightToast(context,data['message'] ?? 'Summary added successfully',backgroundColor: Colors.green);
          setState(() {
            isEditingSummary = false; // Add this line
          });
          fetchPatientData();
        } else {
          showTopRightToast(context,data['message'] ?? 'Failed to add summary',backgroundColor: Colors.red);

        }
      } else {
        print("response.body");
        print(response.body);

        showTopRightToast(context,'Failed to add summary',backgroundColor: Colors.red);



      }
    } catch (e) {
      showTopRightToast(context,'Error: ${e.toString()}',backgroundColor: Colors.red);

    } finally {
      setState(() {
        isAddingSummary = false;
        summaryController.clear();
      });
    }
  }*/

  String _getDisplayText(dynamic value) {
    return (value == null || value.toString().isEmpty)
        ? 'Not specified'
        : value.toString();
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


    return
      isMobile ?
      Row(

      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _sidebarCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:  [
                Text("${patient['first_name']} ${patient['last_name']} -${_getGenderText(patient['gender'])}", style: TextStyle(fontWeight: FontWeight.w600,fontSize:  ResponsiveUtils.fontSize(context, 20),color: AppColors.primary)),
               // Text("PH ID-${patient['phid']}", style: TextStyle(fontWeight: FontWeight.w600,fontSize: 20,color: AppColors.primary)),
                SizedBox(height: 8),
                buildInfoBlock("PH ID", "${patient['phid']}"),
                buildInfoBlock("History", _getHistoryText()),
                !isMobile
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: buildInfoBlock(
                        "Location",
                        _getDisplayText(dischargeInfo?['location'])

                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: buildInfoBlock(
                        "Occupation",
                        _getDisplayText(dischargeInfo?['occupation'])

                      ),
                    ),
                  ],
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildInfoBlock(
                      "Location",
                      _getDisplayText(dischargeInfo?['location'])

                    ),
                    buildInfoBlock(
                      "Occupation",
                      _getDisplayText(dischargeInfo?['occupation'])

                    ),
                  ],
                ),
          
                // Row 2
                !isMobile
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: buildInfoBlock(
                        "Diagnosis",
                        _getDisplayText(dischargeInfo?['diagnosis'])

                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: buildInfoBlock(
                        "Surgery Name",
                        _getDisplayText(dischargeInfo?['operation_type'])

                      ),
                    ),
                  ],
                )
                    : Column(
                  children: [
                    buildInfoBlock(
                      "Diagnosis",
                      _getDisplayText(dischargeInfo?['diagnosis'])

                    ),
                    buildInfoBlock(
                      "Surgery Name",
                      _getDisplayText(dischargeInfo?['operation_type'])

                    ),
                  ],
                ),
          
                // Row 3
                !isMobile
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: buildInfoBlock(
                        "Chief Complaints",
                          visitInfo != null ? _getDisplayText( visitInfo['chief_complaints'])  : 'Not specified'

                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: buildInfoBlock(
                        "Clinical Diagnosis",
                        _getDisplayText(visitInfo?['clinical_diagnosis'])

                      ),
                    ),
                  ],
                )
                    : Column(
                  children: [
                    buildInfoBlock(
                      "Chief Complaints",
                        visitInfo != null ? _getDisplayText( visitInfo['chief_complaints'])  : 'Not specified'

                    ),
                    buildInfoBlock(
                      "Clinical Diagnosis",
                      _getDisplayText(visitInfo?['clinical_diagnosis'])

                    ),
                  ],
                ),
          
          
                Row(
                  children: [
                    Expanded(
                      child: buildInfoBlock(
                          "Summary",
          
                          (patientData!['summary'] != null && patientData!['summary'].isNotEmpty)
                              ? !isEditingSummary ? (patientData!['summary'][0]['summary'] ?? 'Not specified') :''
                              : 'Not specified'
                      ),
                    ),
            /*        if (!isEditingSummary &&
                        patientData!['summary'] != null &&
                        patientData!['summary'].isNotEmpty)*/
                    if (!isEditingSummary)
                      IconButton(
                        icon: Icon(Icons.edit_outlined, color: AppColors.primary),
                        onPressed: () {
                          setState(() {
                            isEditingSummary = true;
                            summaryController.text = (patientData!['summary'] != null &&
                                patientData!['summary'].isNotEmpty)
                                ? patientData!['summary'][0]['summary'] ?? ''
                                : '';
                          });
                        },
                      ),
          
                    if (isEditingSummary)
                    Row(
                      children: [
          
                        IconButton(
                          onPressed: isAddingSummary ? null : addSummary,
                          icon:   Icon(Icons.check_rounded,  color: AppColors.primary,),
          
          
          
                          ),
          
          
          
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              isEditingSummary = false;
          
                            });
                          },
                        ),
                      ],
                    )
                  ],
                ),
                if (isEditingSummary)
                  Column(
                    children: [
                      //SizedBox(height: 12),
                      CustomTextField(
                        controller: summaryController,
                        hintText: 'Summary',
                        maxLines: 2,
                      ),
                 /*     SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Animatedbutton(
                            onPressed: () {
                              setState(() {
                                isEditingSummary = false;
                              });
                            },
                            shadowColor: Colors.white,
                            titlecolor: AppColors.primary,
                            backgroundColor: Colors.white,
                            borderColor: AppColors.secondary,
                            isLoading: isCancleLoading,
                            title: 'Cancel',
                          ),
          
                          SizedBox(width: 8),
                          Animatedbutton(
                            onPressed: isAddingSummary ? null : addSummary,
                            isLoading: isAddingSummary,
                            title: 'Update Summary',
                            backgroundColor: AppColors.secondary,
                            shadowColor: Colors.white,
                          ),
                        ],
                      ),*/
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _sidebarCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Contact Patient",
                  style: TextStyle(
                    fontSize:ResponsiveUtils.fontSize(context, 14),
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondary,
                  ),
                ),
              !isMobile ?
              ListTile(

                  leading: Image.asset(
                    "assets/whatsapp.png",
                    height: ResponsiveUtils.scaleHeight(context, 20),
                  ),
                  title:  Text('Connect on Whatsapp',style: TextStyle(fontSize:  ResponsiveUtils.fontSize(context, 14)),),
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

                ):

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
!isMobile?
                ListTile(
                  leading: Image.asset(
                    "assets/call.png",
                    height:  ResponsiveUtils.scaleHeight(context, 20),
                  ),
                  title: Text('Connect on Call - ${patient['mobile_no']}',style: TextStyle(fontSize:  ResponsiveUtils.fontSize(context, 14)),),
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
                ):InkWell(
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
            ),
          ),
        )

      ],
    ):

      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sidebarCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:  [
                  Text("${patient['first_name']} ${patient['last_name']} -${_getGenderText(patient['gender'])}", style: TextStyle(fontWeight: FontWeight.w600,fontSize:  ResponsiveUtils.fontSize(context, 20),color: AppColors.primary)),
                  // Text("PH ID-${patient['phid']}", style: TextStyle(fontWeight: FontWeight.w600,fontSize: 20,color: AppColors.primary)),
                  SizedBox(height: 8),
                  buildInfoBlock("PH ID", "${patient['phid']}"),
                  buildInfoBlock("History", _getHistoryText()),
                  !isMobile
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: buildInfoBlock(
                          "Location",
                          patient['location'] != 'Others'
                              ? patient['location'] ??'Not specified'
                              : patient['other_location']??'Not specified',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: buildInfoBlock(
                          "Occupation",
                          _getDisplayText( patient['occupation'])

                        ),
                      ),
                    ],
                  )
                      : Column(
                    children: [
                      buildInfoBlock(
                        "Location",

                        patient['location'] != 'Others'
                            ? patient['location']
                            : patient['other_location'],
                      ),
                      buildInfoBlock(
                        "Occupation",
                        _getDisplayText( patient['occupation'])

                      ),
                    ],
                  ),
        
                  // Row 2
                  !isMobile
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: buildInfoBlock(
                            "Diagnosis",
                            dischargeInfo != null ? _getDisplayText(dischargeInfo['diagnosis']) : 'Not specified'
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child:buildInfoBlock(
                            "Surgery Name",
                            dischargeInfo != null ? _getDisplayText(dischargeInfo['operation_type']) : 'Not specified'
                        ),
                      ),
                    ],
                  )
                      : Column(
                    children: [
                      buildInfoBlock(
                        "Diagnosis",
                        _getDisplayText( dischargeInfo['diagnosis'])

                      ),
                      buildInfoBlock(
                        "Surgery Name",
                        _getDisplayText( dischargeInfo['operation_type'])


                      ),
                    ],
                  ),
        
                  // Row 3
                  !isMobile
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: buildInfoBlock(
                          "Chief Complaints",
                            visitInfo != null ? _getDisplayText( visitInfo['chief_complaints'])  : 'Not specified'

                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child:buildInfoBlock(
                            "Clinical Diagnosis",
                            dischargeInfo != null ? _getDisplayText(visitInfo?['clinical_diagnosis']) : 'Not specified'
                        ),
                      ),
                    ],
                  )
                      : Column(
                    children: [
                      buildInfoBlock(
                        "Chief Complaints",
                          visitInfo != null ? _getDisplayText( visitInfo['chief_complaints'])  : 'Not specified'

                      ),
                      buildInfoBlock(
                        "Clinical Diagnosis",
                        _getDisplayText(visitInfo?['clinical_diagnosis'])

                      ),
                    ],
                  ),


                  Row(

                    children: [
                      buildInfoBlock(
                          "Summary",

                          (patientData!['summary'] != null && patientData!['summary'].isNotEmpty)
                              ? !isEditingSummary ? (patientData!['summary'][0]['summary'] ?? '') :''
                              : 'Not specified'
                      ),
                      /*        if (!isEditingSummary &&
                        patientData!['summary'] != null &&
                        patientData!['summary'].isNotEmpty)*/
                      if (!isEditingSummary && role['role']==1)
                        Visibility(
                          visible:PermissionService().canEditPatients ,
                          child: IconButton(
                            icon: Icon(Icons.edit_outlined, color: AppColors.primary),
                            onPressed: () {
                              setState(() {
                                isEditingSummary = true;
                                summaryController.text = (patientData!['summary'] != null &&
                                    patientData!['summary'].isNotEmpty)
                                    ? patientData!['summary'][0]['summary'] ?? ''
                                    : '';
                              });
                            },
                          ),
                        ),

                      if (isEditingSummary)
                        Row(
                          children: [

                            IconButton(
                              onPressed: isAddingSummary ? null : addSummary,
                              icon:   Icon(Icons.check_rounded,  color: AppColors.primary,),



                            ),



                            IconButton(
                              icon: Icon(Icons.close_rounded, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  isEditingSummary = false;

                                });
                              },
                            ),
                          ],
                        )
                    ],
                  ),
                  if (isEditingSummary)
                    Column(
                      children: [
                        //SizedBox(height: 12),
                        CustomTextField(
                          controller: summaryController,
                          hintText: 'Summary',
                          maxLines: 2,
                        ),
                        /*     SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Animatedbutton(
                            onPressed: () {
                              setState(() {
                                isEditingSummary = false;
                              });
                            },
                            shadowColor: Colors.white,
                            titlecolor: AppColors.primary,
                            backgroundColor: Colors.white,
                            borderColor: AppColors.secondary,
                            isLoading: isCancleLoading,
                            title: 'Cancel',
                          ),
        
                          SizedBox(width: 8),
                          Animatedbutton(
                            onPressed: isAddingSummary ? null : addSummary,
                            isLoading: isAddingSummary,
                            title: 'Update Summary',
                            backgroundColor: AppColors.secondary,
                            shadowColor: Colors.white,
                          ),
                        ],
                      ),*/
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _sidebarCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Contact Patient",
                    style: TextStyle(
                      fontSize:  ResponsiveUtils.fontSize(context, 14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondary,
                    ),
                  ),
                  ListTile(
                    leading: Image.asset(
                      "assets/whatsapp.png",
                      height: ResponsiveUtils.scaleHeight(context, 22)
                    ),
                    title:  Text('+91-${patient['mobile_no']}'),
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
                      height:  ResponsiveUtils.scaleHeight(context, 22)
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
              ),
            )
        ,Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.print, color: AppColors.primary),
                  onPressed: () => _printPatientDetails(),
                ),
              ],
            ),
          ],
        ),
      );
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

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
            pw.Header(
            level: 0,
            child: pw.Text('Patient Details',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),),
            pw.SizedBox(height: 20),

            // Patient Basic Info
            pw.Text('Basic Information',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            _buildPdfRow('Name', '${patient['first_name']} ${patient['last_name']}'),
            _buildPdfRow('Gender', _getGenderText(patient['gender'])),
            _buildPdfRow('PH ID', patient['phid']),
            _buildPdfRow('Mobile', patient['mobile_no']),
            _buildPdfRow('WhatsApp Number', patient['mobile_no']),
            pw.SizedBox(height: 10),

            // Medical History
            pw.Text('Medical History',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            _buildPdfRow('History', _getHistoryText()),
            _buildPdfRow('Diagnosis', _getDisplayText(dischargeInfo?['diagnosis'])),
            _buildPdfRow('Surgery Name', _getDisplayText(dischargeInfo?['operation_type'])),
            _buildPdfRow('Chief Complaints', _getDisplayText(visitInfo?['chief_complaints'])),
            _buildPdfRow('Clinical Diagnosis', _getDisplayText(visitInfo?['clinical_diagnosis'])),
            pw.SizedBox(height: 10),

            // Additional Info
            pw.Text('Additional Information',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            _buildPdfRow('Location', _getDisplayText(dischargeInfo?['location'])),
            _buildPdfRow('Occupation', _getDisplayText(dischargeInfo?['occupation'])),
            pw.SizedBox(height: 10),

            // Summary
            pw.Text('Summary',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            pw.Text(
              (patientData!['summary'] != null && patientData!['summary'].isNotEmpty)
                  ? patientData!['summary'][0]['summary'] ?? 'No summary available'
                  : 'No summary available',
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