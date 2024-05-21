import 'dart:io';
// import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rondas_relampago/source/models/gameplay/game_units/paints.dart';

// Owned
import 'source/relampago_game.dart';
import 'package:rondas_relampago/source/models/ads/ads.dart';
import 'package:rondas_relampago/source/storage/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await SharedPreferences.getInstance()
  //   ..clear();
  if (!kIsWeb) if (
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
            StoredValuesKeys.adRating.storageKey,
          )) {
            case true:
              await AdsController.unlimitAds(storage);
              // PreloadedAds.preloadSingleAd(AdKind.nativePlatform);
              break;
            case false:
              await AdsController.limitAds(storage);
              // PreloadedAds.preloadSingleAd(AdKind.nativePlatform);
              break;
            case null:
              break;
          }
        },
      ),
    );
  }
  // await SharedPreferences.getInstance()
  //     .then((value) async => await value.remove(key));
  runApp(
    WidgetsApp(
      debugShowCheckedModeBanner: false,
      color: Colors.amber,
      builder: (
        _,
        __,
      ) =>
          FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (
          _,
          snapshot,
        ) =>
            switch (snapshot.data) {
          SharedPreferences data => Relampago(
              storage: data,
            ),
          null => Scaffold(
              backgroundColor: ColorScheme.fromSeed(
                seedColor: Colors.blue,
              ).onPrimaryContainer,
              body: const Center(
                child: CircularProgressIndicator(
                  color: Colors.amber,
                ),
              ),
            ),
        },
      ),
    ),
  );
}
