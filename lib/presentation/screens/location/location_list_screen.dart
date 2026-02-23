import 'package:attendance_app/core/constants/media_colors.dart';
import 'package:attendance_app/core/utils/botton.dart';
import 'package:attendance_app/presentation/bloc/location/location_bloc.dart';
import 'package:attendance_app/presentation/bloc/location/location_event.dart';
import 'package:attendance_app/presentation/bloc/location/location_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_location_screen.dart';
import '../attendance/attendance_screen.dart';

class LocationListScreen extends StatelessWidget {
  const LocationListScreen({super.key});

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
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, state) {
          if (state is LocationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LocationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<LocationBloc>().add(GetLocationsEvent()),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (state is LocationLoaded) {
            if (state.locations.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Belum ada lokasi\nTambahkan lokasi terlebih dahulu',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.locations.length,
              itemBuilder: (context, index) {
                final location = state.locations[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AttendanceScreen(location: location),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.secondary,
                        child: Icon(Icons.location_on, color: Colors.white),
                      ),
                      title: Text(
                        location.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Latitude: ${location.latitude.toStringAsFixed(6)}',
                          ),
                          Text(
                            'Longitude: ${location.longitude.toStringAsFixed(6)}',
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon:  Icon(
                              Icons.delete_outline,
                              color: AppColors.primary,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Hapus Lokasi'),
                                  content: Text(
                                    'Yakin ingin menghapus lokasi ${location.name}?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        context.read<LocationBloc>().add(
                                          DeleteLocationEvent(location.id),
                                        );
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        'Hapus',
                                        style: TextStyle(color: AppColors.primary),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: UIButton(
          label: 'Tambah Lokasi',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddLocationScreen()),
            );
          },
          color: AppColors.primary,
          type: UIButtonType.filled,
        ),
      ),
    );
  }
}
