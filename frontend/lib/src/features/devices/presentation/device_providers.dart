import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/device_repository.dart';
import '../domain/device.dart';

const deviceVendors = [
  'MikroTik',
  'Ubiquiti',
  'Huawei',
  'VSOL',
  'BDCOM',
  'Cisco',
  'Generic',
];
const deviceTypes = [
  'ROUTER',
  'SWITCH',
  'OLT',
  'ONU',
  'TOWER',
  'ACCESS_POINT',
  'SERVER',
];
const deviceStatuses = ['ONLINE', 'OFFLINE', 'UNKNOWN'];

final deviceSearchProvider = NotifierProvider<DeviceSearchController, String>(
  DeviceSearchController.new,
);
final deviceVendorFilterProvider =
    NotifierProvider<DeviceVendorFilterController, String?>(
      DeviceVendorFilterController.new,
    );
final deviceTypeFilterProvider =
    NotifierProvider<DeviceTypeFilterController, String?>(
      DeviceTypeFilterController.new,
    );
final deviceLocationFilterProvider =
    NotifierProvider<DeviceLocationFilterController, String?>(
      DeviceLocationFilterController.new,
    );
final devicePageProvider = NotifierProvider<DevicePageController, int>(
  DevicePageController.new,
);
final deviceSortByProvider = NotifierProvider<DeviceSortByController, String>(
  DeviceSortByController.new,
);
final deviceSortDirProvider = NotifierProvider<DeviceSortDirController, String>(
  DeviceSortDirController.new,
);

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

class DeviceSearchController extends Notifier<String> {
  @override
  String build() => '';

  void setValue(String value) => state = value;
}

class DeviceVendorFilterController extends Notifier<String?> {
  @override
  String? build() => null;

  void setValue(String? value) => state = value;
}

class DeviceTypeFilterController extends Notifier<String?> {
  @override
  String? build() => null;

  void setValue(String? value) => state = value;
}

class DeviceLocationFilterController extends Notifier<String?> {
  @override
  String? build() => null;

  void setValue(String? value) => state = value;
}

class DevicePageController extends Notifier<int> {
  @override
  int build() => 1;

  void setValue(int value) => state = value;
}

class DeviceSortByController extends Notifier<String> {
  @override
  String build() => 'created_at';

  void setValue(String value) => state = value;
}

class DeviceSortDirController extends Notifier<String> {
  @override
  String build() => 'desc';

  void setValue(String value) => state = value;
}
