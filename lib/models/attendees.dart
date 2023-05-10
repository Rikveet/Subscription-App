class Attendee {
  String firstName;
  String lastName;
  String email;
  String phoneNumber;
  String city;

  Attendee({required this.firstName, required this.lastName, required this.email, this.phoneNumber = '', required this.city});
}
