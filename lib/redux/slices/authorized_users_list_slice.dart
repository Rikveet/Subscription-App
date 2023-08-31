import 'dart:async';
import 'package:radha_swami_management_system/constants.dart';
import 'package:radha_swami_management_system/redux/app_state.dart';
import 'package:radha_swami_management_system/redux/slices/user_slice.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

class AuthorizedUserListStore {
  List<Map<String, dynamic>>? list;
  StreamSubscription<List<Map<String, dynamic>>>? observer;
  AuthorizedUserListStore({this.list, this.observer});
}


class SetAuthorizedUsersAction {
  List<Map<String, dynamic>> authorizedUsers;

  SetAuthorizedUsersAction(this.authorizedUsers);
}

class AuthorizedUsersObserverAttached {
  StreamSubscription<List<Map<String, dynamic>>> attached;

  AuthorizedUsersObserverAttached(this.attached);
}

// Thunk observer to listen to the supabase changes to the attendee table
ThunkAction<AppState> listenToAuthorizedUsers() {
  return (Store<AppState> store) async {
    if (store.state.authorizedUserStore.observer != null) {
      // listener attached
      return;
    }
    final authorizedUsersObserver =
    CLIENT.from('authorized_user').stream(primaryKey: ['id']).order('name', ascending: true).listen((List<Map<String, dynamic>> data) {
      // subscribe to the authorized users table
      final authorizedUsers = data;
      final clientEmail = CLIENT.auth.currentUser?.email;
      final Map<String, dynamic>? userRow = clientEmail != null
          ? authorizedUsers.firstWhere((user) => user['email'] == clientEmail, orElse: () {
        return {};
      })
          : null;
      if (userRow != null && userRow.isNotEmpty && authorizedUsers.isNotEmpty) {
        final permissions = (userRow['permissions'] as List<dynamic>).map((e) => e as String);
        bool isClientAdmin = permissions.contains("ADMIN");
        bool isClientEditor = permissions.contains("EDITOR");
        store.dispatch(SetUserEditorAction(isClientEditor));
        store.dispatch(SetUserAdminAction(isClientAdmin));
      }
    });

    store.dispatch(AuthorizedUsersObserverAttached(authorizedUsersObserver));
  };
}


AppState authorizedUsersReducer(AppState state, dynamic action) {
  switch(action){
    case SetAuthorizedUsersAction:
      {
        return AppState(
            attendeeStore: state.attendeeStore,
            authorizedUserStore: AuthorizedUserListStore(list: action.authorizedUsers, observer: state.authorizedUserStore.observer),
            attendanceRecords: state.attendanceRecords,
            userStore: state.userStore);
      }
    case AuthorizedUsersObserverAttached:
      {
        return AppState(
            attendeeStore: state.attendeeStore,
            authorizedUserStore: AuthorizedUserListStore(list: state.authorizedUserStore.list, observer: action.attached),
            attendanceRecords: state.attendanceRecords,
            userStore: state.userStore);
      }
  }
  return state;
}