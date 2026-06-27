import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/responsive_page.dart';
import '../../locations/presentation/location_providers.dart';
import '../data/device_repository.dart';
import '../domain/device.dart';
import 'device_providers.dart';

class DeviceFormScreen extends ConsumerStatefulWidget {
  const DeviceFormScreen({this.deviceId, super.key});

  final String? deviceId;

  @override
  ConsumerState<DeviceFormScreen> createState() => _DeviceFormScreenState();
}

class _DeviceFormScreenState extends ConsumerState<DeviceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _hostname = TextEditingController();
  final _ip = TextEditingController();
  final _description = TextEditingController();
  String _vendor = deviceVendors.first;
  String _deviceType = deviceTypes.first;
  String _status = 'UNKNOWN';
  String? _locationId;
  bool _hydrated = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _hostname.dispose();
    _ip.dispose();
    _description.dispose();
    super.dispose();
  }

  void _hydrate(Device device) {
    if (_hydrated) return;
    _hydrated = true;
    _name.text = device.deviceName;
    _hostname.text = device.hostname ?? '';
    _ip.text = device.ipAddress;
    _description.text = device.description ?? '';
    _vendor = device.vendor;
    _deviceType = device.deviceType;
    _status = device.status;
    _locationId = device.locationId;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final payload = {
      'device_name': _name.text.trim(),
      'hostname': _hostname.text.trim().isEmpty ? null : _hostname.text.trim(),
      'vendor': _vendor,
      'device_type': _deviceType,
      'ip_address': _ip.text.trim(),
      'location_id': _locationId,
      'status': _status,
      'description': _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
    };

    try {
      final repository = ref.read(deviceRepositoryProvider);
      final saved = widget.deviceId == null
          ? await repository.create(payload)
          : await repository.update(widget.deviceId!, payload);
      ref.invalidate(devicesProvider);
      ref.invalidate(deviceDetailProvider(saved.id));
      if (mounted) context.go('/devices/${saved.id}');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final existing = widget.deviceId == null
        ? null
        : ref.watch(deviceDetailProvider(widget.deviceId!));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deviceId == null ? 'Add Device' : 'Edit Device'),
      ),
      body: ResponsivePage(
        maxWidth: 860,
        child:
            existing?.when(
              data: (device) {
                _hydrate(device);
                return _form();
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(error.toString())),
            ) ??
            _form(),
      ),
    );
  }

  Widget _form() {
    final locationState = ref.watch(locationsProvider);
    final locations = locationState.hasValue
        ? locationState.value?.items ?? const []
        : const [];
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Device Name'),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Device name is required.'
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _hostname,
            decoration: const InputDecoration(labelText: 'Hostname'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _vendor,
                  decoration: const InputDecoration(labelText: 'Vendor'),
                  items: deviceVendors
                      .map(
                        (item) =>
                            DropdownMenuItem(value: item, child: Text(item)),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _vendor = value ?? deviceVendors.first),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _deviceType,
                  decoration: const InputDecoration(labelText: 'Device Type'),
                  items: deviceTypes
                      .map(
                        (item) =>
                            DropdownMenuItem(value: item, child: Text(item)),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _deviceType = value ?? deviceTypes.first),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _ip,
            decoration: const InputDecoration(labelText: 'IP Address'),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'IP address is required.'
                : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            initialValue: _locationId,
            decoration: const InputDecoration(labelText: 'Location'),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Unassigned'),
              ),
              ...locations.map(
                (item) => DropdownMenuItem<String?>(
                  value: item.id,
                  child: Text(item.locationName),
                ),
              ),
            ],
            onChanged: (value) => setState(() => _locationId = value),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: deviceStatuses
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) => setState(() => _status = value ?? 'UNKNOWN'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _description,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Save Device'),
            ),
          ),
        ],
      ),
    );
  }
}
