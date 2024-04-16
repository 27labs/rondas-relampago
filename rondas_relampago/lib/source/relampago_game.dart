import 'dart:io';

// import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';

// Owned
import 'package:rondas_relampago/source/models/ads/ads.dart';
import 'package:rondas_relampago/source/models/app_lifecycle/app_lifecycle.dart';
import 'package:rondas_relampago/source/models/audio/audio_controller.dart';
import 'package:rondas_relampago/source/models/themes/themes.dart';
import 'package:rondas_relampago/source/pages/ads_requirements.dart';
import 'package:rondas_relampago/source/pages/casual_singleplayer/match.dart';
import 'package:rondas_relampago/source/pages/casual_singleplayer/tutorial.dart';
import 'package:rondas_relampago/source/pages/main_menu.dart';
// import 'package:rondas_relampago/source/pages/utils/change_notifiers.dart';
// import 'package:rondas_relampago/source/pages/utils/providers.dart';
import 'package:rondas_relampago/source/pages/utils/route_names.dart';
import 'package:rondas_relampago/source/storage/storage.dart';

class Relampago extends StatefulWidget {
  const Relampago({
    super.key,
  });

  @override
  State<Relampago> createState() => RelampagoState();
}

class RelampagoState extends State<Relampago> {
  late final AudioController _audioController = AudioController();
  SharedPreferences? _storage;
  RGBThemes _activeTheme = RGBThemes.blue;

  GameAudioSettings _toggleMusic() {
    _audioController.toggleMusic(
      _storage,
    );
    return _audioController.sound;
  }

  RGBThemes _changeTheme(
    RGBThemes theme,
  ) {
    setState(() {
      _activeTheme = theme;
    });
    return _activeTheme;
  }

  void _updateCasualScoreBy(
    int wins,
  ) =>
      _storage!.setInt(
          StoredValuesKeys.casualWins.storageKey,
          (_storage?.getInt(
                    StoredValuesKeys.casualWins.storageKey,
                  ) ??
                  0) +
              1);

  int? _getCasualWins() => _storage?.getInt(
        StoredValuesKeys.casualWins.storageKey,
      );

  void _initFromPersistentStorage() async {
    _storage = await SharedPreferences.getInstance();
    _audioController.initialize(switch (_storage!.getBool(
      StoredValuesKeys.soundVolume.storageKey,
    )) {
      false => GameAudioSettings.soundOff,
      _ => GameAudioSettings.soundOn
    });
    _activeTheme = RGBThemes.values[_storage!.getInt(
          StoredValuesKeys.selectedTheme.storageKey,
        ) ??
        RGBThemes.blue.index];
  }

  @override
  void initState() {
    super.initState();
    _initFromPersistentStorage();
    _router = GoRouter(
      routes: [
        GoRoute(
          name: RouteNames.mainMenu.name,
          path: '/',
          builder: (
            _,
            __,
          ) =>
              // !kDebugMode &&
              (Platform.isAndroid || Platform.isIOS)
                  ? AdsController.adCategorySelected == null
                      ? const AdsRequirementsScreen()
                      : MainMenu(
                          onThemeSelected: _changeTheme,
                          onVolumeToggled: _toggleMusic,
                          activeTheme: _activeTheme,
                          getCasualWins: _getCasualWins,
                        )
                  : MainMenu(
                      onThemeSelected: _changeTheme,
                      onVolumeToggled: _toggleMusic,
                      activeTheme: _activeTheme,
                      getCasualWins: _getCasualWins,
                    ),
        ),
        GoRoute(
          name: RouteNames.casualPlay.name,
          path: '/casual',
          redirect: (
            _,
            __,
          ) =>
              '/casual/tutorial',
        ),
        GoRoute(
          name: RouteNames.casualPairPlay.name,
          path: '/casual_pair',
          redirect: (
            _,
            __,
          ) =>
              '/casual/tutorial?multiplayer',
        ),
        GoRoute(
          name: RouteNames.casualTutorial.name,
          path: '/casual/tutorial',
          builder: (
            _,
            state,
          ) =>
              TutorialForCasual(
            onVolumeToggled: _toggleMusic,
            activeTheme: _activeTheme,
            multiplayer: state.uri.query.isNotEmpty,
          ),
        ),
        GoRoute(
          name: RouteNames.singlePlayer.name,
          path: '/casual/singleplayer',
          builder: (
            _,
            __,
          ) =>
              CasualMatch(
            onVolumeToggled: _toggleMusic,
            singleplayer: (updateCasualScoreBy: _updateCasualScoreBy),
          ),
        ),
        GoRoute(
          name: RouteNames.twoPlayers.name,
          path: '/casual/twoplayer',
          builder: (
            _,
            __,
          ) =>
              CasualMatch(
            onVolumeToggled: _toggleMusic,
          ),
        ),
      ],
    );
  }

  late final GoRouter _router;

  @override
  Widget build(
    _,
  ) {
    if (
        // !kDebugMode &&
        (Platform.isAndroid || Platform.isIOS)) {
      // PreloadedAds.initProviders(ref);
    }
    return AppLifecycleObserver(
      audioController: _audioController,
      child: SafeArea(
        child: MaterialApp.router(
          title: '¡Rondas Relámpago!',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            textTheme: GoogleFonts.lexendTextTheme(),
            colorScheme: ColorScheme.fromSeed(
              // brightness: Brightness.dark,
              seedColor: _activeTheme.seedColor,
            ).copyWith(
              primary: Colors.amber,
            ),
            useMaterial3: true,
          ),
          routerConfig: _router,
        ),
      ),
    );
  }
}
