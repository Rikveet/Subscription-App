class AuthorizedUser {
  String name;
  String email;
  List<String> permissions;

  AuthorizedUser({required this.name, required this.email, this.permissions = const []});
}
