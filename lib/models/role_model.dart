class Role {
  final int id;
  final String roleName;
  final List<int> permissionIds;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int? createdBy;
  final int? updatedBy;
  final int? deletedBy;

  Role({
    required this.id,
    required this.roleName,
    required this.permissionIds,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
    this.deletedBy,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    // Parse permission_ids which comes as a comma-separated string
    final permissionIdsString = json['permission_id']?.toString() ?? '';
    final permissionIds = permissionIdsString.split(',').map((id) {
      return int.tryParse(id.trim()) ?? 0;
    }).where((id) => id != 0).toList();

    // Handle ID conversion - try parsing as int first, then fallback to string parsing
    final dynamic idValue = json['id'];
    final int parsedId = idValue is int
        ? idValue
        : int.tryParse(idValue?.toString() ?? '0') ?? 0;

    // Handle status conversion
    final dynamic statusValue = json['status'];
    final int parsedStatus = statusValue is int
        ? statusValue
        : int.tryParse(statusValue?.toString() ?? '0') ?? 0;

    return Role(
      id: parsedId,
      roleName: json['role_name']?.toString() ?? '',
      permissionIds: permissionIds,
      status: parsedStatus,
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toString()),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'].toString())
          : null,
      createdBy: json['created_by'] is int
          ? json['created_by'] as int?
          : int.tryParse(json['created_by']?.toString() ?? ''),
      updatedBy: json['updated_by'] is int
          ? json['updated_by'] as int?
          : int.tryParse(json['updated_by']?.toString() ?? ''),
      deletedBy: json['deleted_by'] is int
          ? json['deleted_by'] as int?
          : int.tryParse(json['deleted_by']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role_name': roleName,
      'permission_id': permissionIds.join(','),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'created_by': createdBy,
      'updated_by': updatedBy,
      'deleted_by': deletedBy,
    };
  }
}