import 'dart:io';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:rondas_relampago/source/pages/utils/change_notifiers.dart';
import 'package:url_launcher/url_launcher_string.dart';

// Owned
import 'package:rondas_relampago/source/models/ads/ads.dart';
import 'package:rondas_relampago/source/storage/storage.dart';
import 'package:rondas_relampago/source/pages/utils/route_names.dart';
import 'package:rondas_relampago/source/models/themes/themes.dart';
import 'package:rondas_relampago/source/pages/utils/content_prompt.dart';
import 'package:rondas_relampago/source/pages/utils/screen_title.dart';
// import 'package:rondas_relampago/source/pages/utils/providers.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({
    super.key,
  });

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MenuScreenTitle(
              AppLocalizations.of(
                context,
              )!
                  .gameName,
            ),
            const _MenuThemePicker(),
            _gap,
            _MenuItem(
              AppLocalizations.of(
                context,
              )!
                  .singlePlayerMode,
              route: RouteNames.casualPlay.name,
            ),
            _gap,
            _MenuItem(
              AppLocalizations.of(
                context,
              )!
                  .casualMode,
              route: 'casual_mode',
            ),
            _gap,
            _MenuItem(
              AppLocalizations.of(
                context,
              )!
                  .competitiveMode,
              route: 'competitive_mode',
            ),
            _gap,
            const _AdSection(),
            const _GameStatistics(),
            TextButton(
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
            _gap,
          ],
        ),
      );
}

class _MenuItem extends StatelessWidget {
  final String route;
  final String buttonText;
  const _MenuItem(
    this.buttonText, {
    required this.route,
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) =>
      Expanded(
        child: TextButton(
          onPressed: () => context.pushNamed(
            route,
          ),
          style: TextButton.styleFrom(
            textStyle: Theme.of(
              context,
            ).textTheme.headlineSmall,
            // primary: Theme.of(context).primaryColor,
            // onSurface: const Color.fromARGB(0, 0, 0, 0),
          ),
          child: Container(
            height: double.infinity,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            decoration: BoxDecoration(
              color: RGBThemes
                  .values[Provider.of<SharedPreferences?>(
                        context,
                      )?.getInt(
                        StoredValuesKeys.selectedTheme.storageKey,
                      ) ??
                      RGBThemes.blue.index]
                  .seedColor,
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
        ),
      );
}

class _MenuThemePicker extends StatelessWidget {
  const _MenuThemePicker({
    super.key,
  });

  @override
  Widget build(
    context,
  ) =>
      FittedBox(
        fit: BoxFit.contain,
        child: Row(
          children: [
            Text(
              '• ${AppLocalizations.of(
                context,
              )!.themeWord}: ',
              style: Theme.of(
                context,
              ).textTheme.headline6?.copyWith(
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
              value: RGBThemes.values[Provider.of<SharedPreferences?>(
                    context,
                  )?.getInt(
                    StoredValuesKeys.selectedTheme.storageKey,
                  ) ??
                  RGBThemes.blue.index],
              dropdownColor: RGBThemes
                  .values[Provider.of<SharedPreferences?>(
                        context,
                      )?.getInt(
                        StoredValuesKeys.selectedTheme.storageKey,
                      ) ??
                      RGBThemes.blue.index]
                  .seedColor,
              icon: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5.0,
                ),
                child: Icon(
                  Icons.brush_outlined,
                  color: Theme.of(
                    context,
                  ).primaryColor,
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: RGBThemes.blue,
                  child: Padding(
                    padding: const EdgeInsets.all(
                      10.0,
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
                      ).textTheme.headline6?.copyWith(
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
                      10.0,
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
                      ).textTheme.headline6?.copyWith(
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
                      10.0,
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
                      ).textTheme.headline6?.copyWith(
                            color: Theme.of(
                              context,
                            ).primaryColor,
                          ),
                    ),
                  ),
                ),
              ],
              onChanged: (
                RGBThemes? theme,
              ) {
                Provider.of<SharedPreferences?>(
                  context,
                  listen: false,
                )?.setInt(StoredValuesKeys.selectedTheme.storageKey,
                    theme?.index ?? RGBThemes.blue.index);
                Provider.of<StateUpdater>(
                  context,
                  listen: false,
                )();
              },
            ),
            Text(
              ' •',
              style: Theme.of(
                context,
              ).textTheme.headline6?.copyWith(
                    color: Theme.of(
                      context,
                    ).primaryColor,
                  ),
            ),
          ],
        ),
      );
}

class _AdSection extends StatelessWidget {
  const _AdSection({
    super.key,
  });

  @override
  Widget build(
    context,
  ) =>
      Expanded(
        child:
            // kDebugMode ||
            !(Platform.isAndroid || Platform.isIOS)
                ? const SizedBox()
                : Platform.isAndroid
                    ? Column(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                SizedBox(
                                    width:
                                        AdSize.mediumRectangle.width.toDouble(),
                                    height: 350,
                                    child: Provider.of<List<NativeAd>>(context)
                                            .isNotEmpty
                                        ? AdWidget(
                                            ad: Provider.of<List<NativeAd>>(
                                                    context)
                                                .last,
                                          )
                                        : null),
                                const SizedBox(
                                  width: 20,
                                ),
                                Center(
                                  child: IconButton(
                                    iconSize: 25,
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (innerContext) =>
                                            const ContentPromptDialog(),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.refresh_rounded,
                                      color: Theme.of(
                                        context,
                                      ).primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _gap,
                        ],
                      )
                    : const SizedBox(),
      );
}

class _GameStatistics extends StatelessWidget {
  const _GameStatistics({
    super.key,
  });

  @override
  Widget build(
    context,
  ) =>
      SizedBox(
        height: _gap.height! * 3,
        width: _gap.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '• ',
              style: Theme.of(
                context,
              ).textTheme.headline6?.copyWith(
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
              ).textTheme.headline6?.copyWith(
                    color: Theme.of(
                      context,
                    ).primaryColor,
                  ),
            ),
            Text(
              (
                Provider.of<SharedPreferences?>(
                      context,
                    )?.getInt(
                      StoredValuesKeys.casualWins.storageKey,
                    ) ??
                    0,
              ).toString(),
              style: Theme.of(
                context,
              ).textTheme.headline6?.copyWith(
                    color: Theme.of(
                      context,
                    ).primaryColor,
                  ),
            ),
            Text(
              ' • ',
              style: Theme.of(
                context,
              ).textTheme.headline6?.copyWith(
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

const _gap = SizedBox(
  height: 20,
);
