import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/responsive_page.dart';
import 'location_providers.dart';

class LocationListScreen extends ConsumerWidget {
  const LocationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locations = ref.watch(locationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Locations'),
        actions: [
          IconButton(
            tooltip: 'Devices',
            onPressed: () => context.go('/devices'),
            icon: const Icon(Icons.router_outlined),
          ),
          IconButton(
            tooltip: 'Add location',
            onPressed: () => context.go('/locations/new'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ResponsivePage(
        child: Column(
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 280,
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: 'Search locations',
                    ),
                    onChanged: (value) {
                      ref.read(locationPageProvider.notifier).setValue(1);
                      ref.read(locationSearchProvider.notifier).setValue(value);
                    },
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String?>(
                    initialValue: ref.watch(locationTypeFilterProvider),
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All'),
                      ),
                      ...locationTypes.map(
                        (item) => DropdownMenuItem<String?>(
                          value: item,
                          child: Text(item),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      ref.read(locationPageProvider.notifier).setValue(1);
                      ref
                          .read(locationTypeFilterProvider.notifier)
                          .setValue(value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: locations.when(
                data: (result) => ListView.separated(
                  itemCount: result.items.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final location = result.items[index];
                    return Card(
                      child: ListTile(
                        onTap: () => context.go('/locations/${location.id}'),
                        leading: const Icon(Icons.location_on_outlined),
                        title: Text(location.locationName),
                        subtitle: Text(
                          '${location.locationType} • Parent: ${location.parentLocationId ?? '-'}',
                        ),
                      ),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text(error.toString())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
