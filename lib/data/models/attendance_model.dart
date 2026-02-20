import 'package:attendance_app/domain/entities/attendance_entity.dart';

class AttendanceModel extends AttendanceEntity {
  const AttendanceModel({
    required super.id,
    required super.locationId,
    super.checkinLatitude,
    super.checkinLongitude,
    super.checkinTime,
    super.checkinStatus,
    super.checkoutLatitude,
    super.checkoutLongitude,
    super.checkoutTime,
    super.checkoutStatus,
    required super.createdAt,
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'],
      locationId: map['location_id'],
      checkinLatitude: map['checkin_latitude'],
      checkinLongitude: map['checkin_longitude'],
      checkinTime: map['checkin_time'] != null
          ? DateTime.parse(map['checkin_time'])
          : null,
      checkinStatus: map['checkin_status'],
      checkoutLatitude: map['checkout_latitude'],
      checkoutLongitude: map['checkout_longitude'],
      checkoutTime: map['checkout_time'] != null
          ? DateTime.parse(map['checkout_time'])
          : null,
      checkoutStatus: map['checkout_status'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'location_id': locationId,
      'checkin_latitude': checkinLatitude,
      'checkin_longitude': checkinLongitude,
      'checkin_time': checkinTime?.toIso8601String(),
      'checkin_status': checkinStatus,
      'checkout_latitude': checkoutLatitude,
      'checkout_longitude': checkoutLongitude,
      'checkout_time': checkoutTime?.toIso8601String(),
      'checkout_status': checkoutStatus,
      'created_at': createdAt.toIso8601String(),
    };
  }
}