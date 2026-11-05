/// Tingkat kesulitan challenge sekaligus opsi filter pada daftar challenge.
///
/// [all] bukan tingkat kesulitan sungguhan; ia dipakai sebagai "tanpa filter".
enum ChallengeDifficulty {
  all(key: 'All', displayLabel: 'Semua Level'),
  easy(key: 'Easy', displayLabel: 'Easy'),
  medium(key: 'Medium', displayLabel: 'Medium'),
  hard(key: 'Hard', displayLabel: 'Hard'),
  expert(key: 'Expert', displayLabel: 'Expert');

  const ChallengeDifficulty({required this.key, required this.displayLabel});

  /// Nilai yang tersimpan pada `SqlChallengeModel.difficulty`.
  final String key;

  /// Teks yang ditampilkan ke pengguna.
  final String displayLabel;

  /// Apakah challenge dengan [difficulty] lolos filter ini.
  bool matches(String difficulty) =>
      this == all || key.toLowerCase() == difficulty.toLowerCase();

  /// Memetakan string dari model ke enum. Nilai tak dikenal menjadi [all].
  static ChallengeDifficulty fromKey(String key) {
    final normalized = key.toLowerCase();
    for (final value in values) {
      if (value.key.toLowerCase() == normalized) return value;
    }
    return all;
  }
}
