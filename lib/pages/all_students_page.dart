// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart'; // For the cute mini pie charts
// import '../services/api_service.dart';
// import '../models/student_model.dart';
// import '../theme/app_colors.dart'; // Using your AppColors

// class AllStudentsPage extends StatefulWidget {
//   @override
//   State<AllStudentsPage> createState() => _AllStudentsPageState();
// }

// class _AllStudentsPageState extends State<AllStudentsPage> {
//   List<Student> allStudents = [];
//   List<Student> filteredStudents = [];
//   bool isLoading = true;
//   TextEditingController searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _fetchStudents();
//   }

//   Future<void> _fetchStudents() async {
//     final students = await ApiService.getAllStudents();
//     setState(() {
//       allStudents = students;
//       filteredStudents = students;
//       isLoading = false;
//     });
//   }

//   void _filterSearch(String query) {
//     setState(() {
//       filteredStudents = allStudents
//           .where((s) => (s.otherInfo?['roll_no'] ?? '')
//               .toString()
//               .toLowerCase()
//               .contains(query.toLowerCase()))
//           .toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: AppColors.primary,
//         title: const Text("Student Directory", style: TextStyle(color: Colors.white)),
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           _buildSearchBar(),
//           Expanded(
//             child: isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _buildStudentList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchBar() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       color: AppColors.primary,
//       child: TextField(
//         controller: searchController,
//         onChanged: _filterSearch,
//         style: const TextStyle(color: Colors.white),
//         decoration: InputDecoration(
//           hintText: "Search by Roll Number...",
//           hintStyle: const TextStyle(color: Colors.white70),
//           prefixIcon: const Icon(Icons.search, color: Colors.white70),
//           filled: true,
//           fillColor: Colors.white.withOpacity(0.1),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide.none,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStudentList() {
//     if (filteredStudents.isEmpty) {
//       return const Center(child: Text("No students found."));
//     }
//     return ListView.builder(
//       padding: const EdgeInsets.all(12),
//       itemCount: filteredStudents.length,
//       itemBuilder: (context, index) {
//         final student = filteredStudents[index];
//         return _buildStudentCard(student);
//       },
//     );
//   }

//   Widget _buildStudentCard(Student student) {
//     return Card(
//       elevation: 2,
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       color: AppColors.card,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             // Left Side: Student Details
//             Expanded(
//               flex: 3,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     student.name.toUpperCase(),
//                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
//                   ),
//                   const SizedBox(height: 4),
//                  _detailRow(Icons.badge, "Roll: ${student.otherInfo?['roll_no'] ?? 'N/A'}"),
//                   _detailRow(Icons.email, student.parentEmail),
//                   const SizedBox(height: 10),
//                   const Text("Attendance Stats", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
//                   _attendanceRow("Weekly: 85%", "Monthly: 92%"),
//                 ],
//               ),
//             ),

//             // Right Side: Cute Mini Pie Chart
//             Expanded(
//               flex: 1,
//               child: SizedBox(
//                 height: 60,
//                 child: PieChart(
//                   PieChartData(
//                     sectionsSpace: 0,
//                     centerSpaceRadius: 15,
//                     sections: [
//                       PieChartSectionData(color: AppColors.success, value: 85, radius: 10, showTitle: false),
//                       PieChartSectionData(color: AppColors.error, value: 15, radius: 10, showTitle: false),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _detailRow(IconData icon, String text) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         children: [
//           Icon(icon, size: 14, color: AppColors.textSecondary),
//           const SizedBox(width: 6),
//           Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
//         ],
//       ),
//     );
//   }

//   Widget _attendanceRow(String week, String month) {
//     return Row(
//       children: [
//         Text(week, style: const TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold)),
//         const SizedBox(width: 10),
//         Text(month, style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
//       ],
//     );
//   }
// }






import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../models/student_model.dart';
import '../theme/app_colors.dart';

class AllStudentsPage extends StatefulWidget {
  @override
  State<AllStudentsPage> createState() => _AllStudentsPageState();
}

class _AllStudentsPageState extends State<AllStudentsPage> {
  List<Student> allStudents = [];
  List<Student> filteredStudents = [];
  bool isLoading = true;
  String? selectedClass;
  List<String> classes = ["Play Group",
  "1-A",
  "1-B",
  "2-A",
  "2-B",
  "3-A",
  "3-B",
  "4-A",
  "4-B",
  "5-A",
  "5-B",
  "6-A",
  "6-B",
  "7-A",
  "7-B",
  "8-A",
  "8-B",
  "9-A",
  "9-B",
  "10-A",
  "10-B",]; // Example classes
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents({String? studentClass}) async {
    setState(() => isLoading = true);
    final students = await ApiService.getAllStudents(
      studentClass: studentClass,
    );
    setState(() {
      allStudents = students;
      filteredStudents = students;
      isLoading = false;
    });
  }

  void _filterSearch(String query) {
    setState(() {
      filteredStudents = allStudents
          .where(
            (s) => (s.otherInfo?['roll_no'] ?? '')
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          "Student Directory",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildClassDropdown(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildStudentList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.primary,
      child: TextField(
        controller: searchController,
        onChanged: _filterSearch,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search by Roll Number...",
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildClassDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButton<String>(
        isExpanded: true,
        value: selectedClass,
        hint: const Text("Select Class"),
        items: classes
            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
            .toList(),
        onChanged: (value) {
          setState(() => selectedClass = value);
          _fetchStudents(studentClass: value);
        },
      ),
    );
  }

  Widget _buildStudentList() {
    if (filteredStudents.isEmpty) {
      return const Center(child: Text("No students found."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        return _buildStudentCard(student);
      },
    );
  }

  Widget _buildStudentCard(Student student) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: AppColors.card,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Left Side: Student Details + Stats
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _detailRow(
                    Icons.badge,
                    "Roll: ${student.otherInfo?['roll_no'] ?? 'N/A'}",
                  ),
                  _detailRow(Icons.email, student.parentEmail),
                  const SizedBox(height: 10),
                  const Text(
                    "Attendance Stats",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  FutureBuilder<Map<String, dynamic>>(
                    future: _fetchStudentStats(student.id!),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return const SizedBox(
                          height: 30,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      final stats = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _attendanceRow(
                            "Weekly: ${stats['weekly']}%",
                            "Monthly: ${stats['monthly']}%",
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            height: 60,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 0,
                                centerSpaceRadius: 15,
                                sections: [
                                  PieChartSectionData(
                                    color: AppColors.success,
                                    value: stats['weekly'].toDouble(),
                                    radius: 10,
                                    showTitle: false,
                                  ),
                                  PieChartSectionData(
                                    color: AppColors.error,
                                    value: (100 - stats['weekly']).toDouble(),
                                    radius: 10,
                                    showTitle: false,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _attendanceRow(String week, String month) {
    return Row(
      children: [
        Text(
          week,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.success,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          month,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Fetch weekly & monthly attendance from backend
  Future<Map<String, int>> _fetchStudentStats(int studentId) async {
    int weeklyPercent = 0;
    int monthlyPercent = 0;

    // Weekly
    final weeklyRes = await ApiService.getStudentWeekly(studentId);
    if (weeklyRes.isNotEmpty) {
     final totalDays = weeklyRes.fold<int>(
  0,
  (sum, e) =>
      sum +
      int.parse((e['present'] ?? 0).toString()) +
      int.parse((e['absent'] ?? 0).toString()),
);

final presentDays = weeklyRes.fold<int>(
  0,
  (sum, e) => sum + int.parse((e['present'] ?? 0).toString()),
);

      if (totalDays > 0)
        weeklyPercent = ((presentDays / totalDays) * 100).round();
    }

    // Monthly
    final monthlyRes = await ApiService.getStudentMonthly(studentId);
    if (monthlyRes.isNotEmpty) {
     final present = int.parse(monthlyRes.firstWhere(
  (e) => e['status'] == 'Present',
  orElse: () => {'count': 0},
)['count'].toString());

final total = monthlyRes.fold<int>(
  0,
  (sum, e) => sum + int.parse((e['count'] ?? 0).toString()),
);

      if (total > 0) monthlyPercent = ((present / total) * 100).round();
    }

    return {'weekly': weeklyPercent, 'monthly': monthlyPercent};
  }
}
