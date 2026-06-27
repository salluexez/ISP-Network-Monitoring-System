class Device {
  const Device({
    required this.id,
    required this.deviceName,
    required this.vendor,
    required this.deviceType,
    required this.ipAddress,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.hostname,
    this.locationId,
    this.parentDeviceId,
    this.description,
  });

  final String id;
  final String deviceName;
  final String? hostname;
  final String vendor;
  final String deviceType;
  final String ipAddress;
  final String? locationId;
  final String? parentDeviceId;
  final String status;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as String,
      deviceName: json['device_name'] as String,
      hostname: json['hostname'] as String?,
      vendor: json['vendor'] as String,
      deviceType: json['device_type'] as String,
      ipAddress: json['ip_address'] as String,
      locationId: json['location_id'] as String?,
      parentDeviceId: json['parent_device_id'] as String?,
      status: json['status'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class DeviceListResult {
  const DeviceListResult({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<Device> items;
  final int total;
  final int page;
  final int pageSize;

  factory DeviceListResult.fromJson(Map<String, dynamic> json) {
    return DeviceListResult(
      items: (json['items'] as List<dynamic>)
          .map((item) => Device.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      pageSize: json['page_size'] as int,
    );
  }
}
