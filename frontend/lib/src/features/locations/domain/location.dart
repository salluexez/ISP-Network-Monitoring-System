class NetworkLocation {
  const NetworkLocation({
    required this.id,
    required this.locationName,
    required this.locationType,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.parentLocationId,
  });

  final String id;
  final String locationName;
  final String locationType;
  final double? latitude;
  final double? longitude;
  final String? parentLocationId;
  final DateTime createdAt;

  factory NetworkLocation.fromJson(Map<String, dynamic> json) {
    return NetworkLocation(
      id: json['id'] as String,
      locationName: json['location_name'] as String,
      locationType: json['location_type'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      parentLocationId: json['parent_location_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class LocationListResult {
  const LocationListResult({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<NetworkLocation> items;
  final int total;
  final int page;
  final int pageSize;

  factory LocationListResult.fromJson(Map<String, dynamic> json) {
    return LocationListResult(
      items: (json['items'] as List<dynamic>)
          .map((item) => NetworkLocation.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      pageSize: json['page_size'] as int,
    );
  }
}
