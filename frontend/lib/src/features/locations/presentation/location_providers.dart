import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/location_repository.dart';
import '../domain/location.dart';

const locationTypes = ['CORE', 'POP', 'TOWER', 'VILLAGE', 'OLT_ROOM'];

class LocationListQuery {
  const LocationListQuery({
    this.search,
    this.locationType,
    this.parentLocationId,
    this.page = 1,
    this.pageSize = 25,
  });

  final String? search;
  final String? locationType;
  final String? parentLocationId;
  final int page;
  final int pageSize;
}

final locationSearchProvider =
    NotifierProvider<LocationSearchController, String>(
      LocationSearchController.new,
    );
final locationTypeFilterProvider =
    NotifierProvider<LocationTypeFilterController, String?>(
      LocationTypeFilterController.new,
    );
final locationPageProvider = NotifierProvider<LocationPageController, int>(
  LocationPageController.new,
);

final locationsProvider = FutureProvider<LocationListResult>((ref) {
  final repository = ref.read(locationRepositoryProvider);
  return repository.list(
    search: ref.watch(locationSearchProvider),
    locationType: ref.watch(locationTypeFilterProvider),
    page: ref.watch(locationPageProvider),
  );
});

final locationDetailProvider = FutureProvider.family<NetworkLocation, String>((
  ref,
  id,
) {
  return ref.read(locationRepositoryProvider).get(id);
});

class LocationSearchController extends Notifier<String> {
  @override
  String build() => '';

  void setValue(String value) => state = value;
}

class LocationTypeFilterController extends Notifier<String?> {
  @override
  String? build() => null;

  void setValue(String? value) => state = value;
}

class LocationPageController extends Notifier<int> {
  @override
  int build() => 1;

  void setValue(int value) => state = value;
}
