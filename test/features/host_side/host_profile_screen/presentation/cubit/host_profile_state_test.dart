import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/cubit/host_profile_state.dart';

void main() {
  test('exposes display-ready cached host values', () {
    const state = HostProfileState(
      status: HostProfileStatus.loaded,
      fullName: 'Jomon Johnson',
      phone: '+918921355574',
      userId: 'host-id',
      dob: '09/07/1999',
      gender: 'male',
      role: 'staff',
    );

    expect(state.displayName, 'Jomon Johnson');
    expect(state.initials, 'JJ');
    expect(state.displayPhone, '+918921355574');
    expect(state.displayUserId, 'host-id');
    expect(state.displayDob, '09/07/1999');
    expect(state.displayGender, 'Male');
    expect(state.displayRole, 'Verified host');
  });

  test('uses safe fallbacks when optional profile values are absent', () {
    const state = HostProfileState(status: HostProfileStatus.loaded);

    expect(state.displayName, 'Host');
    expect(state.initials, 'H');
    expect(state.displayPhone, 'Phone unavailable');
    expect(state.displayUserId, 'ID unavailable');
  });
}
