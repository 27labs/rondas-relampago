import 'dart:io';

import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

// Owned
import 'package:rondas_relampago/source/models/ads/ads.dart';
import 'package:rondas_relampago/source/models/app_lifecycle/app_lifecycle.dart';
import 'package:rondas_relampago/source/models/themes/themes.dart';
// import 'package:rondas_relampago/source/models/themes/themes.dart';
import 'package:rondas_relampago/source/pages/ads_requirements.dart';
import 'package:rondas_relampago/source/pages/casual_singleplayer/match.dart';
import 'package:rondas_relampago/source/pages/casual_singleplayer/tutorial.dart';
import 'package:rondas_relampago/source/pages/main_menu.dart';
import 'package:rondas_relampago/source/pages/utils/providers.dart';
import 'package:rondas_relampago/source/pages/utils/route_names.dart';

class Relampago extends ConsumerWidget {
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
            !kDebugMode && (Platform.isAndroid || Platform.isIOS)
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
    ref,
  ) {
    if (!kDebugMode && (Platform.isAndroid || Platform.isIOS))
      ref.read(
        preloadedAdsProvider,
      );
    return AppLifecycleObserver(
      audioController: ref.watch(
        audioControllerProvider,
      ),
      child: SafeArea(
        child: MaterialApp.router(
          title: '¡Rondas Relámpago!',
          localizationsDelegates: const [
            AppLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            textTheme: GoogleFonts.lexendTextTheme(),
            colorScheme: ColorScheme.fromSeed(
              // brightness: Brightness.dark,
              seedColor: switch (ref.watch(
                selectedThemeProvider,
              )) {
                AsyncData(
                  :final value,
                ) =>
                  value,
                _ => RGBThemes.blue
              }
                  .seedColor,
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
