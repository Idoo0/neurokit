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

    return FutureBuilder<List<Object?>>(
      future: Future.wait([
        store.getWarmupSummary(),       // 0: {'score','total','done'}
        store.getStudySummary(),        // 1: {'startedAt','durationSec','done'}
        store.getSelectedModeString(),  // 2: String? (SessionMode.name)
        store.getStats(),               // 3: {'weeklyFocusSec','weekStartYmd','streakCount','lastYmd'}
        store.getLifetimeWarmup(),      // 4: {'score','total'}
      ]),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(child: Center(child: CircularProgressIndicator())),
          );
        }
        if (!snap.hasData || snap.data == null) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(child: Center(child: Text('No data'))),
          );
        }

        final data = snap.data!;
        final warmup   = data[0] as Map<String, Object>;
        final study    = data[1] as Map<String, Object?>;
        final modeStr  = data[2] as String?;
        final stats    = data[3] as Map<String, int>;
        final lifetime = data[4] as Map<String, int>;
        final lifeScore = lifetime['score'] ?? 0;
        final lifeTotal = lifetime['total'] ?? 0;

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
                children: [
                  const Spacer(),
                  Text(
                    "Sesi Fokus Selesai!",
                    style: mobileH2.copyWith(color: neutral800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    "assets/images/star-spark-confetti.png",
                    height: 250, // Adjusted height to prevent overflow
                  ),
                  const SizedBox(height: 20),
                  GridView(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent: 95,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _StatBox(
                        title: 'Warmup Poin',
                        value: '$score poin',
                        subtitle: 'Total: $lifeScore poin',
                        accentColor: const Color(0xFFFCD34D),
                      ),
                      _StatBox(
                        title: 'Durasi Belajar',
                        value: durationText,
                        subtitle: 'Minggu ini: $weeklyText',
                        accentColor: const Color(0xFF86EFAC),
                      ),
                      _StatBox(
                        title: '🔥 Streak',
                        value: '$streakCount hari',
                        accentColor: const Color(0xFFFDBA74),
                      ),
                      if (mode != null)
                        _StatBox(
                          title: 'Mode',
                          value: mode == SessionMode.chill ? 'CHILL' : 'LEARN',
                          accentColor: const Color(0xFFB9C2FD),
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

/// A helper widget to display a single statistic in a styled box,
/// now with an optional subtitle.
class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.title,
    required this.value,
    this.subtitle,
    this.accentColor,
  });

  final String title;
  final String value;
  final String? subtitle;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final Color color = accentColor ?? brand600;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: bodyText12.copyWith(color: neutral700, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: bodyText16.copyWith(color: neutral900, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: bodyText12.copyWith(color: neutral600),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}