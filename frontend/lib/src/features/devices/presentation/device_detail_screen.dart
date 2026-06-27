import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/responsive_page.dart';
import '../data/device_repository.dart';
import 'device_providers.dart';
import 'device_status_badge.dart';

class DeviceDetailScreen extends ConsumerWidget {
  const DeviceDetailScreen({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(deviceDetailProvider(deviceId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Details'),
        actions: [
          IconButton(
            tooltip: 'Edit device',
            onPressed: () => context.go('/devices/$deviceId/edit'),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            tooltip: 'Delete device',
            onPressed: () async {
              await ref.read(deviceRepositoryProvider).delete(deviceId);
              ref.invalidate(devicesProvider);
              if (context.mounted) context.go('/devices');
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ResponsivePage(
        child: device.when(
          data: (item) => ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.deviceName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  DeviceStatusBadge(status: item.status),
                ],
              ),
              const SizedBox(height: 20),
              _InfoRow(label: 'Vendor', value: item.vendor),
              _InfoRow(label: 'IP Address', value: item.ipAddress),
              _InfoRow(label: 'Device Type', value: item.deviceType),
              _InfoRow(label: 'Hostname', value: item.hostname ?? '-'),
              _InfoRow(label: 'Location', value: item.locationId ?? '-'),
              _InfoRow(
                label: 'Parent Device',
                value: item.parentDeviceId ?? '-',
              ),
              _InfoRow(label: 'Description', value: item.description ?? '-'),
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
