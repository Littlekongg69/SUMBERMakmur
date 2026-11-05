import 'package:sqlquest/shared/models/app_models.dart';

/// Turunan sederhana dari [SqlChallengeModel] agar UI tidak mengulang
/// aturan seperti "challenge mendukung blok jika blockSet tidak kosong".
extension SqlChallengeModelX on SqlChallengeModel {
  static const int _defaultSlotCount = 6;

  bool get supportsBlockMode => blockSet.isNotEmpty;

  bool get hasTimeLimit => timeLimitSeconds != null;

  /// Jumlah slot pada Mode Blok. Jatuh ke 6 bila data tidak menentukan.
  int get blockSlotCount =>
      targetSlotCount > 0 ? targetSlotCount : _defaultSlotCount;
}
