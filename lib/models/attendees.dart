class Attendee {
  int? id;
  String name;
  String email;
  String phoneNumber;
  String city;

  Attendee({this.id = -1, required this.name, required this.email, this.phoneNumber = '', required this.city});
}
