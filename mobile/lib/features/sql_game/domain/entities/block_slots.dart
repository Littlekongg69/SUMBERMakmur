import 'package:sqlquest/shared/models/app_models.dart';

/// Kumpulan slot pada Mode Blok ("Susun Query").
///
/// Immutable: setiap operasi mengembalikan instance baru sehingga mudah
/// dipakai sebagai bagian dari state dan mudah diuji.
class BlockSlots {
  BlockSlots.empty(int length)
    : this._(List<SqlBlockItem?>.filled(length, null));

  BlockSlots._(List<SqlBlockItem?> items) : items = List.unmodifiable(items);

  final List<SqlBlockItem?> items;

  int get length => items.length;

  /// True bila seluruh slot terisi (syarat mengaktifkan tombol jalankan).
  bool get isFull => items.isNotEmpty && items.every((slot) => slot != null);

  bool get hasAny => items.any((slot) => slot != null);

  /// Query hasil rakitan blok. Spasi sebelum ";" dirapikan.
  String get assembledQuery => items
      .whereType<SqlBlockItem>()
      .map((block) => block.text)
      .join(' ')
      .replaceAll(' ;', ';');

  /// Mengisi slot kosong pertama. Bila semua penuh, mengembalikan `this`.
  BlockSlots fillNext(SqlBlockItem block) {
    final index = items.indexWhere((slot) => slot == null);
    if (index == -1) return this;
    return _replaceAt(index, block);
  }

  BlockSlots clearAt(int index) {
    if (index < 0 || index >= length) return this;
    return _replaceAt(index, null);
  }

  BlockSlots clear() => BlockSlots.empty(length);

  BlockSlots _replaceAt(int index, SqlBlockItem? value) {
    final next = List<SqlBlockItem?>.of(items);
    next[index] = value;
    return BlockSlots._(next);
  }
}
