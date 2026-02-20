import 'package:attendance_app/core/di/service_locator.dart';
import 'package:attendance_app/presentation/bloc/attendance/attendance_bloc.dart';
import 'package:attendance_app/presentation/bloc/location/location_bloc.dart';
import 'package:attendance_app/presentation/bloc/location/location_event.dart';
import 'package:attendance_app/presentation/screens/location/location_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator(); // register semua dependency di sini
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<LocationBloc>()..add(GetLocationsEvent()),
        ),
        BlocProvider(
          create: (_) => sl<AttendanceBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Attendance App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const LocationListScreen(),
      ),
    );
  }
}