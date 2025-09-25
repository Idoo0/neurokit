import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import '../routes/routes_name.dart';
import '../services/local_storage_service.dart';
import '../utils.dart';

class WarmUpPage extends StatefulWidget {
  const WarmUpPage({Key? key}) : super(key: key);

  @override
  State<WarmUpPage> createState() => _WarmUpPageState();
}

enum WarmupMode { easy, medium, hard }

extension WarmupModeX on WarmupMode {
  (int min, int max) get spanRange {
    switch (this) {
      case WarmupMode.easy: return (3, 5);
      case WarmupMode.medium: return (5, 7);
      case WarmupMode.hard: return (7, 9);
    }
  }

  String get label {
    switch (this) {
      case WarmupMode.easy: return "Easy (3–5)";
      case WarmupMode.medium: return "Medium (5–7)";
      case WarmupMode.hard: return "Hard (7–9)";
    }
  }
}

class _WarmUpPageState extends State<WarmUpPage> {
  final _rng = Random();
  final TextEditingController _controller = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();

  WarmupMode? _mode;
  late List<List<int>> _questions;
  int _qIndex = 0;
  int _totalScore = 0;
  String _visibleDigit = "";
  bool _isShowingSequence = false;
  bool _awaitingInput = false;
  int _timeLeft = 10;
  Timer? _questionTimer;
  int _lastCorrectDigits = 0;
  int step = 0;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("id-ID");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speakDigit(int digit) async {
    const Map<int, String> indonesianWords = {
      0: "nol", 1: "satu", 2: "dua", 3: "tiga", 4: "empat",
      5: "lima", 6: "enam", 7: "tujuh", 8: "delapan", 9: "sembilan"
    };
    final wordToSpeak = indonesianWords[digit] ?? '';
    if (wordToSpeak.isNotEmpty) {
      print("Attempting to speak: $wordToSpeak");
      await _flutterTts.speak(wordToSpeak);
    }
  }

  Duration _nextDigitDuration() => const Duration(milliseconds: 750);

  List<List<int>> _generateQuestions(WarmupMode mode) {
    final (minLen, maxLen) = mode.spanRange;
    final List<int> questionLengths = [
      minLen, minLen, minLen,
      minLen + 1, minLen + 1, minLen + 1,
      maxLen, maxLen,
    ];

    return List.generate(8, (index) {
      final len = questionLengths[index];
      if (len == 0) return <int>[];
      List<int> question = [];
      question.add(_rng.nextInt(10));
      for (int i = 1; i < len; i++) {
        int newDigit;
        do { newDigit = _rng.nextInt(10); } while (newDigit == question.last);
        question.add(newDigit);
      }
      return question;
    });
  }

  List<int> get _currentDigits {
    if (_questions.isEmpty) return const <int>[];
    final lastIndex = _questions.length - 1;
    final safeIndex = _qIndex.clamp(0, lastIndex);
    return _questions[safeIndex];
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _controller.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  void _selectMode(WarmupMode m) {
    setState(() {
      _mode = m;
      _questions = _generateQuestions(m);
      _qIndex = 0;
      _startShowSequence();
    });
  }

  Future<void> _startShowSequence() async {
    setState(() {
      step = 1;
      _visibleDigit = "";
      _isShowingSequence = true;
      _awaitingInput = false;
      _timeLeft = 10;
      _controller.clear();
    });

    for (final d in _currentDigits) {
      if (!mounted) return;
      setState(() => _visibleDigit = d.toString());
      _speakDigit(d);
      await Future.delayed(_nextDigitDuration());
    }

    if (!mounted) return;
    setState(() {
      _visibleDigit = "";
      _isShowingSequence = false;
    });

    _startInputPhase();
  }

  void _startInputPhase() {
    setState(() {
      step = 2;
      _awaitingInput = true;
      _timeLeft = 10;
    });

    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          t.cancel();
          _submitAnswer();
        }
      });
    });
  }

  void _submitAnswer() {
    _questionTimer?.cancel();
    final answer = _controller.text.trim();
    final expected = _currentDigits.map((e) => e.toString()).join();
    int correctDigits = 0;
    final minLen = min(answer.length, expected.length);
    for (int i = 0; i < minLen; i++) {
      if (answer[i] == expected[i]) correctDigits++;
    }
    _totalScore += correctDigits;
    setState(() {
      _awaitingInput = false;
      _lastCorrectDigits = correctDigits;
      step = 3;
    });
  }

  Future<void> _nextQuestionOrFinish() async {
    _questionTimer?.cancel();

    final lastIndex = _questions.length - 1;
    final isLast = _qIndex >= lastIndex;

    if (isLast) {
      final store = Get.find<LocalStorageService>();
      await store.setWarmupResult(score: _totalScore, totalQuestions: _questions.length);
      await store.markStudyStartedNow();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Get.offNamed(RoutesName.studySession);
      });
      return;
    }

    setState(() => _qIndex++);
    _startShowSequence();
  }

  /// ⭐️ Displays a confirmation dialog before canceling the warmup.
  Future<bool?> _showCancelConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Batalkan Warmup?'),
          content: const Text('Progres tidak akan disimpan. Yakin ingin kembali ke menu utama?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Tidak', style: TextStyle(color: neutral700)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Ya, Batalkan', style: TextStyle(color: brand600, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (step) {
      case 0: content = _modePicker(); break;
      case 1: content = _showSequenceView(); break;
      case 2: content = _inputView(); break;
      case 3: content = _feedbackView(); break;
      default: content = _modePicker();
    }
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding * 1.5),
                child: content,
              ),
            ),
            if (step == 1 || step == 2)
              Positioned(
                top: 8,
                left: 8,
                child: TextButton.icon(
                  icon: const Icon(Icons.close, color: neutral500),
                  label: Text(
                    "Batalkan",
                    style: bodyText14.copyWith(color: neutral500),
                  ),
                  onPressed: () async {
                    // ⭐️ Show confirmation dialog before canceling
                    final shouldCancel = await _showCancelConfirmationDialog();
                    if (shouldCancel == true && mounted) {
                      Get.offAllNamed(RoutesName.homepage);
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _modePicker() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Pilih Mode Warmup", style: mobileH2, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        for (final m in WarmupMode.values) ...[
          SizedBox(
            width: 240,
            child: ElevatedButton(
              onPressed: () => _selectMode(m),
              style: ElevatedButton.styleFrom(
                backgroundColor: brand700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(m.label, style: buttonText),
            ),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 12),
        Text(
          "8 soal • 10 detik per soal\nPoin per angka benar",
          textAlign: TextAlign.center,
          style: bodyText14.copyWith(color: neutral600),
        ),
      ],
    );
  }

  Widget _showSequenceView() {
    final total = _questions.length;
    final shownIndex = (_qIndex + 1).clamp(1, total);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Soal $shownIndex/$total", style: mobileH4),
        const SizedBox(height: 24),
        Text(
          _isShowingSequence ? "Inget angkanya ya!" : "Siap-siap jawab",
          style: mobileH2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 120,
          width: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_isShowingSequence && _visibleDigit.isNotEmpty) ...[
                Text(
                  _visibleDigit,
                  style: mobileH1.copyWith(fontSize: 72),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(Icons.volume_up, color: neutral400),
                ),
              ] else
                Icon(Icons.visibility, size: 88, color: neutral300),
            ],
          ),
        )
      ],
    );
  }

  Widget _inputView() {
    final total = _questions.length;
    final shownIndex = (_qIndex + 1).clamp(1, total);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Soal $shownIndex/$total", style: mobileH4),
        const SizedBox(height: 12),
        Text("Masukkan urutan angkanya", style: mobileH3, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        SizedBox(
          width: 220,
          child: TextField(
            controller: _controller,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: mobileH4,
            decoration: InputDecoration(
              hintText: "Masukkan angkanya",
              hintStyle: bodyText16.copyWith(color: neutral400),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Waktu: $_timeLeft dtk",
          style: bodyText16.copyWith(
            color: _timeLeft <= 3 ? Colors.red : neutral800,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _awaitingInput ? _submitAnswer : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: brand700,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Text("Periksa", style: buttonText),
        ),
      ],
    );
  }

  Widget _feedbackView() {
    final lastIndex = (_questions.length - 1).clamp(0, _questions.length == 0 ? 0 : _questions.length - 1);
    final safeIndex = _qIndex.clamp(0, lastIndex);
    final expected = _questions.isEmpty
        ? ""
        : _questions[safeIndex].map((e) => e.toString()).join();

    final user = _controller.text.trim();
    final total = _questions.length;
    final shownIndex = (_qIndex + 1).clamp(1, total);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _lastCorrectDigits == _currentDigits.length
              ? "Mantap! Jawabanmu tepat 🎯"
              : _lastCorrectDigits == 0
              ? "Ups, hampir!\nFokus sedikit lagi,\nkamu pasti bisa."
              : "Lumayan! $_lastCorrectDigits benar dari ${_currentDigits.length}",
          style: mobileH3,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        _answerCard("Jawaban Benar", expected),
        const SizedBox(height: 10),
        _answerCard("Jawaban Kamu", user.isEmpty ? "—" : user),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _statBox("Soal", "$shownIndex/$total", yellow700),
            const SizedBox(width: 10),
            _statBox("Poin", _totalScore.toString(), brand400),
          ],
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _nextQuestionOrFinish,
          style: ElevatedButton.styleFrom(
            backgroundColor: brand700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            safeIndex >= total - 1 ? "Mulai Sesi Belajar" : "Lanjut",
            style: buttonText,
          ),
        ),
      ],
    );
  }

  Widget _answerCard(String label, String value) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: neutral100,
        borderRadius: AppConstants.defaultBorderRadius,
      ),
      child: Column(
        children: [
          Text(label, style: bodyText14.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(value, style: mobileH4.copyWith(letterSpacing: 2)),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: bodyText14.copyWith(fontWeight: FontWeight.bold, color: neutral900),
          ),
          Text(
            value,
            style: bodyText16.copyWith(fontWeight: FontWeight.bold, color: neutral900),
          ),
        ],
      ),
    );
  }
}