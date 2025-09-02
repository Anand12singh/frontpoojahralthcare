class DashboardResponse {
  final bool status;
  final String message;
  final DashboardData data;

  DashboardResponse({required this.status, required this.message, required this.data});

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      status: json['status'],
      message: json['message'],
      data: DashboardData.fromJson(json['data']),
    );
  }
}

class DashboardData {
  final String totalOperations;
  final List<SurgeryType> surgeryByType;
  final List<SurgeryLocation> surgeryByLocation;

  DashboardData({
    required this.totalOperations,
    required this.surgeryByType,
    required this.surgeryByLocation,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalOperations: json['total_operations'],
      surgeryByType: (json['surgery_by_type'] as List)
          .map((e) => SurgeryType.fromJson(e))
          .toList(),
      surgeryByLocation: (json['surgery_by_location'] as List)
          .map((e) => SurgeryLocation.fromJson(e))
          .toList(),
    );
  }
}

class SurgeryType {
  final String name;
  final int totalCount;

  SurgeryType({required this.name, required this.totalCount});

  factory SurgeryType.fromJson(Map<String, dynamic> json) {
    return SurgeryType(
      name: json['name'],
      totalCount: int.tryParse(json['total_count'].toString()) ?? 0,
    );
  }
}

class SurgeryLocation {
  final String location;
  final int totalNumber;

  SurgeryLocation({required this.location, required this.totalNumber});

  factory SurgeryLocation.fromJson(Map<String, dynamic> json) {
    return SurgeryLocation(
      location: json['location'],
      totalNumber: int.tryParse(json['total_number'].toString()) ?? 0,
    );
  }
}
