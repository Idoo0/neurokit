import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/routes_name.dart';

class StudySessionResultPage extends StatelessWidget {
  const StudySessionResultPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Sesi Fokus Selesai!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Image.asset("assets/images/star-sleep.png", width: 160),
              const SizedBox(height: 20),
              const Text(
                "Kerja bagus!\nkamu mendapatkan 10 poin",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Get.offAllNamed(RoutesName.homepage),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text("Home"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}