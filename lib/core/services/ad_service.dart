import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constants/ad_constants.dart';
import 'analytics_service.dart';
import 'pro_service.dart';

class AdService extends GetxService {
  static AdService get to => Get.find<AdService>();

  static const _creditsKey = 'ad_skip_credits';

  final _box = GetStorage();

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  final RxBool isInterstitialReady = false.obs;
  final RxBool isRewardedReady = false.obs;
  final RxInt adSkipCredits = 0.obs;

  String get _bannerUnitId =>
      kDebugMode ? AdConstants.testBannerAdUnitId : AdConstants.bannerAdUnitId;

  String get _interstitialUnitId => kDebugMode
      ? AdConstants.testInterstitialAdUnitId
      : AdConstants.interstitialAdUnitId;

  String get _rewardedUnitId => kDebugMode
      ? AdConstants.testRewardedAdUnitId
      : AdConstants.rewardedAdUnitId;

  @override
  void onInit() {
    super.onInit();
    adSkipCredits.value = _box.read<int>(_creditsKey) ?? 0;
    if (Platform.isAndroid) {
      loadInterstitialAd();
      loadRewardedAd();
    }
  }

  void addAdCredits(int count) {
    adSkipCredits.value += count;
    _box.write(_creditsKey, adSkipCredits.value);
  }

  void _consumeCredit() {
    if (adSkipCredits.value > 0) {
      adSkipCredits.value -= 1;
      _box.write(_creditsKey, adSkipCredits.value);
    }
  }

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: _bannerUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Banner ad failed: $error');
        },
      ),
    );
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          isInterstitialReady.value = true;
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (error) {
          isInterstitialReady.value = false;
          debugPrint('Interstitial ad failed: $error');
        },
      ),
    );
  }

  Future<void> showInterstitialAd({VoidCallback? onDismissed}) async {
    if (!Platform.isAndroid) {
      onDismissed?.call();
      return;
    }

    // Pro users never see ads
    if (ProService.to.isPro.value) {
      onDismissed?.call();
      return;
    }

    // Spend a credit to skip this ad
    if (adSkipCredits.value > 0) {
      _consumeCredit();
      onDismissed?.call();
      return;
    }

    if (_interstitialAd == null || !isInterstitialReady.value) {
      onDismissed?.call();
      loadInterstitialAd();
      return;
    }

    AnalyticsService.to.logAdShown('interstitial');

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        isInterstitialReady.value = false;
        loadInterstitialAd();
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        isInterstitialReady.value = false;
        loadInterstitialAd();
        onDismissed?.call();
      },
    );
    await _interstitialAd!.show();
  }

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          isRewardedReady.value = true;
        },
        onAdFailedToLoad: (error) {
          isRewardedReady.value = false;
          debugPrint('Rewarded ad failed: $error');
        },
      ),
    );
  }

  Future<void> showRewardedAd({
    required VoidCallback onRewarded,
    VoidCallback? onDismissed,
  }) async {
    if (!Platform.isAndroid) {
      onRewarded();
      return;
    }

    if (_rewardedAd == null || !isRewardedReady.value) {
      onRewarded();
      loadRewardedAd();
      return;
    }

    AnalyticsService.to.logAdShown('rewarded');

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        isRewardedReady.value = false;
        loadRewardedAd();
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        isRewardedReady.value = false;
        loadRewardedAd();
        onRewarded();
      },
    );
    await _rewardedAd!.show(
      onUserEarnedReward: (_, reward) => onRewarded(),
    );
  }

  @override
  void onClose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    super.onClose();
  }
}
