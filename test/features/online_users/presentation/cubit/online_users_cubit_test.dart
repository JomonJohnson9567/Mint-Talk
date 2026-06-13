import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/features/user_side/online_users/presentation/cubit/online_users_cubit.dart';
import 'package:mint_talk/features/user_side/online_users/presentation/cubit/online_users_state.dart';

void main() {
  group('OnlineUsersCubit', () {
    late OnlineUsersCubit cubit;

    setUp(() {
      cubit = OnlineUsersCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state should be active tab with filtered active users', () {
      expect(cubit.state.selectedTab, VideoCallFilterTab.active);
      // Ensure all users in active state are either online or onCall
      for (final user in cubit.state.users) {
        final statusName = user.status.name;
        expect(statusName == 'online' || statusName == 'onCall', isTrue);
      }
    });

    test('selectTab should emit state with new selectedTab and filtered users', () {
      cubit.selectTab(VideoCallFilterTab.favorites);
      expect(cubit.state.selectedTab, VideoCallFilterTab.favorites);
      for (final user in cubit.state.users) {
        expect(user.isFavorite, isTrue);
      }

      cubit.selectTab(VideoCallFilterTab.offline);
      expect(cubit.state.selectedTab, VideoCallFilterTab.offline);
      for (final user in cubit.state.users) {
        expect(user.status.name, equals('offline'));
      }
    });
  });
}
