import 'package:get/get.dart';
import '../pages/homepage_page.dart';
import '../pages/stats_page.dart';
import '../pages/study_session_page.dart';
import '../pages/warm_up_page.dart';
import '../pages/badges_page.dart';
import '../pages/settings_page.dart';
import 'routes_name.dart';

class AppRoutes {
  static const initRoute = RoutesName.homepage;
  static final routes = [
    GetPage(
      name: RoutesName.homepage,
      page: () => const HomepagePage(),
      transition: Transition.fade,
    ),
    GetPage(
      name: RoutesName.stats,
      page: () => const StatsPage(),
      transition: Transition.fade,
    ),
    GetPage(
      name: RoutesName.studySession,
      page: () => const StudySessionPage(),
      transition: Transition.fade,
    ),
    GetPage(
      name: RoutesName.warmUp,
      page: () => const WarmUpPage(),
      transition: Transition.fade,
    ),
    GetPage(
      name: RoutesName.badges,
      page: () => BadgesPage(
        onBackPressed: () {
          Get.back();
        },
      ),
      transition: Transition.fade,
    ),
    GetPage(
      name: RoutesName.settings,
      page: () => const SettingsPage(),
      transition: Transition.fade,
    ),
  ];
}
