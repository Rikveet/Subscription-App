import 'package:radha_swami_management_system/redux/app_state.dart';

class UserStore{
  bool isAdmin = false;
  bool isEditor = false;
  UserStore({this.isAdmin = false, this.isEditor = false});
}


class SetUserEditorAction {
  bool isEditor;
  SetUserEditorAction(this.isEditor);
}

class SetUserAdminAction {
  bool isAdmin;
  SetUserAdminAction(this.isAdmin);
}


AppState userReducer(AppState state, dynamic action){
  switch(action){
    case SetUserEditorAction:
      {
        return AppState(
            attendeeStore: state.attendeeStore,
            authorizedUserStore: state.authorizedUserStore,
            attendanceRecords: state.attendanceRecords,
            userStore: UserStore(isEditor: action.isEditor, isAdmin: state.userStore.isAdmin));
      }
    case SetUserAdminAction:
      {
        return AppState(
            attendeeStore: state.attendeeStore,
            authorizedUserStore: state.authorizedUserStore,
            attendanceRecords: state.attendanceRecords,
            userStore: UserStore(isEditor: state.userStore.isEditor, isAdmin: action.isAdmin));
      }
  }
  return state;
}