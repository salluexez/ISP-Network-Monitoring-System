import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/device.dart';

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  return DeviceRepository(ref.read(dioProvider));
});

class DeviceRepository {
  DeviceRepository(this._dio);

  final Dio _dio;

  Future<DeviceListResult> list({
    String? search,
    String? vendor,
    String? deviceType,
    String? locationId,
    int page = 1,
    int pageSize = 25,
    String sortBy = 'created_at',
    String sortDir = 'desc',
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/devices',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (vendor != null && vendor.isNotEmpty) 'vendor': vendor,
        if (deviceType != null && deviceType.isNotEmpty)
          'device_type': deviceType,
        if (locationId != null && locationId.isNotEmpty)
          'location_id': locationId,
        'page': page,
        'page_size': pageSize,
        'sort_by': sortBy,
        'sort_dir': sortDir,
      },
    );
    return DeviceListResult.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<Device> get(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/devices/$id');
    return Device.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<Device> create(Map<String, dynamic> payload) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/devices',
      data: payload,
    );
    return Device.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<Device> update(String id, Map<String, dynamic> payload) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/devices/$id',
      data: payload,
    );
    return Device.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<void> delete(String id) async {
    await _dio.delete<void>('/devices/$id');
  }
}
