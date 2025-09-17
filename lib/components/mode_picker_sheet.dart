import 'package:flutter/material.dart';
import '../models/mode.dart';
import '../utils.dart';

Future<SessionMode?> showModePicker(BuildContext context) {
  return showModalBottomSheet<SessionMode>(
    context: context,
    isScrollControlled: false,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _ModePickerSheet(),
  );
}

class _ModePickerSheet extends StatefulWidget {
  const _ModePickerSheet({super.key});

  @override
  State<_ModePickerSheet> createState() => _ModePickerSheetState();
}

class _ModePickerSheetState extends State<_ModePickerSheet> {
  SessionMode? _selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // drag handle
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: neutral200,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 14),

          // title 2 baris (sesuai desain)
          Text(
            'pilih mode musik yang',
            textAlign: TextAlign.center,
            style: mobileH3.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            'sesuai mood lu!',
            textAlign: TextAlign.center,
            style: mobileH3.copyWith(fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 18),

          // pilihan Chill & Learn
          Row(
            children: [
              Expanded(
                child: _ModeChoice(
                  label: 'Chill',
                  selected: _selected == SessionMode.chill,
                  onTap: () => setState(() => _selected = SessionMode.chill),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _ModeChoice(
                  label: 'Learn',
                  selected: _selected == SessionMode.learn,
                  onTap: () => setState(() => _selected = SessionMode.learn),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // tombol Mulai Sesi (disabled bila belum pilih)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _selected == null
                  ? null
                  : () => Navigator.pop(context, _selected),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: _selected == null ? neutral200 : brand600,
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                backgroundColor: Colors.white,
                foregroundColor: _selected == null ? neutral400 : brand600,
                textStyle: bodyText16.copyWith(fontWeight: FontWeight.w600),
              ),
              child: const Text('Mulai Sesi'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeChoice extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChoice({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fill = selected ? brand800 : neutral50;
    final txt = selected ? Colors.white : neutral900;
    final borderColor = selected ? brand800 : neutral200;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: brand800.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: bodyText16.copyWith(color: txt, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
