import 'package:docflow/modules/home/views/home_view.dart';
import 'package:get/get.dart';

import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.home, page: () => const HomeView()),
  ];
}
