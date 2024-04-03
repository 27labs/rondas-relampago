// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
export 'package:flutter_riverpod/flutter_riverpod.dart';

// Owned
import 'package:rondas_relampago/source/models/ads/ads.dart';
import 'package:rondas_relampago/source/models/audio/audio_controller.dart';
import 'package:rondas_relampago/source/models/themes/themes.dart';
import 'package:rondas_relampago/source/storage/storage.dart';
part 'providers.g.dart';

@riverpod
Future<SharedPreferences> sharedPreferences(
  SharedPreferencesRef ref,
) async =>
    await SharedPreferences.getInstance();

@riverpod
PreloadedAds preloadedAds(
  PreloadedAdsRef ref,
) =>
    PreloadedAds()
      ..preloadSingleAd(
        AdKind.nativePlatform,
      );

@riverpod
AudioController audioController(
  AudioControllerRef ref,
) =>
    AudioController()
      ..initialize(
        switch (ref.watch(
          savedVolumeProvider,
        )) {
          AsyncData(
            :final value,
          ) =>
            value ? GameAudioSettings.soundOn : GameAudioSettings.soundOff,
          _ => GameAudioSettings.soundOn
        },
      );

@riverpod
bool soundVolume(
  SoundVolumeRef ref,
) =>
    ref
        .watch(
          audioControllerProvider,
        )
        .sound
        .muted;

@riverpod
Future<bool> savedVolume(
  SavedVolumeRef ref,
) async =>
    await SharedPreferences.getInstance().then(
      (
        value,
      ) =>
          value.getBool(
            StoredValuesKeys.soundVolume.storageKey,
          ) ??
          true,
    );

@riverpod
Future<RGBThemes> selectedTheme(
  SelectedThemeRef ref,
) async =>
    await SharedPreferences.getInstance().then(
      (
        value,
      ) =>
          RGBThemes.values[value.getInt(
                StoredValuesKeys.selectedTheme.storageKey,
              ) ??
              0],
    );
