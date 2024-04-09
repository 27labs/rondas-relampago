export 'package:shared_preferences/shared_preferences.dart';
export 'dart:convert';

enum StoredValuesKeys {
  selectedTheme('selected_theme'),
  soundVolume('sound_volume'),
  adRating('ad_rating'),
  casualWins('casual_wins');

  final String storageKey;
  const StoredValuesKeys(
    this.storageKey,
  );
}
