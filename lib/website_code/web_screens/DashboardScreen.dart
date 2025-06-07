import 'package:flutter/material.dart';
import 'package:poojaheakthcare/utils/colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Sample data for bookmarks using map
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

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome Back, Dr. Pooja",
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

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              
                  Expanded(
                    flex: 7, //
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Section
              
                        // Stats Cards - Horizontal Scroll
                        SizedBox(
                          height: 120, // Fixed height for stats cards
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildStatCard("Todays Follow Ups", "42", 'assets/Dashboardicon5.png'),
                              const SizedBox(width: 16),
                              _buildStatCard("New Patients", "210", 'assets/Dashboardicon4.png'),
                              const SizedBox(width: 16),
                              _buildStatCard("Pending Reports", "12", 'assets/Dashboardicon3.png'),
                              const SizedBox(width: 16),
                              _buildStatCard("Total Appointment", "879", 'assets/Dashboardicon2.png'),
                              const SizedBox(width: 16),
                              _buildStatCard("Total Patients", "1222", 'assets/Dashboardicon1.png'),
                            ],
                          ),
                        ),
              
                        const SizedBox(height: 20),
              
              
                        Expanded(
                          child: Container(
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
                                                  topLeft: Radius.circular(12)),
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      "Patient name",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: AppColors.primary,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      "Diagnosis",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: AppColors.primary,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      "Summary",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: AppColors.primary,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      "Actions",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: AppColors.primary,
                                                      ),
                                                    ),
                                                  ),
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
                        ),
              
                        const SizedBox(height: 20),
              
                        // Follow Ups Section
                        SizedBox(
                          height: 200, // Fixed height for follow-ups
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
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
                                    const Text(
                                      "Follow ups",
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    const Text(
                                      "Today",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      _buildFollowUpItem(
                                        name: "Gretchen O'Kon, M/31",
                                        date: "07 May 2025, 9am",
                                        condition: "Hernia",
                                        phone: "+91-7788544987",
                                        isToday: false,
                                      ),
                                      const SizedBox(width: 16),
                                      _buildFollowUpItem(
                                        name: "Gretchen O'Kon, M/31",
                                        date: "07 May 2025, 9am",
                                        condition: "Hernia",
                                        phone: "+91-7788544987",
                                        isToday: false,
                                      ),
                                      const SizedBox(width: 16),
                                      _buildFollowUpItem(
                                        name: "Gretchen O'Kon, M/31",
                                        date: "07 May 2025, 9am",
                                        condition: "Hernia",
                                        phone: "+91-7788544987",
                                        isToday: false,
                                      ),
                                      const SizedBox(width: 16),
                                      _buildFollowUpItem(
                                        name: "Gretchen O'Kon, M/31",
                                        date: "07 May 2025, 9am",
                                        condition: "Hernia",
                                        phone: "+91-7788544987",
                                        isToday: false,
                                      ),
                                      const SizedBox(width: 16),
                                      _buildFollowUpItem(
                                        name: "Gretchen O'Kon, M/31",
                                        date: "07 May 2025, 9am",
                                        condition: "Hernia",
                                        phone: "+91-7788544987",
                                        isToday: false,
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
                  ),
              
                  // Sidebar Column (20% width)
                  Expanded(
                    flex: 3, // 20% of width
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      margin: const EdgeInsets.only(left: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.hinttext.withOpacity(0.2)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Quick Actions",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: 20),
                          // Add more sidebar items here
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
    );


  }



  Widget _buildFollowUpItem({
    required String name,
    required String date,
    required String condition,
    required String phone,
    required bool isToday,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.hinttext.withOpacity(0.2)),
      ),


      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.primary
            ),
          ),
          const SizedBox(height: 4),
          Text(date,
            style: const TextStyle(
            fontWeight: FontWeight.bold,
              color: AppColors.primary,
            fontSize: 12,
          ),
          ),
          const SizedBox(height: 4),
          Text(condition, style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
              color: AppColors.primary
          ),),
          const SizedBox(height: 8),
          Row(
            children: [

              Text(phone, style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                  color: AppColors.primary
              ),),
            ],
          ),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 12.0,horizontal: 12),
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
            flex: 1,
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

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey,
    );
  }


}