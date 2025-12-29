import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import 'all_students_page.dart';
import 'MarkAttendancePage.dart';
import 'student_form_page.dart';

class AttendanceDashboard extends StatefulWidget {
  @override
  _AttendanceDashboardState createState() => _AttendanceDashboardState();
}

class _AttendanceDashboardState extends State<AttendanceDashboard> {
  // Logic: We fetch all data in one go for the best performance
  late Future<Map<String, dynamic>> _dashboardData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _dashboardData =
        Future.wait([
          ApiService.getDailyStats(),
          ApiService.getRecentActivity(),
          ApiService.getWeeklyAttendance(),
        ]).then((results) {
          return {
            'stats': results[0],
            'activity': results[1],
            'weekly': results[2],
          };
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E5BB0),
        centerTitle: true,
        title: Column(
          children: const [
            Text(
              "PUNJAB COLLEGE CHICHAWATNI",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text("AI ATTENDANCE SYSTEM", style: TextStyle(fontSize: 10)),
          ],
        ),
        leading: const Icon(Icons.menu),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.account_circle),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() => _loadData()),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dashboardData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text("Error loading dashboard data"));
            }

            final data = snapshot.data!;
            final stats = data['stats'];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("QUICK ACTIONS"),
                  _buildQuickActions(context),
                  const SizedBox(height: 20),

                  _buildSectionTitle("DAILY SUMMARY"),
                  _buildSummaryRow(stats),
                  const SizedBox(height: 20),

                  _buildSectionTitle("RECENT ACTIVITY"),
                  _buildActivityList(data['activity']),
                  const SizedBox(height: 20),

                  _buildSectionTitle("ANALYTICS OVERVIEW"),
                  _buildChartsSection(data['weekly']),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1E5BB0),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.8,
        children: [
          _actionButton(
            Icons.person_add,
            "STUDENT REGISTRATION",
            Colors.blue,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StudentFormPage()),
              );
            },
          ),
          _actionButton(
            Icons.qr_code_scanner,
            "MARK ATTENDANCE",
            Colors.indigo,
            () {
              // Navigator.push logic here
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MarkAttendancePage2()),
              );
            },
          ),
          _actionButton(
            Icons.list_alt,
            "VIEW ALL STUDENTS",
            Colors.blue.shade800,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AllStudentsPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSummaryRow(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryCircle(
            "${stats['presentPercent']}%",
            "PRESENT",
            Colors.green,
            "${stats['presentCount']}/${stats['total']}",
          ),
          _summaryCircle(
            "${stats['absentPercent']}%",
            "ABSENT",
            Colors.red,
            "${stats['total'] - stats['presentCount']}/${stats['total']}",
          ),
        ],
      ),
    );
  }

  Widget _summaryCircle(
    String percent,
    String label,
    Color color,
    String count,
  ) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                value: double.parse(percent.replaceAll('%', '')) / 100,
                strokeWidth: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              percent,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
        Text(count, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _buildActivityList(List<dynamic> activities) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        children: activities.isEmpty
            ? [const Text("No activity today")]
            : activities
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: item['status'] == 'Present'
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${item['name']} - ",
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            item['status'].toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              color: item['status'] == 'Present'
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "(${item['time']})",
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
      ),
    );
  }

  Widget _buildChartsSection(List<dynamic> weeklyData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: SizedBox(
        height: 150,
        child: BarChart(
          BarChartData(
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(show: false),
            barGroups: weeklyData
                .asMap()
                .entries
                .map(
                  (e) => BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        // This safely converts "5" (String) into 5.0 (Double)
                        toY:
                            double.tryParse(e.value['count'].toString()) ?? 0.0,
                        color: Colors.green,
                        width: 12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(8),
        bottomRight: Radius.circular(8),
      ),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
      ],
    );
  }
}
