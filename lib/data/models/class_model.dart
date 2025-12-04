class ClassModel {
  final String id;
  final String name;
  final String lecturerId;
  final List<String> studentIds;

  ClassModel({
    required this.id,
    required this.name,
    required this.lecturerId,
    this.studentIds = const [],
  });

  factory ClassModel.fromMap(String id, Map<String, dynamic> map) {
    return ClassModel(
      id: id,
      name: map['name'] ?? '',
      lecturerId: map['lecturerId'] ?? '',
      studentIds: List<String>.from(map['studentIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'lecturerId': lecturerId,
      'studentIds': studentIds,
    };
  }
}
