import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/routes_name.dart';
import '../utils.dart';

class StudySessionResultPage extends StatelessWidget {
  const StudySessionResultPage({super.key});

  @override
  Widget build(BuildContext context) {
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
              Text(
                "Kerja bagus!\nkamu mendapatkan 10 poin",
                style: bodyText18.copyWith(color: neutral700),
                textAlign: TextAlign.center,
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
  }
}