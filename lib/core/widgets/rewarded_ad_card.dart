import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/ad_service.dart';
import '../services/analytics_service.dart';
import '../services/pro_service.dart';

class RewardedAdCard extends StatelessWidget {
  const RewardedAdCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ProService.to.isPro.value) return const SizedBox.shrink();

      final adService = AdService.to;
      final credits = adService.adSkipCredits.value;

      if (credits > 0) {
        return _CreditsInfoCard(credits: credits);
      }

      return _WatchAdCard(adService: adService);
    });
  }
}

class _WatchAdCard extends StatelessWidget {
  final AdService adService;
  const _WatchAdCard({required this.adService});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : const Color(0xFFFFFDE7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.play_circle_rounded,
              color: Colors.amber,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Skip next 3 ads',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                Text(
                  'Watch a short video',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              adService.showRewardedAd(
                onRewarded: () {
                  adService.addAdCredits(3);
                  AnalyticsService.to.logRewardedWatched();
                  Get.snackbar(
                    'Reward Earned!',
                    'Next 3 ads will be skipped automatically',
                    duration: const Duration(seconds: 3),
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black87,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Watch',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreditsInfoCard extends StatelessWidget {
  final int credits;
  const _CreditsInfoCard({required this.credits});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2A1A) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_rounded, color: Colors.green, size: 20),
          const SizedBox(width: 10),
          Text(
            'Ad-free for next $credits operation${credits > 1 ? 's' : ''}',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
