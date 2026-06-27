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

final locationSearchProvider = StateProvider<String>((ref) => '');
final locationTypeFilterProvider = StateProvider<String?>((ref) => null);
final locationPageProvider = StateProvider<int>((ref) => 1);

final locationsProvider = FutureProvider<LocationListResult>((ref) {
  final repository = ref.read(locationRepositoryProvider);
  return repository.list(
    search: ref.watch(locationSearchProvider),
    locationType: ref.watch(locationTypeFilterProvider),
    page: ref.watch(locationPageProvider),
  );
});

final locationDetailProvider = FutureProvider.family<NetworkLocation, String>((ref, id) {
  return ref.read(locationRepositoryProvider).get(id);
});
