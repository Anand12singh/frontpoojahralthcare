class Medication {
  final int srNo;
  final String name;
  final String dosage;
  final String frequency;
  final String duration;

  Medication({
    required this.srNo,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      srNo: json['sr_no'] ?? 0,
      name: json['name_of_medication'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      duration: json['duration'] ?? '',
    );
  }
}
