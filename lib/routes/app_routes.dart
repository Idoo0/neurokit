import 'package:get/get.dart';

import '../view/homepage.dart';
import '../view/stats_page.dart';
import '../view/study_session_page.dart';
import '../view/warmup_page.dart';                 // ensure this matches the actual filename
import '../view/motivation_page.dart';
import '../view/study_session_result_page.dart';
import '../view/badges_page.dart';
// import '../view/settings_page.dart';
import 'routes_name.dart';
import '../view/onboarding_flow.dart';

class AppRoutes {
  static const initRoute = RoutesName.motivation;

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
      name: RoutesName.motivation,
      page: () {
        // Safe fallback so LLM args are optional
        final args = Get.arguments as Map<String, dynamic>?;

        final isStarting = args?['isStarting'] as bool? ?? true;
        final messages = (args?['messages'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
            const [
              'Believe in yourself!',
            ];

        return MotivationPage(
          isStarting: isStarting,
          messages: messages,
        );
      },
      transition: Transition.fade,
    ),
    GetPage(
      name: RoutesName.studyResult,
      page: () => const StudySessionResultPage(),
      transition: Transition.fade,
    ),
    GetPage(
      name: RoutesName.badges,
      page: () => BadgesPage(
        onBackPressed: () => Get.back(),
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