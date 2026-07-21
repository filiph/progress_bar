import 'package:test/test.dart';
import 'package:backend/state_store.dart';

void main() {
  group('StateStore Tests', () {
    late StateStore store;

    setUp(() {
      store = StateStore.inMemory();
    });

    tearDown(() {
      store.close();
    });

    test('get non-existent key returns null', () {
      expect(store.getLastPercentage('non_existent'), isNull);
    });

    test('get and set percentage', () {
      store.setLastPercentage('test_key', 42);
      expect(store.getLastPercentage('test_key'), equals(42));
    });

    test('update existing percentage (ON CONFLICT)', () {
      store.setLastPercentage('test_key', 42);
      store.setLastPercentage('test_key', 43);
      expect(store.getLastPercentage('test_key'), equals(43));
    });

    test('multiple distinct keys', () {
      store.setLastPercentage('key1', 10);
      store.setLastPercentage('key2', 20);
      expect(store.getLastPercentage('key1'), equals(10));
      expect(store.getLastPercentage('key2'), equals(20));
    });
  });
}
