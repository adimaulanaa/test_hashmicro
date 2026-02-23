import 'package:attendance_app/core/constants/media_colors.dart';
import 'package:attendance_app/core/utils/botton.dart';
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
        title: const Text(
          'Pilih Lokasi',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
        child:  UIButton(
          label: 'Simpan Lokasi',
          onPressed: () async {
            final geoPoint = await _pickerController
                .selectAdvancedPositionPicker();
            if (context.mounted) {
              Navigator.pop(context, geoPoint);
            }
          },
          color: AppColors.primary,
          type: UIButtonType.filled,
        ),
      ),
    );
  }
}
