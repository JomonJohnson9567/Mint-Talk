import 'package:mint_talk/core/constants/app_texts.dart';

/// Who the blocked list holds: users block hosts, hosts block users. Drives
/// the screen's title and copy; the data and actions are the same.
enum BlockedListKind {
  hosts,
  users;

  String get title => switch (this) {
    hosts => AppTexts.blockedHostsTitle,
    users => AppTexts.blockedUsersTitle,
  };

  String get emptyTitle => switch (this) {
    hosts => AppTexts.noBlockedHosts,
    users => AppTexts.noBlockedUsers,
  };

  String get emptyMessage => switch (this) {
    hosts => AppTexts.noBlockedHostsDesc,
    users => AppTexts.noBlockedUsersDesc,
  };

  /// Shown when the API returns no name.
  String get fallbackName => switch (this) {
    hosts => 'Host',
    users => 'User',
  };

  String unblockTitle(String name) => 'Unblock $name?';

  String unblockMessage(String name) =>
      '$name will be able to call and message you again.';
}
