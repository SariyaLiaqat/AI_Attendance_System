class Student {
  int? id; // 👈 Optional
  String name;
  String rollNo;
  String parentEmail;
  Map<String, dynamic>? otherInfo;
  String? studentClass; // ← New
  List<double>? faceEmbedding;

  Student({
    this.id,
    required this.name,
    required this.rollNo,
    required this.parentEmail,
    this.otherInfo,
    this.studentClass, // ← New
    this.faceEmbedding,
  });

  // From JSON (convert API response to Student object)
  factory Student.fromJson(Map<String, dynamic> json) {
    // Extract roll_no safely from other_info
    var other = json['other_info'];
    String extractedRoll = '';
    if (other != null && other['roll_no'] != null) {
      extractedRoll = other['roll_no'].toString();
    }

    String? extractedClass;
    if (json['class'] != null) {
      extractedClass = json['class'];
    }

    return Student(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
      rollNo: extractedRoll,
      parentEmail: json['parent_email'] ?? '',
      otherInfo: json['other_info'],
      studentClass: extractedClass, // ← Added
      faceEmbedding: json['face_embedding'] != null
          ? List<double>.from(
              (json['face_embedding'] as List).map((e) => (e as num).toDouble()))
          : null,
    );
  }

  // To JSON (send to backend)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'face_embedding': faceEmbedding,
      'parent_email': parentEmail,
      'other_info': otherInfo ?? {'roll_no': rollNo},
      'class': studentClass ?? 'Unknown', // ← Added
    };
  }
}
