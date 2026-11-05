import 'package:flutter_test/flutter_test.dart';
import 'package:sqlquest/features/sql_game/domain/entities/block_slots.dart';

import 'helpers/sql_game_fixtures.dart';

void main() {
  group('BlockSlots', () {
    test('empty membuat slot kosong sebanyak length', () {
      final slots = BlockSlots.empty(3);
      expect(slots.length, 3);
      expect(slots.hasAny, isFalse);
      expect(slots.isFull, isFalse);
      expect(slots.assembledQuery, '');
    });

    test('fillNext mengisi slot kosong pertama', () {
      final slots = BlockSlots.empty(3)
          .fillNext(keywordSelect)
          .fillNext(columnStar);
      expect(slots.items[0], keywordSelect);
      expect(slots.items[1], columnStar);
      expect(slots.items[2], isNull);
    });

    test('fillNext mengisi lubang bekas clearAt lebih dulu', () {
      final slots = BlockSlots.empty(3)
          .fillNext(keywordSelect)
          .fillNext(columnStar)
          .clearAt(0)
          .fillNext(tableRecipes);
      expect(slots.items[0], tableRecipes);
      expect(slots.items[1], columnStar);
    });

    test('fillNext saat penuh mengembalikan instance yang sama', () {
      final full = BlockSlots.empty(1).fillNext(keywordSelect);
      expect(full.fillNext(columnStar), same(full));
    });

    test('isFull true hanya saat semua slot terisi', () {
      var slots = BlockSlots.empty(2).fillNext(keywordSelect);
      expect(slots.isFull, isFalse);
      slots = slots.fillNext(columnStar);
      expect(slots.isFull, isTrue);
    });

    test('operasi tidak mengubah instance asal (immutable)', () {
      final original = BlockSlots.empty(2);
      original.fillNext(keywordSelect);
      expect(original.hasAny, isFalse);
    });

    test('items tidak bisa dimodifikasi dari luar', () {
      final slots = BlockSlots.empty(2);
      expect(() => slots.items[0] = keywordSelect, throwsUnsupportedError);
    });

    test('clearAt dengan indeks di luar rentang diabaikan', () {
      final slots = BlockSlots.empty(2).fillNext(keywordSelect);
      expect(slots.clearAt(-1), same(slots));
      expect(slots.clearAt(5), same(slots));
    });

    test('clear mengosongkan semua slot dengan panjang tetap', () {
      final cleared = BlockSlots.empty(2)
          .fillNext(keywordSelect)
          .fillNext(columnStar)
          .clear();
      expect(cleared.length, 2);
      expect(cleared.hasAny, isFalse);
    });

    test('assembledQuery menggabungkan teks dan merapikan " ;"', () {
      final slots = BlockSlots.empty(5)
          .fillNext(keywordSelect)
          .fillNext(columnStar)
          .fillNext(tableRecipes)
          .fillNext(closingSemicolon);
      expect(slots.assembledQuery, 'SELECT * recipes;');
    });
  });
}
