import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/device_repository.dart';
import '../domain/device.dart';

const deviceVendors = ['MikroTik', 'Ubiquiti', 'Huawei', 'VSOL', 'BDCOM', 'Cisco', 'Generic'];
const deviceTypes = ['ROUTER', 'SWITCH', 'OLT', 'ONU', 'TOWER', 'ACCESS_POINT', 'SERVER'];
const deviceStatuses = ['ONLINE', 'OFFLINE', 'UNKNOWN'];

final deviceSearchProvider = StateProvider<String>((ref) => '');
final deviceVendorFilterProvider = StateProvider<String?>((ref) => null);
final deviceTypeFilterProvider = StateProvider<String?>((ref) => null);
final deviceLocationFilterProvider = StateProvider<String?>((ref) => null);
final devicePageProvider = StateProvider<int>((ref) => 1);
final deviceSortByProvider = StateProvider<String>((ref) => 'created_at');
final deviceSortDirProvider = StateProvider<String>((ref) => 'desc');

final devicesProvider = FutureProvider<DeviceListResult>((ref) {
  final repository = ref.read(deviceRepositoryProvider);
  return repository.list(
    search: ref.watch(deviceSearchProvider),
    vendor: ref.watch(deviceVendorFilterProvider),
    deviceType: ref.watch(deviceTypeFilterProvider),
    locationId: ref.watch(deviceLocationFilterProvider),
    page: ref.watch(devicePageProvider),
    sortBy: ref.watch(deviceSortByProvider),
    sortDir: ref.watch(deviceSortDirProvider),
  );
});

final deviceDetailProvider = FutureProvider.family<Device, String>((ref, id) {
  return ref.read(deviceRepositoryProvider).get(id);
});
