import 'package:attendance_app/presentation/bloc/attendance/attendance_bloc.dart';
import 'package:attendance_app/presentation/bloc/attendance/attendance_event.dart';
import 'package:attendance_app/presentation/bloc/attendance/attendance_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/location_entity.dart';

class AttendanceScreen extends StatefulWidget {
  final LocationEntity location;

  const AttendanceScreen({super.key, required this.location});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AttendanceBloc>().add(GetAttendancesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.location.name),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (_) => AttendanceHistoryScreen(
              //       locationId: widget.location.id,
              //     ),
              //   ),
              // );
            },
          ),
        ],
      ),
      body: BlocConsumer<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            context.read<AttendanceBloc>().add(GetAttendancesEvent());
          }
          if (state is AttendanceRejected) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
            context.read<AttendanceBloc>().add(GetAttendancesEvent());
          }
          if (state is AttendanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AttendanceLoaded) {
            final today = state.todayAttendance;
            final hasCheckin = today?.checkinTime != null;
            final hasCheckout = today?.checkoutTime != null;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // info lokasi
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informasi Lokasi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.blue, size: 20),
                              const SizedBox(width: 8),
                              Text(widget.location.name),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.my_location, color: Colors.grey, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Lat: ${widget.location.latitude.toStringAsFixed(6)}, Lng: ${widget.location.longitude.toStringAsFixed(6)}',
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: const [
                              Icon(Icons.radar, color: Colors.orange, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Radius maksimal: 50 meter',
                                style: TextStyle(color: Colors.orange, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // status absensi hari ini
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Absensi Hari Ini',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildAttendanceRow(
                            label: 'Check In',
                            time: today?.checkinTime,
                            status: today?.checkinStatus,
                          ),
                          const Divider(),
                          _buildAttendanceRow(
                            label: 'Check Out',
                            time: today?.checkoutTime,
                            status: today?.checkoutStatus,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // tombol checkin
                  ElevatedButton.icon(
                    onPressed: hasCheckin
                        ? null
                        : () {
                            context.read<AttendanceBloc>().add(
                                  CheckinEvent(
                                    locationId: widget.location.id,
                                    locationLatitude: widget.location.latitude,
                                    locationLongitude: widget.location.longitude,
                                  ),
                                );
                          },
                    icon: const Icon(Icons.login),
                    label: Text(hasCheckin ? 'Sudah Check In' : 'Check In'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // tombol checkout
                  ElevatedButton.icon(
                    onPressed: (!hasCheckin || hasCheckout)
                        ? null
                        : () {
                            context.read<AttendanceBloc>().add(
                                  CheckoutEvent(
                                    attendanceId: today!.id,
                                    locationId: widget.location.id,
                                    locationLatitude: widget.location.latitude,
                                    locationLongitude: widget.location.longitude,
                                  ),
                                );
                          },
                    icon: const Icon(Icons.logout),
                    label: Text(hasCheckout ? 'Sudah Check Out' : 'Check Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildAttendanceRow({
    required String label,
    DateTime? time,
    String? status,
  }) {
    final hasData = time != null;
    final isApproved = status == 'approved';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          if (!hasData)
            const Text('-', style: TextStyle(color: Colors.grey))
          else
            Row(
              children: [
                Text(
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isApproved ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isApproved ? 'Approved' : 'Rejected',
                    style: TextStyle(
                      color: isApproved ? Colors.green.shade700 : Colors.red.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}