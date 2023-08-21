class AttendanceRecord {
  int? id;
  DateTime date;
  int attendeeId;

  AttendanceRecord({this.id = -1, required this.date, required this.attendeeId});
}
