import 'dart:io';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Owned
import 'source/relampago_game.dart';
import 'package:rondas_relampago/source/models/ads/ads.dart';
import 'package:rondas_relampago/source/storage/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await SharedPreferences.getInstance()
  //   ..clear();
  if (
      // !kDebugMode &&
      (Platform.isAndroid || Platform.isIOS)) {
    MobileAds.instance.initialize();
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        maxAdContentRating: MaxAdContentRating.g,
      ),
    );
    await (
      SharedPreferences.getInstance().then(
        (storage) async {
          switch (storage.getBool(
            'adRating',
          )) {
            case true:
              await AdsController.unlimitAds();
              // PreloadedAds.preloadSingleAd(AdKind.nativePlatform);
              break;
            case false:
              await AdsController.limitAds();
              // PreloadedAds.preloadSingleAd(AdKind.nativePlatform);
              break;
            case null:
          }
        },
      ),
    );
  }
  // await SharedPreferences.getInstance()
  //     .then((value) async => await value.remove(key));
  runApp(
    ProviderScope(
      child: Relampago(),
    ),
  );
}
