



class Student {
  int? id; // 👈 Add this
  String name;
  String rollNo;
  String parentEmail;
  Map<String, dynamic>? otherInfo;
  List<double>? faceEmbedding;

  Student({
    this.id, // 👈 Add this
    required this.name,
    required this.rollNo,
    required this.parentEmail,
    this.otherInfo,
    this.faceEmbedding,
  });

 factory Student.fromJson(Map<String, dynamic> json) {
  // Extract roll_no safely from other_info
  var other = json['other_info'];
  String extractedRoll = '';
  if (other != null && other['roll_no'] != null) {
    extractedRoll = other['roll_no'].toString(); // .toString() is safer!
  }

  return Student(
    id: json['id'],
    name: json['name'] ?? 'Unknown',
    rollNo: extractedRoll,
    parentEmail: json['parent_email'] ?? '',
    otherInfo: json['other_info'],
    faceEmbedding: json['face_embedding'] != null
        ? List<double>.from((json['face_embedding'] as List).map((e) => (e as num).toDouble()))
        : null,
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id, // 👈 Include it here
      'name': name,
      'face_embedding': faceEmbedding,
      'parent_email': parentEmail,
      'other_info': otherInfo ?? {'roll_no': rollNo},
    };
  }
}