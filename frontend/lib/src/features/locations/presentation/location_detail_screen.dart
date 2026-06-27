import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/responsive_page.dart';
import '../data/location_repository.dart';
import 'location_providers.dart';

class LocationDetailScreen extends ConsumerWidget {
  const LocationDetailScreen({required this.locationId, super.key});

  final String locationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(locationDetailProvider(locationId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Details'),
        actions: [
          IconButton(
            tooltip: 'Edit location',
            onPressed: () => context.go('/locations/$locationId/edit'),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            tooltip: 'Delete location',
            onPressed: () async {
              await ref.read(locationRepositoryProvider).delete(locationId);
              ref.invalidate(locationsProvider);
              if (context.mounted) context.go('/locations');
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ResponsivePage(
        child: location.when(
          data: (item) => ListView(
            children: [
              Text(
                item.locationName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              _InfoRow(label: 'Type', value: item.locationType),
              _InfoRow(
                label: 'Latitude',
                value: item.latitude?.toString() ?? '-',
              ),
              _InfoRow(
                label: 'Longitude',
                value: item.longitude?.toString() ?? '-',
              ),
              _InfoRow(
                label: 'Parent Location',
                value: item.parentLocationId ?? '-',
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text(error.toString())),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(title: Text(label), subtitle: Text(value)),
    );
  }
}
