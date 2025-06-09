import 'package:flutter/material.dart';
import 'package:tab_container/tab_container.dart';
import '../../utils/colors.dart';
import 'Patient_Registration.dart';

class PatientDataTabsScreen extends StatelessWidget {
  const PatientDataTabsScreen({super.key});

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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary,),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    TabContainer(
                      tabEdge: TabEdge.top,
                      tabMaxLength: 120,
                      tabCurve: Curves.easeInOut,
                      tabDuration: const Duration(milliseconds: 300),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      tabBorderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      selectedTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primary
                      ),
                      unselectedTextStyle: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                        color: AppColors.secondary,
                      ),
                      tabs: const [
                        Text('Onboarding'),
                        Text('Surgery'),
                        Text('Discharge Info'),
                        Text('Follow Ups'),
                      ],
        
                      children: [
                         Container(child: SingleChildScrollView(child: OnboardingForm())),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const SurgeryTabContent(),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const DischargeTabContent(),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const FollowUpsTabContent(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              const Expanded(
                flex: 1,
                child: PatientDetailsSidebar(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SurgeryTabContent extends StatelessWidget {
  const SurgeryTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Surgery Details Coming Soon',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class DischargeTabContent extends StatelessWidget {
  const DischargeTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Discharge Info Coming Soon',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class FollowUpsTabContent extends StatelessWidget {
  const FollowUpsTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Follow Ups Coming Soon',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}