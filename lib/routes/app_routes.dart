import 'package:get/get.dart';
import 'package:my_app/view/homepage.dart';
// import '../view/homepage_page.dart';
import '../view/stats_page.dart';
import '../view/study_session_page.dart';
// import '../view/warm_up_page.dart';
import '../view/badges_page.dart';
// import '../view/settings_page.dart';
import 'routes_name.dart';
import '../view/onboarding_flow.dart';

class AppRoutes {
  static const initRoute = RoutesName.onboardingFlow;
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
    // GetPage(
    //   name: RoutesName.warmUp,
    //   page: () => const WarmUpPage(),
    //   transition: Transition.fade,
    // ),
    GetPage(
      name: RoutesName.badges,
      page: () => BadgesPage(
        onBackPressed: () {
          Get.back();
        },
      ),
      transition: Transition.fade,
    ),
    // GetPage(
    //   name: RoutesName.settings,
    //   page: () => const SettingsPage(),
    //   transition: Transition.fade,
    // ),
    GetPage(
      name: RoutesName.onboardingFlow,
      page: () => const OnboardingFlowScreen(),
      transition: Transition.fade,
    ),
  ];
}
