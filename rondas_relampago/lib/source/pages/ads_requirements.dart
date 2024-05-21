import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rondas_relampago/source/pages/utils/content_prompt.dart';

class AdsRequirementsScreen extends StatelessWidget {
  const AdsRequirementsScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    Future.delayed(
      const Duration(
        milliseconds: 500,
      ),
      () => showDialog(
        context: context,
        builder: (
          _,
        ) =>
            const ContentPromptDialog(),
      ).then(
        (
          value,
        ) =>
            context.pushReplacementNamed(
          'main_menu',
        ),
      ),
    );
    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).colorScheme.onSecondaryContainer,
    );
  }
}
