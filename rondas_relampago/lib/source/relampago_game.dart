import 'dart:io';

// import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';
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
import 'package:rondas_relampago/source/pages/casual/match.dart';
import 'package:rondas_relampago/source/pages/casual/tutorial.dart';
import 'package:rondas_relampago/source/pages/main_menu.dart';
import 'package:rondas_relampago/source/pages/room_selection.dart';
// import 'package:rondas_relampago/source/pages/utils/change_notifiers.dart';
// import 'package:rondas_relampago/source/pages/utils/providers.dart';
import 'package:rondas_relampago/source/pages/utils/route_names.dart';
import 'package:rondas_relampago/source/storage/storage.dart';

class Relampago extends StatefulWidget {
  final SharedPreferences storage;
  const Relampago({
    required this.storage,
    super.key,
  });

  @override
  State<Relampago> createState() => RelampagoState();
}

class RelampagoState extends State<Relampago> {
  late final AudioController _audioController = AudioController();
  // SharedPreferences? _storage;
  RGBThemes _activeTheme = RGBThemes.blue;
  bool _userInteracted = false;

  GameAudioSettings _toggleMusic() {
    _audioController.toggleMusic(
      widget.storage,
    );
    return _audioController.sound;
  }

  RGBThemes _changeTheme(
    RGBThemes theme,
  ) {
    setState(() {
      _activeTheme = theme;
    });
    widget.storage.setInt(
      StoredValuesKeys.selectedTheme.storageKey,
      theme.index,
    );
    return _activeTheme;
  }

  void _updateCasualScoreBy(
    int wins,
  ) =>
      widget.storage.setInt(
          StoredValuesKeys.casualWins.storageKey,
          (widget.storage.getInt(
                    StoredValuesKeys.casualWins.storageKey,
                  ) ??
                  0) +
              1);

  int? _getCasualWins() => widget.storage.getInt(
        StoredValuesKeys.casualWins.storageKey,
      );

  void _initFromPersistentStorage() async {
    _audioController.initialize(switch (widget.storage.getBool(
      StoredValuesKeys.soundVolume.storageKey,
    )) {
      false => GameAudioSettings.soundOff,
      _ => GameAudioSettings.soundOn,
    });
    setState(() {
      _activeTheme = RGBThemes.values[widget.storage.getInt(
            StoredValuesKeys.selectedTheme.storageKey,
          ) ??
          RGBThemes.blue.index];
    });
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
              !kDebugMode && !kIsWeb
                  ? (Platform.isAndroid || Platform.isIOS)
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
            singleplayer: (updateCasualScoreBy: _updateCasualScoreBy,),
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
        GoRoute(
          name: RouteNames.onlinePlay.name,
          path: '/online',
          redirect: (
            _,
            __,
          ) =>
              '/online/tutorial',
        ),
        GoRoute(
          name: RouteNames.onlineRoomSelection.name,
          path: '/online/room_selection',
          builder: (
            _,
            __,
          ) =>
              OnlineRoomSelectionScreen(),
        ),
        GoRoute(
          name: RouteNames.onlineCasualTutorial.name,
          path: '/online/tutorial',
          builder: (
            _,
            __,
          ) =>
              TutorialForCasual(
            onVolumeToggled: _toggleMusic,
            activeTheme: _activeTheme,
          ),
        ),
        // GoRoute(
        //   name: RouteNames.onlineTwoPlayers.name,
        //   path: '/online/twoplayer?room_id',
        //   builder: (
        //     _,
        //     state,
        //   ) =>
        //       CasualOnlineMatch(
        //     onVolumeToggled: _toggleMusic,
        //     submittedRoomId: switch (state.uri.query) {
        //       '' => null,
        //       String query => query
        //     }, // '5708e3a0-1465-1f8a-8ee6-692641652579',
        //   ),
        // ),
        GoRoute(
          name: RouteNames.onlineTwoPlayersJoin.name,
          path: '/online/twoplayer/:roomId',
          builder: (
            _,
            state,
          ) =>
              CasualOnlineMatch(
            onVolumeToggled: _toggleMusic,
            submittedRoomId: switch (state.pathParameters['roomId']) {
              null => null,
              _ => state.pathParameters['roomId'],
            }, // '5708e3a0-1465-1f8a-8ee6-692641652579',
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
    if (!kIsWeb) if (
        // !kDebugMode &&
        (Platform.isAndroid || Platform.isIOS)) {
      // PreloadedAds.initProviders(ref);
    }
    return AppLifecycleObserver(
      audioController: _audioController,
      child: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: '¡Rondas Relámpago!',
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: ThemeData(
                textTheme: GoogleFonts.lexendTextTheme(),
                snackBarTheme: SnackBarThemeData(
                  // actionTextColor: Colors.amber,
                  contentTextStyle:
                      GoogleFonts.lexendTextTheme().labelSmall!.copyWith(
                            color: Colors.amber,
                          ),
                  backgroundColor: _activeTheme.seedColor,
                ),
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
            !_userInteracted
                ? GestureDetector(
                    onPanStart: (details) => setState(() async {
                      _userInteracted = await _audioController.initialize(
                          _audioController.sound, true);
                    }),
                    onTapDown: (details) => setState(() async {
                      _userInteracted = await _audioController.initialize(
                          _audioController.sound, true);
                    }),
                    child: const SizedBox(
                      height: 1000,
                      width: 1000,
                    ),
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}
