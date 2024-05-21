import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:provider/provider.dart';

// Owned
import 'package:rondas_relampago/source/models/ads/ads.dart';
// import 'package:rondas_relampago/source/pages/utils/providers.dart';
import 'package:rondas_relampago/source/storage/storage.dart';

class ContentPromptDialog extends StatelessWidget {
  const ContentPromptDialog({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) =>
      AlertDialog(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.onPrimaryContainer,
        titleTextStyle: Theme.of(
          context,
        ).textTheme.titleLarge!.copyWith(
              color: Theme.of(
                context,
              ).primaryColor,
            ),
        contentTextStyle: Theme.of(
          context,
        ).textTheme.bodyLarge!.copyWith(
              color: Theme.of(
                context,
              ).primaryColor,
            ),
        title: Text(
          AppLocalizations.of(
            context,
          )!
              .ageConfirmationTitleText,
        ),
        content: Padding(
          padding: const EdgeInsets.all(14.0),
          child: SingleChildScrollView(
            child: Text(
              AppLocalizations.of(
                context,
              )!
                  .ageConfirmationNotice,
              textAlign: TextAlign.justify,
            ),
          ),
        ),
        icon: const Icon(
          Icons.check,
        ),
        iconColor: Theme.of(
          context,
        ).primaryColor,
        actions: [
          FilledButton(
            onPressed: () async {
              final storage = await SharedPreferences.getInstance();
              AdsController.limitAds(storage);
              PreloadedAds.drain();
              // PreloadedAds.preloadSingleAd(
              //   AdKind.nativePlatform,
              // );
              context.pop();
            },
            child: Text(
              AppLocalizations.of(
                context,
              )!
                  .confirmYoungerText,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          FilledButton(
            onPressed: () async {
              final storage = await SharedPreferences.getInstance();
              AdsController.unlimitAds(storage);
              PreloadedAds.drain();
              // PreloadedAds.preloadSingleAd(
              //   AdKind.nativePlatform,
              // );
              context.pop();
            },
            child: Text(
              AppLocalizations.of(
                context,
              )!
                  .confirmOlderText,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      );
}
