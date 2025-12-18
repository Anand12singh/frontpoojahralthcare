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
    _loadPatientData(); // Load SharedPreferences
  }

  Future<void> _loadPatientData() async {
    await GlobalPatientData.loadFromPrefs();

    if (GlobalPatientData.patientId == null) {
      // Handle null case (e.g., redirect or show message)
      debugPrint("patientId is null after loading prefs");
      return;
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatPhidForMobile(String? patientId, String? phid) {
    if (patientId == null || patientId.isEmpty) return 'N/A';

    String formattedId = patientId;
    if (phid != null && phid.isNotEmpty && phid != 'N/A') {
      formattedId = '$patientId/$phid';
    }

    // Truncate if too long for mobile display
    if (formattedId.length > 15) {
      return '${formattedId.substring(0, 12)}...';
    }

    return formattedId;
  }

  void _showPatientInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Patient Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),

            // Display patient details from sidebar
            PatientDetailsSidebar(
              patientId: GlobalPatientData.patientId!,

            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    // Mobile View
    if (isMobile) {
      return _buildMobileView(context);
    }

    // Desktop View
    return _buildDesktopView(context);
  }

  Widget _buildMobileView(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FF),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 3,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              GlobalPatientData.firstName ?? 'Patient',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            if (GlobalPatientData.lastName != null && GlobalPatientData.lastName!.isNotEmpty)
              Text(
                GlobalPatientData.lastName!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => _showPatientInfo(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Patient Info Card (Quick Summary)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PHID: ${_formatPhidForMobile(GlobalPatientData.patientId, GlobalPatientData.phid)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        GlobalPatientData.phone ?? 'N/A',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),


              ],
            ),
          ),

          // Mobile Tabs Section
          Expanded(
            child: DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  // Mobile Tab Bar
                  Container(
                    color: Colors.white,
                    child: TabBar(

                      controller: _tabController,
                      isScrollable: true,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: Colors.grey[600],
                      indicatorColor: AppColors.secondary,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                      tabs: const [
                        Tab(text: 'Onboarding'),
                        Tab(text: 'Operation'),
                        Tab(text: 'Discharge'),
                        Tab(text: 'Follow Ups'),
                      ],
                    ),
                  ),

                  // Mobile Tab Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Mobile Onboarding Tab
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: OnboardingForm(),
                              ),
                            ],
                          ),
                        ),

                        // Mobile Operation Notes Tab
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: SurgeryTabContent(
                            patientId: GlobalPatientData.patientId.toString(),
                            isMobile: true,
                          ),
                        ),

                        // Mobile Discharge Info Tab
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: DischargeTabContent(
                            patientId: GlobalPatientData.patientId.toString(),
                            isMobile: true,
                          ),
                        ),

                        // Mobile Follow Ups Tab
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: FollowUpsTabContent(
                            patientId: GlobalPatientData.patientId.toString(),
                            isMobile: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopView(BuildContext context) {
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
                    child: Column(
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
                KeepAlivePage(child: SurgeryTabContent(patientId: GlobalPatientData.patientId.toString(), isMobile: false)),
                KeepAlivePage(child: DischargeTabContent(patientId: GlobalPatientData.patientId.toString(), isMobile: false)),
                KeepAlivePage(child: FollowUpsTabContent(patientId: GlobalPatientData.patientId.toString(), isMobile: false)),
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