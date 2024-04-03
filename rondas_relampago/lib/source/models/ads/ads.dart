import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
export 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ads_secrets.dart';

enum AdKind { nativePlatform, mediumRectangleBanner, adaptiveBanner }

typedef AdStore = ({
  List<NativeAd> nativePlatform,
  List<BannerAd> mediumRectangleBanner,
  List<BannerAd> adaptiveBanner
});

class AdsController {
  static bool? _adCategorySelected;

  static bool? get adCategorySelected => _adCategorySelected;

  static Future<void> limitAds() async {
    if (!kDebugMode && (Platform.isAndroid || Platform.isIOS))
      await MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(maxAdContentRating: MaxAdContentRating.g));
    _adCategorySelected = false;
  }

  static Future<void> unlimitAds() async {
    if (!kDebugMode && (Platform.isAndroid || Platform.isIOS))
      await MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(maxAdContentRating: MaxAdContentRating.t));
    _adCategorySelected = true;
  }
}

class PreloadedAds {
  AdStore _ads =
      (nativePlatform: [], mediumRectangleBanner: [], adaptiveBanner: []);

  ({
    int nativePlatform,
    int mediumRectangleBanner,
    int adaptiveBanner
  }) _maxAmountOfAds =
      (nativePlatform: 1, mediumRectangleBanner: 0, adaptiveBanner: 1);

  Duration _initializationTimeout = const Duration(seconds: 3);

  Duration get initializationTimeout => _initializationTimeout;

  set initializationTimeout(Duration timeout) =>
      _initializationTimeout = timeout;

  ({int nativePlatform, int mediumRectangleBanner, int adaptiveBanner})
      get preloadedAmountLimits => _maxAmountOfAds;

  set preloadedAmountLimits(
      ({
        int? nativePlatform,
        int? mediumRectangleBanner,
        int? adaptiveBanner
      }) newLimits) {
    _maxAmountOfAds = (
      nativePlatform:
          newLimits.nativePlatform ?? _maxAmountOfAds.nativePlatform,
      mediumRectangleBanner: newLimits.mediumRectangleBanner ??
          _maxAmountOfAds.mediumRectangleBanner,
      adaptiveBanner: newLimits.adaptiveBanner ?? _maxAmountOfAds.adaptiveBanner
    );

    _ads = (
      nativePlatform: _ads.nativePlatform
          .sublist(_ads.nativePlatform.length - _maxAmountOfAds.nativePlatform),
      mediumRectangleBanner: _ads.mediumRectangleBanner.sublist(
          _ads.mediumRectangleBanner.length -
              _maxAmountOfAds.mediumRectangleBanner),
      adaptiveBanner: _ads.adaptiveBanner
          .sublist(_ads.adaptiveBanner.length - _maxAmountOfAds.adaptiveBanner),
    );
  }

  AdStore get ads => _ads;

  String add(Ad ad, [AdKind? adKind]) {
    final adType = switch (ad) {
      NativeAd _ => AdKind.nativePlatform,
      BannerAd _ => switch (ad.size) {
          AdSize.mediumRectangle => AdKind.mediumRectangleBanner,
          AdSize.fluid || AdSize.banner => AdKind.adaptiveBanner,
          _ => null
        },
      _ => null
    };

    switch (adKind == null
        ? adType
        : adType == adKind
            ? adKind
            : null) {
      case AdKind.nativePlatform:
        if (_ads.nativePlatform.length < _maxAmountOfAds.nativePlatform) {
          _ads.nativePlatform.add(ad as NativeAd);
          return "Native Ad loaded.";
        }
      case AdKind.mediumRectangleBanner:
        if (_ads.mediumRectangleBanner.length <
            _maxAmountOfAds.mediumRectangleBanner) {
          _ads.mediumRectangleBanner.add((ad as BannerAd));
          return "Medium Banner Ad loaded.";
        }
      case AdKind.adaptiveBanner:
        if (_ads.adaptiveBanner.length < _maxAmountOfAds.adaptiveBanner) {
          _ads.adaptiveBanner.add(ad as BannerAd);
          return "Adaptive Banner Ad loaded.";
        }
      default:
    }
    return "Invalid ad wasn't added.";
  }

  void removeAt(int index, AdKind adKind) {
    switch (adKind) {
      case AdKind.nativePlatform:
        if (index >= 0 && index < _ads.nativePlatform.length)
          _ads.nativePlatform.removeAt(index);
      case AdKind.mediumRectangleBanner:
        if (index >= 0 && index < _ads.mediumRectangleBanner.length)
          _ads.mediumRectangleBanner.removeAt(index);
      case AdKind.adaptiveBanner:
        if (index >= 0 && index < _ads.mediumRectangleBanner.length)
          _ads.mediumRectangleBanner.removeAt(index);
    }
  }

  Future<void> preloadSingleAd(AdKind adKind) async {
    bool loaded = false;

    const adRequest = AdRequest();

    switch (adKind) {
      case AdKind.nativePlatform:
        NativeAd(
            nativeTemplateStyle:
                NativeTemplateStyle(templateType: TemplateType.medium),
            adUnitId: kDebugMode
                ? DevelopmentAdsUnitId.nativePlatform.unitId
                : ReleaseAdsUnitId.nativePlatform.unitId,
            request: adRequest,
            listener: NativeAdListener(onAdLoaded: (ad) {
              debugPrint(add(ad as NativeAd, AdKind.nativePlatform));
              loaded = true;
            })).load();
        break;
      case AdKind.adaptiveBanner:
        BannerAd(
            adUnitId: kDebugMode
                ? DevelopmentAdsUnitId.adaptiveBanner.unitId
                : ReleaseAdsUnitId.adaptiveBanner.unitId,
            request: adRequest,
            size: AdSize.banner,
            listener: BannerAdListener(onAdLoaded: (ad) {
              debugPrint(add(ad as BannerAd, AdKind.adaptiveBanner));
              loaded = true;
            })).load();
        break;
      case AdKind.mediumRectangleBanner:
        BannerAd(
            adUnitId: kDebugMode
                ? DevelopmentAdsUnitId.mediumRectangleBanner.unitId
                : ReleaseAdsUnitId.mediumRectangleBanner.unitId,
            request: adRequest,
            size: AdSize.mediumRectangle,
            listener: BannerAdListener(onAdLoaded: (ad) {
              debugPrint(add(ad as BannerAd, AdKind.mediumRectangleBanner));
              loaded = true;
            })).load();
        break;
    }

    while (!loaded) {}
  }
}
