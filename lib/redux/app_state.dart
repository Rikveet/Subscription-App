import 'package:radha_swami_management_system/redux/slices/attendee_list_slice.dart';
import 'package:radha_swami_management_system/redux/slices/authorized_users_list_slice.dart';
import 'package:radha_swami_management_system/redux/slices/user_slice.dart';

class AppState {
  // stores
  AttendeeListStore attendeeStore;
  AuthorizedUserListStore authorizedUserStore;
  UserStore userStore;
  List<Map<String, dynamic>> attendanceRecords;

  AppState({
    required this.attendeeStore,
    required this.authorizedUserStore,
    required this.attendanceRecords,
    required this.userStore,
  });
}
