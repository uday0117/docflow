import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_service.dart';
import '../services/pro_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _loadBanner();
    }
  }

  void _loadBanner() {
    final ad = AdService.to.createBannerAd();
    ad.load().then((_) {
      if (mounted) {
        setState(() {
          _bannerAd = ad;
          _isLoaded = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!Platform.isAndroid) return const SizedBox.shrink();
      if (ProService.to.isPro.value) return const SizedBox.shrink();
      if (!_isLoaded || _bannerAd == null) return const SizedBox.shrink();

      return Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    });
  }
}
