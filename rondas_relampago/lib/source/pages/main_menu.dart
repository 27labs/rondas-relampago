import 'dart:io';
// import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rondas_relampago/source/models/audio/audio_controller.dart';
import 'package:rondas_relampago/source/models/gameplay/game_units/paints.dart';
// import 'package:provider/provider.dart';
// import 'package:rondas_relampago/source/pages/utils/change_notifiers.dart';
import 'package:url_launcher/url_launcher_string.dart';

// Owned
import 'package:rondas_relampago/source/models/ads/ads.dart';
// import 'package:rondas_relampago/source/storage/storage.dart';
import 'package:rondas_relampago/source/pages/utils/route_names.dart';
import 'package:rondas_relampago/source/models/themes/themes.dart';
import 'package:rondas_relampago/source/pages/utils/content_prompt.dart';
import 'package:rondas_relampago/source/pages/utils/screen_title.dart';
// import 'package:rondas_relampago/source/pages/utils/providers.dart';

class MainMenu extends StatefulWidget {
  final RGBThemes activeTheme;
  final int? Function() getCasualWins;
  final RGBThemes Function(RGBThemes) onThemeSelected;
  final GameAudioSettings Function() onVolumeToggled;
  const MainMenu({
    required this.onThemeSelected,
    required this.onVolumeToggled,
    required this.activeTheme,
    required this.getCasualWins,
    super.key,
  });

  @override
  State<MainMenu> createState() => MainMenuState();
}

class MainMenuState extends State<MainMenu> {
  RGBThemes _activeTheme = RGBThemes.blue;

  void _onThemeSelected(
    RGBThemes theme,
  ) {
    setState(() {
      _activeTheme = widget.onThemeSelected(
        theme,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _activeTheme = widget.activeTheme;
  }

  @override
  Widget build(
    BuildContext context,
  ) =>
      Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(
          context,
        ).colorScheme.onPrimaryContainer,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MenuScreenTitle(
              AppLocalizations.of(
                context,
              )!
                  .gameName,
              onVolumeToggled: widget.onVolumeToggled,
            ),
            Expanded(
              // flex: 100,
              child: SizedBox(
                height: 320,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: _MenuThemePicker(
                        onThemeSelected: _onThemeSelected,
                        activeTheme: _activeTheme,
                      ),
                    ),
                    // _gap,
                    Expanded(
                      child: _MenuItem(
                        AppLocalizations.of(
                          context,
                        )!
                            .singlePlayerMode,
                        route: RouteNames.casualPlay.name,
                        color: _activeTheme.seedColor,
                      ),
                    ),
                    // _gap,
                    Expanded(
                      child: _MenuItem(
                        AppLocalizations.of(
                          context,
                        )!
                            .casualMode,
                        route: RouteNames.casualPairPlay.name,
                        color: _activeTheme.seedColor,
                      ),
                    ),
                    // _gap,
                    Expanded(
                      child: _MenuItem(
                        AppLocalizations.of(
                          context,
                        )!
                            .onlineCasualMode,
                        route: null, // RouteNames.onlinePlay.name,
                        color: Colors.black,
                      ),
                    ),
                    // _gap,
                    const _AdSection(),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            _GameStatistics(
              getCasualWins: widget.getCasualWins,
            ),
            TextButton(
              style: ButtonStyle(
                textStyle: WidgetStateProperty.all<TextStyle>(
                  Theme.of(context)
                      .textTheme
                      .labelSmall!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                overlayColor: WidgetStateProperty.all<Color>(
                  Colors.transparent,
                ),
                fixedSize: WidgetStateProperty.all<Size>(
                  Size(164, 10),
                ),
              ),
              onPressed: () {
                launchUrlString(
                  "https://rondas-relampago.web.app/privacy.html",
                );
              },
              child: Text(
                AppLocalizations.of(
                  context,
                )!
                    .privacyPolicy,
              ),
            ),
            const SizedBox(
              height: 9,
            ),
          ],
        ),
      );
}

class _MenuItem extends StatelessWidget {
  final String? route;
  final String buttonText;
  final Color color;
  const _MenuItem(
    this.buttonText, {
    required this.color,
    required this.route,
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) =>
      TextButton(
        onPressed: () => route != null
            ? context.pushNamed(
                route!,
              )
            : () {},
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.all<Color>(
            Colors.transparent,
          ),
          textStyle: MaterialStateProperty.all<TextStyle?>(
            Theme.of(
              context,
            ).textTheme.titleMedium,
          ),
        ),
        child: Container(
          height: double.infinity,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(
            horizontal: 15,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(
              Radius.circular(
                10,
              ),
            ),
          ),
          child: Center(
            child: Text(
              buttonText,
            ),
          ),
        ),
      );
}

class _MenuThemePicker extends StatelessWidget {
  final void Function(RGBThemes) onThemeSelected;
  final RGBThemes activeTheme;
  const _MenuThemePicker({
    required this.onThemeSelected,
    required this.activeTheme,
    super.key,
  });

  static const _shrink = 0.7;

  @override
  Widget build(
    context,
  ) =>
      FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          height: 65 * _shrink,
          width: 300 * _shrink,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '• ${AppLocalizations.of(
                  context,
                )!.themeWord}: ',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).primaryColor,
                    ),
              ),
              DropdownButton(
                borderRadius: BorderRadius.circular(
                  10.0,
                ),
                alignment: AlignmentDirectional.bottomStart,
                value: activeTheme,
                dropdownColor: activeTheme.seedColor,
                icon: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5.0,
                  ),
                  child: Icon(
                    Icons.brush_outlined,
                    color: Theme.of(
                      context,
                    ).primaryColor,
                    size: 22,
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: RGBThemes.blue,
                    child: Padding(
                      padding: const EdgeInsets.all(
                        5.0,
                      ),
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!
                            .blue,
                        semanticsLabel: AppLocalizations.of(
                          context,
                        )!
                            .blueTheme,
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(
                              color: Theme.of(
                                context,
                              ).primaryColor,
                            ),
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: RGBThemes.green,
                    child: Padding(
                      padding: const EdgeInsets.all(
                        5.0,
                      ),
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!
                            .green,
                        semanticsLabel: AppLocalizations.of(
                          context,
                        )!
                            .greenTheme,
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(
                              color: Theme.of(
                                context,
                              ).primaryColor,
                            ),
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: RGBThemes.red,
                    child: Padding(
                      padding: const EdgeInsets.all(
                        5.0,
                      ),
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!
                            .red,
                        semanticsLabel: AppLocalizations.of(
                          context,
                        )!
                            .redTheme,
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(
                              color: Theme.of(
                                context,
                              ).primaryColor,
                            ),
                      ),
                    ),
                  ),
                ],
                onChanged: (
                  theme,
                ) =>
                    onThemeSelected(
                  theme ?? RGBThemes.blue,
                ),
              ),
              Text(
                ' •',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).primaryColor,
                    ),
              ),
            ],
          ),
        ),
      );
}

class _AdSection extends StatefulWidget {
  const _AdSection({
    super.key,
  });

  @override
  State<_AdSection> createState() => _AdSectionState();
}

class _AdSectionState extends State<_AdSection> {
  BannerAd? _bannerAd;
  // NativeAd? _nativeAd;

  void _loadAd() async {
    await PreloadedAds.preloadSingleAd(
      // AdKind.nativePlatform,
      // () => setState(
      //   () {
      //     _nativeAd = PreloadedAds.ads.nativePlatform.last;
      //   },
      // ),
      AdKind.mediumRectangleBanner,
      () => setState(
        () {
          _bannerAd = PreloadedAds.ads.mediumRectangleBanner.last;
        },
      ),
    );
  }

  static const _margin = SizedBox(
    width: 15.0,
  );

  @override
  void initState() {
    super.initState();
    // TODO: fetchAd()
    if (!kIsWeb) _loadAd();
  }

  @override
  Widget build(
    context,
  ) => // kDebugMode ||
      !kIsWeb
          ? !(Platform.isAndroid || Platform.isIOS)
              ? const SizedBox()
              : Platform.isAndroid
                  ? Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                _margin,
                                Expanded(
                                  child: SizedBox(
                                    width:
                                        AdSize.mediumRectangle.width.toDouble(),
                                    height: 350,
                                    // child: _nativeAd != null
                                    //     ? AdWidget(
                                    //         ad: _nativeAd!,
                                    //       )
                                    //     : null,
                                    child: _bannerAd != null
                                        ? AdWidget(
                                            ad: _bannerAd!,
                                          )
                                        : null,
                                  ),
                                ),
                                _margin,
                                // const SizedBox(
                                //   width: 5,
                                // ),
                                Center(
                                  child: IconButton(
                                    iconSize: 25,
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (
                                          innerContext,
                                        ) =>
                                            const ContentPromptDialog(),
                                      ).then((
                                        value,
                                      ) {
                                        setState(() {
                                          // _nativeAd = null;
                                          _bannerAd = null;
                                        });
                                        _loadAd();
                                      });
                                    },
                                    icon: Icon(
                                      Icons.refresh_rounded,
                                      color: Theme.of(
                                        context,
                                      ).primaryColor,
                                    ),
                                  ),
                                ),
                                _margin,
                              ],
                            ),
                          ),
                          // _gap,
                        ],
                      ),
                    )
                  : const SizedBox()
          : const SizedBox();
}

class _GameStatistics extends StatelessWidget {
  final int? Function() getCasualWins;
  const _GameStatistics({
    required this.getCasualWins,
    super.key,
  });

  @override
  Widget build(
    context,
  ) =>
      SizedBox(
        height: 30,
        // width: _gap.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '• ',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).primaryColor,
                  ),
            ),
            Text(
              AppLocalizations.of(
                context,
              )!
                  .winsCounterText,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).primaryColor,
                  ),
            ),
            Text(
              (getCasualWins() ?? 0).toString(),
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).primaryColor,
                  ),
            ),
            Text(
              ' • ',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).primaryColor,
                  ),
            ),
            // Text(AppLocalizations.of(context)!.winsPercentileText,
            //     style: Theme.of(context)
            //         .textTheme
            //         .headline6
            //         ?.copyWith(color: Theme.of(context).primaryColor)),
            // Text(_winPercentile.toStringAsPrecision(4),
            //     style: Theme.of(context)
            //         .textTheme
            //         .headline6
            //         ?.copyWith(color: Theme.of(context).primaryColor)),
            // Text(' •',
            //     style: Theme.of(context)
            //         .textTheme
            //         .headline6
            //         ?.copyWith(color: Theme.of(context).primaryColor)),
          ],
        ),
      );
}

// const _gap = Flexible(
//   flex: 5,
//   child: SizedBox(
//     height: 25,
//   ),
// );
