import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Owned
import 'package:rondas_relampago/source/models/ads/ads.dart';
import 'package:rondas_relampago/source/pages/utils/providers.dart';

class ContentPromptDialog extends ConsumerWidget {
  const ContentPromptDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) => AlertDialog(
        backgroundColor: Theme.of(context).errorColor,
        titleTextStyle: Theme.of(context)
            .textTheme
            .titleLarge!
            .copyWith(color: Theme.of(context).primaryColor),
        contentTextStyle: Theme.of(context)
            .textTheme
            .bodyLarge!
            .copyWith(color: Theme.of(context).primaryColor),
        title: Text(AppLocalizations.of(context)!.ageConfirmationTitleText),
        content: Text(
          AppLocalizations.of(context)!.ageConfirmationNotice,
          textAlign: TextAlign.justify,
        ),
        icon: const Icon(Icons.check),
        iconColor: Theme.of(context).primaryColor,
        actions: [
          FilledButton(
              onPressed: () {
                AdsController.limitAds();
                switch (ref.watch(sharedPreferencesProvider)) {
                  case AsyncData(:final value):
                    value.setBool('adRating', false);
                    break;
                  case _:
                }
                context.pop();
              },
              child: Text(AppLocalizations.of(context)!.confirmYoungerText)),
          FilledButton(
              onPressed: () {
                AdsController.unlimitAds();
                switch (ref.watch(sharedPreferencesProvider)) {
                  case AsyncData(:final value):
                    value.setBool('adRating', true);
                    break;
                  case _:
                }
                context.pop();
              },
              child: Text(AppLocalizations.of(context)!.confirmOlderText)),
        ],
      );
}
