import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import '../../../services/gps_service.dart';
import '../../../core/di/service_locator.dart';

class PickLocationScreen extends StatefulWidget {
  const PickLocationScreen({super.key});

  @override
  State<PickLocationScreen> createState() => _PickLocationScreenState();
}

class _PickLocationScreenState extends State<PickLocationScreen> {
  late PickerMapController _pickerController;

  @override
  void initState() {
    super.initState();
    _pickerController = PickerMapController(
      initPosition: GeoPoint(latitude: -6.2088, longitude: 106.8456),
    );
  }

  @override
  void dispose() {
    _pickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPickerLocation(
      controller: _pickerController,
      appBarPicker: AppBar(
        title: const Text('Pilih Lokasi'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      onMapReady: (isReady) async {
        if (isReady) {
          try {
            final position = await sl<GpsService>().getCurrentPosition();
            await _pickerController.goToLocation(
              GeoPoint(
                latitude: position.latitude,
                longitude: position.longitude,
              ),
            );
          } catch (e) {
            debugPrint('GPS error: $e');
          }
        }
      },
      showDefaultMarkerPickWidget: true,
      pickerConfig: const CustomPickerLocationConfig(
        zoomOption: ZoomOption(initZoom: 15, minZoomLevel: 3, maxZoomLevel: 19),
      ),
      bottomWidgetPicker: Positioned(
        bottom: 16,
        left: 16,
        right: 16,
        child: ElevatedButton.icon(
          onPressed: () async {
            final geoPoint = await _pickerController
                .selectAdvancedPositionPicker();
            if (context.mounted) {
              Navigator.pop(context, geoPoint);
            }
          },
          icon: const Icon(Icons.check),
          label: const Text('Pilih Lokasi Ini'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}
