import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:in_app_review/in_app_review.dart';

class ReviewService extends GetxService {
  static ReviewService get to => Get.find<ReviewService>();

  static const _usageKey = 'tool_usage_count';
  static const _reviewDoneKey = 'review_requested';
  static const _reviewThreshold = 3;

  final _box = GetStorage();

  Future<void> onToolCompleted() async {
    if (_box.read<bool>(_reviewDoneKey) ?? false) return;

    final count = (_box.read<int>(_usageKey) ?? 0) + 1;
    _box.write(_usageKey, count);

    if (count >= _reviewThreshold) {
      _box.write(_reviewDoneKey, true);
      try {
        final review = InAppReview.instance;
        if (await review.isAvailable()) {
          await review.requestReview();
        }
      } catch (_) {}
    }
  }
}
