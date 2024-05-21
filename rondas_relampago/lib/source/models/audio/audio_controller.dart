// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

// Owned
// import 'package:rondas_relampago/source/pages/utils/providers.dart';
import 'package:rondas_relampago/source/storage/storage.dart';

/// Allows playing music and sound. A facade to `package:audioplayers`.
class AudioController {
  final AudioPlayer _musicPlayer;

  /// This is a list of [AudioPlayer] instances which are rotated to play
  /// sound effects.
  ///
  /// Normally, we would just call [AudioCache.play] and let it procure its
  /// own [AudioPlayer] every time. But this seems to lead to errors and
  /// bad performance on iOS devices.

  // final void Function() toggleMusic;

  /// Creates an instance that plays music and sound.
  ///
  /// Use [polyphony] to configure the number of sound effects (SFX) that can
  /// play at the same time. A [polyphony] of `1` will always only play one
  /// sound (a new sound will stop the previous one). See discussion
  /// of [_sfxPlayers] to learn why this is the case.
  ///
  /// Background music does not count into the [polyphony] limit. Music will
  /// never be overridden by sound effects.
  AudioController({int polyphony = 2})
      : assert(polyphony >= 1),
        _musicPlayer = AudioPlayer(playerId: 'musicPlayer')
          ..setReleaseMode(ReleaseMode.loop);

  /// Enables the [AudioController] to listen to [AppLifecycleState] events,
  /// and therefore do things like stopping playback when the game
  /// goes into the background.

  /// Enables the [AudioController] to track changes to settings.
  /// Namely, when any of [SettingsController.muted],
  /// [SettingsController.musicOn] or [SettingsController.soundsOn] changes,
  /// the audio controller will act accordingly.

  void dispose() {
    _musicPlayer.dispose();
  }

  GameAudioSettings sound = GameAudioSettings.soundOff;

  /// Preloads all sound effects.
  Future<bool> initialize(GameAudioSettings setting,
      [bool forced = false]) async {
    // _log.info('Preloading sound effects');
    // This assumes there is only a limited number of sound effects in the game.
    // If there are hundreds of long sound effect files, it's better
    // to be more selective when preloading.
    sound = setting;

    if (!kIsWeb || forced) {
      await _musicPlayer.play(AssetSource('songs/GYMKANA A.wav'));
      if (sound.muted) await _musicPlayer.pause();
      return true;
    }

    return false;
  }

  /// Plays a single sound effect, defined by [type].
  ///
  /// The controller will ignore this call when the attached settings'
  /// [SettingsController.muted] is `true` or if its
  /// [SettingsController.soundsOn] is `false`.

  AppLifecycleListener get lifecycleListener =>
      AppLifecycleListener(onStateChange: handleAppLifecycle);

  void handleAppLifecycle(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (!sound.muted) {
          _musicPlayer.resume();
        }
        break;
      default:
        _musicPlayer.pause();
    }
  }

  void _mutedHandler({required GameAudioSettings setting}) {
    if (setting.muted) {
      // All sound just got muted.
      _stopAllSound();
    } else {
      _resumeMusic();
    }
  }

  void _resumeMusic() async {
    sound = GameAudioSettings.soundOn;
    await _musicPlayer.resume();
  }

  void _stopAllSound() async {
    sound = GameAudioSettings.soundOff;
    await _musicPlayer.pause();
  }

  void toggleMusic(SharedPreferences? storage) {
    // final storage = await SharedPreferences.getInstance();

    final soundState = switch (storage?.getBool(
      StoredValuesKeys.soundVolume.storageKey,
    )) {
      false => GameAudioSettings.soundOff,
      true => GameAudioSettings.soundOn,
      null => sound,
    };

    final newSoundState = soundState.muted
        ? GameAudioSettings.soundOn
        : GameAudioSettings.soundOff;
    _mutedHandler(setting: newSoundState);

    storage?.setBool(
        StoredValuesKeys.soundVolume.storageKey, !newSoundState.muted);
  }
}

enum GameAudioSettings {
  soundOn(false),
  soundOff(true);

  final bool muted;

  const GameAudioSettings(this.muted);
}
