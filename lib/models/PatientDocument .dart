class PatientDocument {
  final int id;
  final int documentTypeId;
  final String mediaUrl;
  
  PatientDocument({
    required this.id,
    required this.documentTypeId,
    required this.mediaUrl,
  });
  
  factory PatientDocument.fromJson(Map<String, dynamic> json) {
    return PatientDocument(
      id: json['id'] as int,
      documentTypeId: json['document_type_id'] as int,
      mediaUrl: json['media_url'] as String,
    );
  }
}