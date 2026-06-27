import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/location.dart';

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepository(ref.read(dioProvider));
});

class LocationRepository {
  LocationRepository(this._dio);

  final Dio _dio;

  Future<LocationListResult> list({
    String? search,
    String? locationType,
    String? parentLocationId,
    int page = 1,
    int pageSize = 25,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/locations',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (locationType != null && locationType.isNotEmpty) 'location_type': locationType,
        if (parentLocationId != null && parentLocationId.isNotEmpty) 'parent_location_id': parentLocationId,
        'page': page,
        'page_size': pageSize,
      },
    );
    return LocationListResult.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<NetworkLocation> get(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/locations/$id');
    return NetworkLocation.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<NetworkLocation> create(Map<String, dynamic> payload) async {
    final response = await _dio.post<Map<String, dynamic>>('/locations', data: payload);
    return NetworkLocation.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<NetworkLocation> update(String id, Map<String, dynamic> payload) async {
    final response = await _dio.put<Map<String, dynamic>>('/locations/$id', data: payload);
    return NetworkLocation.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<void> delete(String id) async {
    await _dio.delete<void>('/locations/$id');
  }
}
