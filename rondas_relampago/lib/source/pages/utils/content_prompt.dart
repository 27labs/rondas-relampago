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
        ).errorColor,
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
        content: Text(
          AppLocalizations.of(
            context,
          )!
              .ageConfirmationNotice,
          textAlign: TextAlign.justify,
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
              AdsController.limitAds();
              PreloadedAds.drain();
              PreloadedAds.preloadSingleAd(
                AdKind.nativePlatform,
              );
              context.pop();
              await (await SharedPreferences.getInstance()).setBool(
                StoredValuesKeys.adRating.storageKey,
                false,
              );
            },
            child: Text(
              AppLocalizations.of(
                context,
              )!
                  .confirmYoungerText,
            ),
          ),
          FilledButton(
            onPressed: () async {
              AdsController.unlimitAds();
              PreloadedAds.drain();
              PreloadedAds.preloadSingleAd(
                AdKind.nativePlatform,
              );
              context.pop();
              await (await SharedPreferences.getInstance()).setBool(
                StoredValuesKeys.adRating.storageKey,
                true,
              );
            },
            child: Text(
              AppLocalizations.of(
                context,
              )!
                  .confirmOlderText,
            ),
          ),
        ],
      );
}
