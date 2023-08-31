import 'dart:async';

import 'package:radha_swami_management_system/constants.dart';
import 'package:radha_swami_management_system/redux/app_state.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';


class AttendeeListStore {
  List<Map<String, dynamic>> list;
  StreamSubscription<List<Map<String, dynamic>>>? observer;
  AttendeeListStore({this.list = const [], this.observer});
}

class SetAttendeesAction {
  List<Map<String, dynamic>> attendees;

  SetAttendeesAction(this.attendees);
}

class AttendeesObserverAttached {
  StreamSubscription<List<Map<String, dynamic>>> attached;

  AttendeesObserverAttached(this.attached);
}

// TODO: make a observer and state to send error messages from thunk actions
// Thunk observer to listen to the supabase changes to the attendee table
ThunkAction<AppState> listenToAttendees() {
  return (Store<AppState> store) async {
    if (store.state.attendeeStore.observer != null) {
      // listener attached
      return;
    }
    final attendeesObserver = CLIENT
        .from('attendee')
        .stream(primaryKey: ['id'])
        .order('name', ascending: true)
        .listen((List<Map<String, dynamic>> data) {
      // subscribe to the attendee table
      store.dispatch(SetAttendeesAction(data));
    });
    store.dispatch(AttendeesObserverAttached(attendeesObserver));
  };
}

AppState attendeesReducer(AppState state, dynamic action) {
  switch (action) {
    case SetAttendeesAction:
      {
        return AppState(
            attendeeStore: AttendeeListStore(list: action.attendees, observer: state.attendeeStore.observer),
            authorizedUserStore: state.authorizedUserStore,
            attendanceRecords: state.attendanceRecords,
            userStore: state.userStore);
      }
    case AttendeesObserverAttached:
      {
        return AppState(
            attendeeStore: AttendeeListStore(list: state.attendeeStore.list, observer: action.attached),
            authorizedUserStore: state.authorizedUserStore,
            attendanceRecords: state.attendanceRecords,
            userStore: state.userStore);
      }
  }
  return state;
}
