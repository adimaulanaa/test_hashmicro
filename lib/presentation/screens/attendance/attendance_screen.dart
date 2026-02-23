import 'dart:async';

import 'package:attendance_app/core/constants/media_colors.dart';
import 'package:attendance_app/presentation/bloc/attendance/attendance_bloc.dart';
import 'package:attendance_app/presentation/bloc/attendance/attendance_event.dart';
import 'package:attendance_app/presentation/bloc/attendance/attendance_state.dart';
import 'package:attendance_app/presentation/screens/attendance/attendance_history_screen.dart';
import 'package:attendance_app/presentation/widgets/slide_action_button.dart';
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
  final todayTime = DateTime.now();
  Timer? _timer;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    context.read<AttendanceBloc>().add(GetAttendancesEvent(widget.location.id));
    _startTimer();
  }

  void _startTimer() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AttendanceBloc, AttendanceState>(
        listenWhen: (previous, current) =>
            current is AttendanceSuccess ||
            current is AttendanceRejected ||
            current is AttendanceError,
        buildWhen: (previous, current) =>
            current is AttendanceLoaded || current is AttendanceInitial,
        listener: (context, state) {
          if (state is AttendanceSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            context.read<AttendanceBloc>().add(
              GetAttendancesEvent(widget.location.id),
            );
          }
          if (state is AttendanceRejected) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
            context.read<AttendanceBloc>().add(
              GetAttendancesEvent(widget.location.id),
            );
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
          if (state is AttendanceLoaded) {
            final today = state.todayAttendance;
            final hasCheckin = today?.checkinTime != null;
            final hasCheckout = today?.checkoutTime != null;

            return Stack(
              children: [
                Container(
                  height: mediaQueryHeight * 0.35,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            const Text(
                              'Attendance',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.history,
                                  color: Colors.white,
                                ),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AttendanceHistoryScreen(
                                        locationId: widget.location.id,
                                      ),
                                    ),
                                  );
                                  if (context.mounted) {
                                    context.read<AttendanceBloc>().add(
                                      GetAttendancesEvent(widget.location.id),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: mediaQueryHeight * 0.03),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircleAvatar(
                            radius: 45,
                            backgroundColor: AppColors.secondary,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mobile Developer',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Adi Maulana',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(todayTime),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: Container(
                          width: mediaQueryWidth * 0.8,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentTime,
                                style: const TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: AppColors.primary,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        widget.location.name,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: mediaQueryHeight * 0.05),
                      if (!hasCheckin)
                        SlideActionButton(
                          label:
                              context.watch<AttendanceBloc>().state
                                  is AttendanceLoading
                              ? 'Checking in...'
                              : 'Slide to Check In',
                          color: AppColors.primary,
                          thumbIcon: Icons.login,
                          isLoading:
                              context.watch<AttendanceBloc>().state
                                  is AttendanceLoading,
                          onSlideComplete: () {
                            context.read<AttendanceBloc>().add(
                              CheckinEvent(
                                locationId: widget.location.id,
                                locationLatitude: widget.location.latitude,
                                locationLongitude: widget.location.longitude,
                              ),
                            );
                          },
                        )
                      else if (hasCheckin && !hasCheckout)
                        SlideActionButton(
                          label:
                              context.watch<AttendanceBloc>().state
                                  is AttendanceLoading
                              ? 'Checking out...'
                              : 'Slide to Check Out',
                          color: AppColors.primary,
                          thumbIcon: Icons.logout,
                          isLoading:
                              context.watch<AttendanceBloc>().state
                                  is AttendanceLoading,
                          onSlideComplete: () {
                            context.read<AttendanceBloc>().add(
                              CheckoutEvent(
                                attendanceId: today!.id,
                                locationId: widget.location.id,
                                locationLatitude: widget.location.latitude,
                                locationLongitude: widget.location.longitude,
                              ),
                            );
                          },
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Center(
                            child: Text(
                              'Absensi hari ini selesai',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
