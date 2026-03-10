import 'package:flutter/material.dart';

enum ShiftStatus {
  scheduled,
  active,
  completed;

  String get label {
    switch (this) {
      case ShiftStatus.scheduled:
        return 'Agendado';
      case ShiftStatus.active:
        return 'Ativo';
      case ShiftStatus.completed:
        return 'Encerrado';
    }
  }

  Color get color {
    switch (this) {
      case ShiftStatus.scheduled:
        return Colors.blue;
      case ShiftStatus.active:
        return Colors.green;
      case ShiftStatus.completed:
        return Colors.grey;
    }
  }
}

class Shift {
  final String id;
  final String userId;
  final String clinicId;
  final DateTime date;
  final String startTime; // Supabase returns "HH:mm:ss"
  final String endTime;   // Supabase returns "HH:mm:ss"
  final ShiftStatus status;
  
  // Optional enrichment fields
  final String? userName;
  final String? userRole;

  Shift({
    required this.id,
    required this.userId,
    required this.clinicId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.userName,
    this.userRole,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'],
      userId: json['user_id'],
      clinicId: json['clinic_id'],
      date: DateTime.parse(json['date']),
      startTime: json['start_time'],
      endTime: json['end_time'],
      status: ShiftStatus.values.byName(json['status']),
      userName: json['profiles']?['full_name'],
      userRole: json['profiles']?['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'clinic_id': clinicId,
      'date': date.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'status': status.name,
    };
  }

  Shift copyWith({
    String? id,
    String? userId,
    String? clinicId,
    DateTime? date,
    String? startTime,
    String? endTime,
    ShiftStatus? status,
    String? userName,
    String? userRole,
  }) {
    return Shift(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      clinicId: clinicId ?? this.clinicId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
    );
  }

  // UI Helpers
  String get formattedTime => '${startTime.substring(0, 5)} - ${endTime.substring(0, 5)}';
}
