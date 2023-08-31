import 'package:flutter/material.dart';
import 'package:radha_swami_management_system/constants.dart';
import 'package:radha_swami_management_system/main.dart';
import 'package:radha_swami_management_system/redux/app_state.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

class AttendanceStore {
  List<Map<String, dynamic>> list;

  AttendanceStore({this.list = const []});
}

class SetAttendanceAction {
  List<Map<String, dynamic>> attendance;

  SetAttendanceAction(this.attendance);
}

ThunkAction<AppState> getAttendanceThunk(String date) {
  return (Store<AppState> store) async {
    CLIENT.from('attendance').select('*, attendees(*)').eq('date', date).then((attendees) {
      final attendanceList = (attendees as List<dynamic>)
          .map((attendees) => {
                // merge the attendee data with the attendance data
                ...(attendees as Map<String, dynamic>),
              })
          .toList();
      debugPrint(attendanceList.toString());
      store.dispatch(SetAttendanceAction(attendanceList));
    });
  };
}

ThunkAction<AppState> addAttendee(int id, String date) {
  return (Store<AppState> store) async {
    await CLIENT.from('attendance').insert({'date': date, 'attendee_id': id});
  };
}

Future<void> removeAttendee(int id) async {
  try {
    await CLIENT.from('attendance').delete().eq('id', id);
  } catch (_) {}
}
