import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/features/shared/block_users/data/blocked_hosts_store.dart';

void main() {
  late BlockedHostsStore store;
  late List<Set<String>> emissions;

  setUp(() {
    store = BlockedHostsStore();
    emissions = [];
    store.changes.listen(emissions.add);
  });

  test('add / remove update the set and notify', () async {
    store.add('a');
    expect(store.isBlocked('a'), isTrue);
    store.remove('a');
    expect(store.isBlocked('a'), isFalse);
    await pumpEventQueue();
    expect(emissions, [
      {'a'},
      <String>{},
    ]);
  });

  test('does not notify when nothing changed', () async {
    store.replaceAll(['a', 'b']);
    store.replaceAll(['b', 'a']);
    store.add('a');
    store.add('');
    store.remove('missing');
    await pumpEventQueue();
    expect(emissions, hasLength(1));
  });

  test('replaceAll drops empty IDs and clear empties the set', () {
    store.replaceAll(['a', '']);
    expect(store.ids, {'a'});
    store.clear();
    expect(store.ids, isEmpty);
  });
}
