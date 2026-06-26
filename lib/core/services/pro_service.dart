import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class ProService extends GetxService {
  static ProService get to => Get.find<ProService>();

  static const String productId = 'docflow_pro';
  static const String _proKey = 'is_pro_unlocked';

  final _box = GetStorage();
  final RxBool isPro = false.obs;
  final RxBool isLoading = false.obs;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  @override
  void onInit() {
    super.onInit();
    isPro.value = _box.read<bool>(_proKey) ?? false;
    _purchaseSub = InAppPurchase.instance.purchaseStream.listen(
      _handlePurchaseUpdate,
      onError: (e) => debugPrint('IAP stream error: $e'),
    );
  }

  void _handlePurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final p in purchases) {
      if (p.productID != productId) continue;
      switch (p.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _unlockPro();
          InAppPurchase.instance.completePurchase(p);
          break;
        case PurchaseStatus.error:
          isLoading.value = false;
          Get.snackbar('Purchase Failed', p.error?.message ?? 'Unknown error');
          break;
        case PurchaseStatus.pending:
          isLoading.value = true;
          break;
        case PurchaseStatus.canceled:
          isLoading.value = false;
          break;
      }
    }
  }

  void _unlockPro() {
    isPro.value = true;
    isLoading.value = false;
    _box.write(_proKey, true);
    Get.snackbar(
      'Welcome to Pro!',
      'Ads removed. Thank you for your support!',
      duration: const Duration(seconds: 4),
    );
  }

  Future<void> purchasePro() async {
    isLoading.value = true;
    try {
      final available = await InAppPurchase.instance.isAvailable();
      if (!available) {
        isLoading.value = false;
        Get.snackbar('Not Available', 'Store is not available right now.');
        return;
      }

      final res =
          await InAppPurchase.instance.queryProductDetails({productId});
      if (res.productDetails.isEmpty) {
        isLoading.value = false;
        Get.snackbar('Error', 'Product not found. Please try again later.');
        return;
      }

      await InAppPurchase.instance.buyNonConsumable(
        purchaseParam:
            PurchaseParam(productDetails: res.productDetails.first),
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> restorePurchases() async {
    isLoading.value = true;
    try {
      await InAppPurchase.instance.restorePurchases();
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Restore Failed', e.toString());
    }
  }

  @override
  void onClose() {
    _purchaseSub?.cancel();
    super.onClose();
  }
}
