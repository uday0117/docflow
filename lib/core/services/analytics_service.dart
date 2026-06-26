import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class AnalyticsService extends GetxService {
  static AnalyticsService get to => Get.find<AnalyticsService>();

  final _analytics = FirebaseAnalytics.instance;

  Future<void> logToolUsed(String toolName) async {
    try {
      await _analytics.logEvent(
        name: 'tool_used',
        parameters: {'tool_name': toolName},
      );
    } catch (e) {
      debugPrint('Analytics logToolUsed error: $e');
    }
  }

  Future<void> logAdShown(String adType) async {
    try {
      await _analytics.logEvent(
        name: 'ad_shown',
        parameters: {'ad_type': adType},
      );
    } catch (e) {
      debugPrint('Analytics logAdShown error: $e');
    }
  }

  Future<void> logRewardedWatched() async {
    try {
      await _analytics.logEvent(name: 'rewarded_ad_watched');
    } catch (e) {
      debugPrint('Analytics logRewardedWatched error: $e');
    }
  }

  Future<void> logProUpgradeViewed() async {
    try {
      await _analytics.logEvent(name: 'pro_upgrade_viewed');
    } catch (e) {
      debugPrint('Analytics logProUpgradeViewed error: $e');
    }
  }

  Future<void> logProPurchased() async {
    try {
      await _analytics.logPurchase(currency: 'USD', value: 1.99);
    } catch (e) {
      debugPrint('Analytics logProPurchased error: $e');
    }
  }
}
