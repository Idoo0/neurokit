// study_session_result_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/routes_name.dart';
import '../services/local_storage_service.dart';
import '../models/mode.dart';
import '../utils.dart';

class StudySessionResultPage extends StatelessWidget {
  const StudySessionResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = Get.find<LocalStorageService>();

    return FutureBuilder(
      future: Future.wait([
        store.getWarmupSummary(),      // {'score': int, 'total': int, 'done': bool}
        store.getStudySummary(),       // {'startedAt': DateTime?, 'durationSec': int, 'done': bool}
        store.getSelectedModeString(), // String? (SessionMode.name)
        store.getStats(),              // {'weeklyFocusSec': int, 'weekStartYmd': int, 'streakCount': int, 'lastYmd': int}
      ]),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(child: Center(child: CircularProgressIndicator())),
          );
        }

        final warmup = snap.data![0] as Map<String, Object>;
        final study  = snap.data![1] as Map<String, Object?>;
        final modeStr = snap.data![2] as String?;
        final stats  = snap.data![3] as Map<String, int>;

        SessionMode? mode;
        if (modeStr != null) {
          try { mode = SessionMode.values.firstWhere((e) => e.name == modeStr); } catch (_) {}
        }

        final score = (warmup['score'] as int?) ?? 0;
        final total = (warmup['total'] as int?) ?? 0;
        final durationSec = (study['durationSec'] as int?) ?? 0;
        final weeklySec = stats['weeklyFocusSec'] ?? 0;
        final streakCount = stats['streakCount'] ?? 0;

        String durationText;
        final mins = durationSec ~/ 60;
        final secs = durationSec % 60;
        if (mins > 0) {
          durationText = '${mins}m ${secs}s';
        } else {
          durationText = '${secs}s';
        }

        String weeklyText;
        final weeklyMins = weeklySec ~/ 60;
        final weeklySecs = weeklySec % 60;
        if (weeklyMins > 0) {
          weeklyText = '${weeklyMins}m ${weeklySecs}s';
        } else {
          weeklyText = '${weeklySecs}s';
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Text(
                    "Sesi Fokus Selesai!",
                    style: mobileH2.copyWith(color: neutral800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Image.asset(
                    "assets/images/star-spark-confetti.png",
                    height: 400,
                  ),
                  const SizedBox(height: 40),

                  // 🔹 Dynamic summary
                  Column(
                    children: [
                      if (mode != null)
                        Text(
                          "Mode: ${mode == SessionMode.chill ? 'CHILL' : 'LEARN'}",
                          style: bodyText16.copyWith(color: neutral700),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 8),
                      Text(
                        "Warmup: $score / $total poin",
                        style: bodyText18.copyWith(color: neutral700),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Durasi belajar: $durationText",
                        style: bodyText18.copyWith(color: neutral700),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Total fokus minggu ini: $weeklyText",
                        style: bodyText18.copyWith(color: neutral700),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "🔥 Streak: $streakCount hari",
                        style: bodyText18.copyWith(color: neutral700),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Get.offAllNamed(RoutesName.homepage),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brand600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                      ),
                      child: Text("Home", style: buttonText),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}