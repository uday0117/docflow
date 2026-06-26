import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'core/services/ad_service.dart';
import 'core/services/analytics_service.dart';
import 'core/services/pro_service.dart';
import 'core/services/recent_files_service.dart';
import 'core/services/review_service.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'modules/splash/splash_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init();
  await MobileAds.instance.initialize();

  Get.put(AnalyticsService(), permanent: true);
  Get.put(ReviewService(), permanent: true);
  Get.put(ProService(), permanent: true);
  Get.put(AdService(), permanent: true);
  Get.put(RecentFilesService(), permanent: true);

  runApp(const DocFlowApp());
}

class DocFlowApp extends StatelessWidget {
  const DocFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DocFlow',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const SplashView(),
    );
  }
}
