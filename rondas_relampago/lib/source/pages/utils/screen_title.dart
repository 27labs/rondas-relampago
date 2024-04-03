import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Owned
import 'package:rondas_relampago/source/models/ads/ads.dart';
import 'package:rondas_relampago/source/pages/utils/providers.dart';

class ScreenTitleSolo extends ConsumerWidget {
  final String title;
  final bool showingResults;
  const ScreenTitleSolo(
    this.title, {
    this.showingResults = false,
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    ref,
  ) {
    if (context.canPop() && !showingResults) {
      return ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 100,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  10,
                  10,
                  5,
                  10,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_sharp,
                  semanticLabel: AppLocalizations.of(
                    context,
                  )!
                      .returnToMainMenu,
                  size: Theme.of(
                    context,
                  ).textTheme.headlineMedium!.fontSize,
                ),
              ),
            ),
            Expanded(
              child: (Platform.isAndroid || Platform.isIOS) &&
                      ref
                          .watch(
                            preloadedAdsProvider,
                          )
                          .ads
                          .adaptiveBanner
                          .isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      child: SizedBox(
                        height: AdSize.banner.height.toDouble(),
                        width: AdSize.banner.width.toDouble(),
                        child: AdWidget(
                          ad: ref
                              .watch(
                                preloadedAdsProvider,
                              )
                              .ads
                              .adaptiveBanner
                              .last,
                        ),
                      ),
                    )
                  : FittedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(
                          8.0,
                        ),
                        child: Text(
                          title,
                          style: Theme.of(
                            context,
                          ).textTheme.headline5!.copyWith(
                                color: Theme.of(
                                  context,
                                ).primaryColor,
                              ),
                        ),
                      ),
                    ),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(
                      audioControllerProvider,
                    )
                    .toggleMusic(
                      ref,
                    );
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  10,
                  10,
                  20,
                  10,
                ),
                child: Icon(
                  ref.watch(
                    soundVolumeProvider,
                  )
                      ? Icons.music_off_outlined
                      : Icons.music_note_outlined,
                  semanticLabel: AppLocalizations.of(
                    context,
                  )!
                      .musicToggle,
                  size: Theme.of(
                    context,
                  ).textTheme.headlineMedium!.fontSize,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 100,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            width: 15,
            height: 20,
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(
                20,
              ),
              alignment: Alignment.center,
              child: Text(
                AppLocalizations.of(
                  context,
                )!
                    .results,
                style: Theme.of(
                  context,
                ).textTheme.headline4?.copyWith(
                      color: Theme.of(
                        context,
                      ).primaryColor,
                    ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(
                    audioControllerProvider,
                  )
                  .toggleMusic(
                    ref,
                  );
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                10,
                10,
                20,
                10,
              ),
              child: Icon(
                ref.watch(
                  soundVolumeProvider,
                )
                    ? Icons.music_off_outlined
                    : Icons.music_note_outlined,
                semanticLabel: AppLocalizations.of(
                  context,
                )!
                    .musicToggle,
                size: Theme.of(
                  context,
                ).textTheme.headlineMedium!.fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScreenTitle extends ConsumerWidget {
  final String title;
  final bool showingResults;
  const ScreenTitle(
    this.title, {
    this.showingResults = false,
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    ref,
  ) {
    if (context.canPop() && !showingResults) {
      return ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 100,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  10,
                  10,
                  5,
                  10,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_sharp,
                  semanticLabel: AppLocalizations.of(
                    context,
                  )!
                      .returnToMainMenu,
                  size: Theme.of(
                    context,
                  ).textTheme.headlineMedium!.fontSize,
                ),
              ),
            ),
            Expanded(
              child: FittedBox(
                child: Padding(
                  padding: const EdgeInsets.all(
                    8.0,
                  ),
                  child: Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.headline5!.copyWith(
                          color: Theme.of(
                            context,
                          ).primaryColor,
                        ),
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(
                      audioControllerProvider,
                    )
                    .toggleMusic(
                      ref,
                    );
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  10,
                  10,
                  20,
                  10,
                ),
                child: Icon(
                  ref.watch(
                    soundVolumeProvider,
                  )
                      ? Icons.music_off_outlined
                      : Icons.music_note_outlined,
                  semanticLabel: AppLocalizations.of(
                    context,
                  )!
                      .musicToggle,
                  size: Theme.of(
                    context,
                  ).textTheme.headlineMedium!.fontSize,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 140,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            width: 30,
            height: 20,
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(
                20,
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(
                  context,
                )!
                    .results,
                style: Theme.of(
                  context,
                ).textTheme.headline4?.copyWith(
                      color: Theme.of(
                        context,
                      ).primaryColor,
                    ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(
                    audioControllerProvider,
                  )
                  .toggleMusic(
                    ref,
                  );
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                10,
                10,
                20,
                10,
              ),
              child: Icon(
                ref.watch(
                  soundVolumeProvider,
                )
                    ? Icons.music_off_outlined
                    : Icons.music_note_outlined,
                semanticLabel: AppLocalizations.of(
                  context,
                )!
                    .musicToggle,
                size: Theme.of(
                  context,
                ).textTheme.headlineMedium!.fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuScreenTitle extends ConsumerWidget {
  final String title;
  const MenuScreenTitle(
    this.title, {
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    ref,
  ) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Container(
          //   padding: const EdgeInsets.fromLTRB(10, 10, 5, 10),
          // ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(
                30,
                20,
                20,
                20,
              ),
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.headline5?.copyWith(
                        color: Theme.of(
                          context,
                        ).primaryColor,
                      ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(
              10,
              10,
              20,
              10,
            ),
            child: TextButton(
              onPressed: () {
                ref
                    .read(
                      audioControllerProvider,
                    )
                    .toggleMusic(
                      ref,
                    );
              },
              child: Icon(
                ref.watch(
                  soundVolumeProvider,
                )
                    ? Icons.music_off_outlined
                    : Icons.music_note_outlined,
                semanticLabel: AppLocalizations.of(
                  context,
                )!
                    .musicToggle,
                size: Theme.of(
                  context,
                ).textTheme.headlineMedium!.fontSize,
              ),
            ),
          ),
        ],
      );
}
