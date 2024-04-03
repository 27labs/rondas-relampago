import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rondas_relampago/source/models/ads/ads.dart';

// Owned
import 'source/relampago_game.dart';
// import 'package:rondas_relampago/source/storage/storage.dart';
// part 'main.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kDebugMode && (Platform.isAndroid || Platform.isIOS)) {
    MobileAds.instance.initialize();
    // await SharedPreferences.getInstance().then(
    //   (storage) async {
    //     switch (storage.getBool('adRating')) {
    //       case true:
    //         AdsController.unlimitAds();
    //         // PreloadedAds.preloadSingleAd(AdKind.nativePlatform);
    //         break;
    //       case false:
    //       case null:
    //         AdsController.limitAds();
    //         // PreloadedAds.preloadSingleAd(AdKind.nativePlatform);
    //         break;
    //     }
    //   },
    // );
  }
  // await SharedPreferences.getInstance()
  //     .then((value) async => await value.remove(key));
  runApp(
    ProviderScope(
      child: Relampago(),
    ),
  );
}
