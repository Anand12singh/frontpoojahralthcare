import 'package:flutter/material.dart';
import 'package:poojaheakthcare/website_code/web_screens/DischargeTabContent.dart';
import '../../constants/ResponsiveUtils.dart';
import '../../constants/global_variable.dart';
import '../../utils/colors.dart';
import '../../widgets/KeepAlivePage.dart';
import 'CustomSidebar.dart';
import 'FollowUpsTabContent.dart';
import 'PatientDetailsSidebar.dart';
import 'Patient_Registration.dart';
import 'SearchBar.dart';
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
    final isMobile = ResponsiveUtils.isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FF),
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 80),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: isMobile
                        ? SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Patients Data',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: ResponsiveUtils.fontSize(context, 26),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height,
                            child: _buildTabsAndViews(),
                          ),
                          const SizedBox(height: 20),
                          PatientDetailsSidebar(
                            patientId: GlobalPatientData.patientId!,
                          ),
                        ],
                      ),
                    )
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Text(
                            'Patients Data',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: ResponsiveUtils.fontSize(context, 26),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: _buildTabsAndViews(),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 1,
                                child: PatientDetailsSidebar(
                                  patientId: GlobalPatientData.patientId!,
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

  Widget _buildTabsAndViews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: ResponsiveUtils.scaleWidth(context, 600),
          child: TabBar(
            indicatorWeight: 0.0,
            labelPadding: const EdgeInsets.all(0),
            controller: _tabController,
            isScrollable: false,
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
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              color: Colors.transparent,
            ),
            tabs: [
              _tabItem('Onboarding'),
              _tabItem('Operation Notes'),
              _tabItem('Discharge Info'),
              _tabItem('Follow Ups'),
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
                KeepAlivePage(child: SurgeryTabContent(patientId: GlobalPatientData.patientId.toString())),
                KeepAlivePage(child: DischargeTabContent(patientId: GlobalPatientData.patientId.toString())),
                KeepAlivePage(child: FollowUpsTabContent(patientId: GlobalPatientData.patientId.toString())),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        width: ResponsiveUtils.scaleWidth(context, 144),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        alignment: Alignment.center,
        child: Tab(
          iconMargin: EdgeInsets.zero,
          text: text,
        ),
      ),
    );
  }

}