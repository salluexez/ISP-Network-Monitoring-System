import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/responsive_page.dart';
import '../data/location_repository.dart';
import '../domain/location.dart';
import 'location_providers.dart';

class LocationFormScreen extends ConsumerStatefulWidget {
  const LocationFormScreen({this.locationId, super.key});

  final String? locationId;

  @override
  ConsumerState<LocationFormScreen> createState() => _LocationFormScreenState();
}

class _LocationFormScreenState extends ConsumerState<LocationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  String _type = locationTypes.first;
  String? _parentId;
  bool _hydrated = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  void _hydrate(NetworkLocation location) {
    if (_hydrated) return;
    _hydrated = true;
    _name.text = location.locationName;
    _latitude.text = location.latitude?.toString() ?? '';
    _longitude.text = location.longitude?.toString() ?? '';
    _type = location.locationType;
    _parentId = location.parentLocationId;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final payload = {
      'location_name': _name.text.trim(),
      'location_type': _type,
      'latitude': _latitude.text.trim().isEmpty
          ? null
          : double.parse(_latitude.text.trim()),
      'longitude': _longitude.text.trim().isEmpty
          ? null
          : double.parse(_longitude.text.trim()),
      'parent_location_id': _parentId,
    };

    try {
      final repository = ref.read(locationRepositoryProvider);
      final saved = widget.locationId == null
          ? await repository.create(payload)
          : await repository.update(widget.locationId!, payload);
      ref.invalidate(locationsProvider);
      ref.invalidate(locationDetailProvider(saved.id));
      if (mounted) context.go('/locations/${saved.id}');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final existing = widget.locationId == null
        ? null
        : ref.watch(locationDetailProvider(widget.locationId!));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.locationId == null ? 'Add Location' : 'Edit Location',
        ),
      ),
      body: ResponsivePage(
        maxWidth: 760,
        child:
            existing?.when(
              data: (location) {
                _hydrate(location);
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
            decoration: const InputDecoration(labelText: 'Location Name'),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Location name is required.'
                : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Location Type'),
            items: locationTypes
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) =>
                setState(() => _type = value ?? locationTypes.first),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            initialValue: _parentId,
            decoration: const InputDecoration(labelText: 'Parent Location'),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('No parent'),
              ),
              ...locations
                  .where((item) => item.id != widget.locationId)
                  .map(
                    (item) => DropdownMenuItem<String?>(
                      value: item.id,
                      child: Text(item.locationName),
                    ),
                  ),
            ],
            onChanged: (value) => setState(() => _parentId = value),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _latitude,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Latitude'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _longitude,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Longitude'),
                ),
              ),
            ],
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
              label: const Text('Save Location'),
            ),
          ),
        ],
      ),
    );
  }
}
