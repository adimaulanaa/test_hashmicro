import 'package:attendance_app/core/constants/media_colors.dart';
import 'package:attendance_app/core/utils/botton.dart';
import 'package:attendance_app/core/utils/custom_text_field.dart';
import 'package:attendance_app/presentation/bloc/location/location_bloc.dart';
import 'package:attendance_app/presentation/bloc/location/location_event.dart';
import 'package:attendance_app/presentation/bloc/location/location_state.dart';
import 'package:attendance_app/presentation/screens/location/pick_location_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geocoding/geocoding.dart';
import '../../../services/gps_service.dart';
import '../../../core/di/service_locator.dart';

class AddLocationScreen extends StatefulWidget {
  const AddLocationScreen({super.key});

  @override
  State<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  final _nameController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  bool _isLoadingGps = false;
  double? _selectedLat;
  double? _selectedLng;
  String? _address;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingGps = true);
    try {
      final position = await sl<GpsService>().getCurrentPosition();
      final address = await _getAddressFromLatLng(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _address = address;
        _selectedLat = position.latitude;
        _selectedLng = position.longitude;
        _latitudeController.text = position.latitude.toStringAsFixed(6);
        _longitudeController.text = position.longitude.toStringAsFixed(6);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoadingGps = false);
    }
  }

  void _submit() {
    String? error;
    if (_nameController.text.trim().isEmpty) {
      error = 'Nama lokasi tidak boleh kosong';
    } else if (_selectedLat == null || _selectedLng == null) {
      error = 'Pilih lokasi di peta atau gunakan lokasi saat ini';
    }

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return;
    }

    context.read<LocationBloc>().add(
      AddLocationEvent(
        name: _nameController.text.trim(),
        latitude: _selectedLat!,
        longitude: _selectedLng!,
      ),
    );
  }

  Future<String?> _getAddressFromLatLng(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return null;
      final place = placemarks.first;

      final parts = [
        if (place.subLocality != null && place.subLocality!.isNotEmpty)
          place.subLocality,
        if (place.locality != null && place.locality!.isNotEmpty)
          place.locality,
        if (place.subAdministrativeArea != null &&
            place.subAdministrativeArea!.isNotEmpty)
          place.subAdministrativeArea,
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty)
          place.administrativeArea,
      ];

      return parts.join(', ');
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Attendance Apps',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: BlocListener<LocationBloc, LocationState>(
        listener: (context, state) {
          if (state is LocationLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Lokasi berhasil ditambahkan'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
          if (state is LocationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Nama Lokasi',
                hintText: 'Contoh: Kantor Pusat',
                prefixIcon: Icons.business,
                controller: _nameController,
              ),
              if (_address != null)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.place, color: Colors.grey, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _address!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_selectedLat != null && _selectedLng != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Latitude',
                          hintText: '-',
                          prefixIcon: Icons.location_on,
                          enabled: false,
                          controller: _latitudeController,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: CustomTextField(
                          label: 'Longitude',
                          hintText: '-',
                          prefixIcon: Icons.location_on,
                          enabled: false,
                          controller: _longitudeController,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              UIButton(
                label: _isLoadingGps
                    ? 'Mengambil lokasi...'
                    : 'Gunakan Lokasi Saat Ini',
                onPressed: _getCurrentLocation,
                color: AppColors.secondary,
                type: UIButtonType.outlined,
              ),
              const SizedBox(height: 12),
              UIButton(
                label: 'Pilih Lokasi di Peta',
                color: AppColors.secondary,
                type: UIButtonType.outlined,
                onPressed: () async {
                  final geoPoint = await Navigator.push<GeoPoint>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PickLocationScreen(),
                    ),
                  );
                  if (geoPoint != null) {
                    final address = await _getAddressFromLatLng(
                      geoPoint.latitude,
                      geoPoint.longitude,
                    );

                    setState(() {
                      _address = address;
                      _selectedLat = geoPoint.latitude;
                      _selectedLng = geoPoint.longitude;
                      _latitudeController.text = geoPoint.latitude
                          .toStringAsFixed(6);
                      _longitudeController.text = geoPoint.longitude
                          .toStringAsFixed(6);
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: UIButton(
          label: 'Simpan Lokasi',
          onPressed: _submit,
          color: AppColors.primary,
          type: UIButtonType.filled,
        ),
      ),
    );
  }
}
