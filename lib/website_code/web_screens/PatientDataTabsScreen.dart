import 'package:flutter/material.dart';
import 'package:poojaheakthcare/website_code/web_screens/DischargeTabContent.dart';
import '../../constants/global_variable.dart';
import '../../utils/colors.dart';
import '../../widgets/KeepAlivePage.dart';
import 'FollowUpsTabContent.dart';
import 'PatientDetailsSidebar.dart';
import 'Patient_Registration.dart';
import 'SurgeryTabContent.dart';

class PatientDataTabsScreen extends StatefulWidget {

  const PatientDataTabsScreen({super.key});

  @override
  State<PatientDataTabsScreen> createState() => _PatientDataTabsScreenState();
}

class _PatientDataTabsScreenState extends State<PatientDataTabsScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF2FF),
        elevation: 0,
        title: const Text(
          'Patients Data',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 26,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 600,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:BorderRadius.only(topLeft: Radius.circular(12),topRight: Radius.circular(12))
                    ),
                    child: TabBar(

                     // padding: const EdgeInsets.symmetric(horizontal: 8),  // Overall padding
                      labelPadding: const EdgeInsets.symmetric(horizontal: 12),  // Space between tabs
                      controller: _tabController,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.secondary,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),


                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),

                      indicatorSize: null,

                      indicator: BoxDecoration(

                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        color: Colors.transparent,
                        border: Border(
                          bottom: BorderSide(
                            color:  Colors.transparent,

                          ),
                        ),
                      ),
                      tabs: const [
                        Tab(text: 'Onboarding'),

                        Tab(text: 'Operation Notes'),

                        Tab(text: 'Discharge Info'),

                        Tab(text: 'Follow Ups'),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          KeepAlivePage(child: SingleChildScrollView(child: OnboardingForm())),
                          KeepAlivePage(child: SurgeryTabContent(patientId: GlobalPatientData.patientId.toString(),)),
                          KeepAlivePage(child: DischargeTabContent(patientId:GlobalPatientData.patientId.toString(),)),
                          KeepAlivePage(child: FollowUpsTabContent(patientId:GlobalPatientData.patientId.toString(),)),
                        ],
                      )
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 1,
              child: PatientDetailsSidebar(patientId: GlobalPatientData.patientId!,),
            ),
          ],
        ),
      ),
    );
  }
}