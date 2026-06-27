import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/responsive_page.dart';
import 'device_providers.dart';
import 'device_status_badge.dart';

class DeviceListScreen extends ConsumerWidget {
  const DeviceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(devicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
        actions: [
          IconButton(
            tooltip: 'Locations',
            onPressed: () => context.go('/locations'),
            icon: const Icon(Icons.location_on_outlined),
          ),
          IconButton(
            tooltip: 'Add device',
            onPressed: () => context.go('/devices/new'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ResponsivePage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DeviceFilters(),
            const SizedBox(height: 16),
            Expanded(
              child: devices.when(
                data: (result) => Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        itemCount: result.items.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final device = result.items[index];
                          return Card(
                            child: ListTile(
                              onTap: () => context.go('/devices/${device.id}'),
                              title: Text(device.deviceName),
                              subtitle: Text(
                                '${device.vendor} • ${device.deviceType} • ${device.ipAddress}',
                              ),
                              trailing: DeviceStatusBadge(
                                status: device.status,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    _Pagination(
                      page: result.page,
                      total: result.total,
                      pageSize: result.pageSize,
                      onChanged: (page) =>
                          ref.read(devicePageProvider.notifier).setValue(page),
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _ErrorState(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(devicesProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceFilters extends ConsumerWidget {
  const _DeviceFilters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 280,
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Search devices',
            ),
            onChanged: (value) {
              ref.read(devicePageProvider.notifier).setValue(1);
              ref.read(deviceSearchProvider.notifier).setValue(value);
            },
          ),
        ),
        _DropdownFilter(
          label: 'Vendor',
          value: ref.watch(deviceVendorFilterProvider),
          items: deviceVendors,
          onChanged: (value) {
            ref.read(devicePageProvider.notifier).setValue(1);
            ref.read(deviceVendorFilterProvider.notifier).setValue(value);
          },
        ),
        _DropdownFilter(
          label: 'Type',
          value: ref.watch(deviceTypeFilterProvider),
          items: deviceTypes,
          onChanged: (value) {
            ref.read(devicePageProvider.notifier).setValue(1);
            ref.read(deviceTypeFilterProvider.notifier).setValue(value);
          },
        ),
        _DropdownFilter(
          label: 'Sort',
          value: ref.watch(deviceSortByProvider),
          items: const ['created_at', 'device_name', 'ip_address', 'status'],
          onChanged: (value) => ref
              .read(deviceSortByProvider.notifier)
              .setValue(value ?? 'created_at'),
        ),
      ],
    );
  }
}

class _DropdownFilter extends StatelessWidget {
  const _DropdownFilter({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: [
          const DropdownMenuItem<String>(value: null, child: Text('All')),
          ...items.map(
            (item) => DropdownMenuItem(value: item, child: Text(item)),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  const _Pagination({
    required this.page,
    required this.total,
    required this.pageSize,
    required this.onChanged,
  });

  final int page;
  final int total;
  final int pageSize;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final maxPage = (total / pageSize).ceil().clamp(1, 999999);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('Page $page of $maxPage • $total devices'),
        IconButton(
          tooltip: 'Previous page',
          onPressed: page > 1 ? () => onChanged(page - 1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton(
          tooltip: 'Next page',
          onPressed: page < maxPage ? () => onChanged(page + 1) : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
