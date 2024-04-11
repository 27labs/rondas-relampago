import 'dart:io';

// import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Owned
import 'package:rondas_relampago/source/models/ads/ads.dart';
import 'package:rondas_relampago/source/models/app_lifecycle/app_lifecycle.dart';
import 'package:rondas_relampago/source/models/audio/audio_controller.dart';
import 'package:rondas_relampago/source/models/themes/themes.dart';
import 'package:rondas_relampago/source/pages/ads_requirements.dart';
import 'package:rondas_relampago/source/pages/casual_singleplayer/match.dart';
import 'package:rondas_relampago/source/pages/casual_singleplayer/tutorial.dart';
import 'package:rondas_relampago/source/pages/main_menu.dart';
import 'package:rondas_relampago/source/pages/utils/change_notifiers.dart';
// import 'package:rondas_relampago/source/pages/utils/providers.dart';
import 'package:rondas_relampago/source/pages/utils/route_names.dart';
import 'package:rondas_relampago/source/storage/storage.dart';

class Relampago extends StatelessWidget {
  Relampago({
    super.key,
  });

  final _router = GoRouter(
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
                    : const MainMenu()
                : const MainMenu(),
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
        name: RouteNames.casualTutorial.name,
        path: '/casual/tutorial',
        builder: (
          _,
          __,
        ) =>
            const TutorialForCasual(),
      ),
      GoRoute(
        name: RouteNames.singlePlayer.name,
        path: '/casual/singleplayer',
        builder: (
          _,
          __,
        ) =>
            const CasualMatch(),
      ),
      GoRoute(
        name: RouteNames.twoPlayers.name,
        path: '/casual/twoplayer',
        builder: (
          _,
          __,
        ) =>
            const CasualMatch(
          multiplayer: true,
        ),
      ),
      // GoRoute(
      //   name: RouteNames.casualPlay.name,
      //   path: '/casual',
      //   redirect: (
      //     context,
      //     __,
      //   ) {
      //     // context.pushReplacementNamed(RouteNames.casualTutorial.name);
      //     Future.delayed(
      //       const Duration(
      //         milliseconds: 10,
      //       ),
      //       () => context.pushReplacementNamed(
      //         RouteNames.casualTutorial.name,
      //       ),
      //     );
      //     return const Scaffold();
      //   },
      //   routes: [
      //     GoRoute(
      //       name: RouteNames.casualTutorial.name,
      //       path: 'tutorial',
      //       builder: (
      //         _,
      //         __,
      //       ) =>
      //           const TutorialForCasual(),
      //     ),
      //     GoRoute(
      //       name: RouteNames.singlePlayer.name,
      //       path: 'singleplayer',
      //       builder: (
      //         _,
      //         __,
      //       ) =>
      //           const CasualMatch(),
      //     ),
      //   ],
      // ),
    ],
  );

  @override
  Widget build(
    _,
  ) {
    if (
        // !kDebugMode &&
        (Platform.isAndroid || Platform.isIOS)) {
      // PreloadedAds.initProviders(ref);
    }
    return FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (
          _,
          snapshot,
        ) {
          return ValueListenableBuilder(
            valueListenable: ValueNotifier(
              RelampagoState(
                (
                  nativeAds: <NativeAd>[],
                  adaptiveAds: <BannerAd>[],
                  audioController: AudioController()
                    ..initialize(
                      switch (snapshot.data?.getBool(
                        StoredValuesKeys.soundVolume.storageKey,
                      )) {
                        false => GameAudioSettings.soundOff,
                        true => GameAudioSettings.soundOn,
                        null => GameAudioSettings.soundOn,
                      },
                    ),
                  sharedPreferences: snapshot.data
                ),
              ),
            ),
            builder: (
              _,
              listenable,
              ___,
            ) =>
                MultiProvider(
              providers: [
                Provider.value(
                  value: listenable.state!.nativeAds,
                ),
                Provider.value(
                  value: listenable.state!.adaptiveAds,
                ),
                Provider.value(
                  value: listenable.state!.audioController,
                ),
                Provider.value(
                  value: listenable.state!.sharedPreferences,
                ),
                Provider.value(
                  value: () {
                    listenable.invalidate();
                    return StateUpdaterNotification.done;
                  },
                  // updateShouldNotify: (previous, current) => false,
                ),
                Provider.value(
                  value: RGBThemes.values[
                      listenable.state!.sharedPreferences?.getInt(
                            StoredValuesKeys.selectedTheme.storageKey,
                          ) ??
                          RGBThemes.blue.index],
                ),
              ],
              builder: (
                context,
                __,
              ) =>
                  AppLifecycleObserver(
                audioController: listenable.state!.audioController,
                child: SafeArea(
                  child: MaterialApp.router(
                    title: '¡Rondas Relámpago!',
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                    theme: ThemeData(
                      textTheme: GoogleFonts.lexendTextTheme(),
                      colorScheme: ColorScheme.fromSeed(
                        // brightness: Brightness.dark,
                        seedColor: Provider.of<RGBThemes>(context).seedColor,
                      ).copyWith(
                        primary: Colors.amber,
                      ),
                      useMaterial3: true,
                    ),
                    routerConfig: _router,
                  ),
                ),
              ),
            ),
          );
        });
  }
}
