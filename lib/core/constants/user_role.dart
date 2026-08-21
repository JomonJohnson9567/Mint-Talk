/// The two roles a user can hold. The backend's raw role string for a host
/// is `'staff'` — this type lets call sites compare a typed enum instead of
/// repeating that string (and its meaning) at every call site.
enum UserRole { user, host }

extension UserRoleParsing on String? {
  UserRole toUserRole() => this == 'staff' ? UserRole.host : UserRole.user;
}
