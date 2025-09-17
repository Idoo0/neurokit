import 'package:flutter/material.dart';
import '../utils.dart';

/// Mode sesi yang tersedia
enum SessionMode { chill, learn }

/// Panggil ini dari halaman manapun untuk menampilkan popup.
/// return: SessionMode jika user menekan "Mulai Sesi", atau null jika ditutup.
Future<SessionMode?> showModePicker(BuildContext context) {
  return showModalBottomSheet<SessionMode>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: false,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _ModePickerSheet(),
  );
}

class _ModePickerSheet extends StatefulWidget {
  const _ModePickerSheet();

  @override
  State<_ModePickerSheet> createState() => _ModePickerSheetState();
}

class _ModePickerSheetState extends State<_ModePickerSheet> {
  SessionMode? _selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "pilih mode musik yang\nsesuai mood lu!",
            textAlign: TextAlign.center,
            style: mobileH3,
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _ModeButton(
                  label: "Chill",
                  selected: _selected == SessionMode.chill,
                  onTap: () => setState(() => _selected = SessionMode.chill),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ModeButton(
                  label: "Learn",
                  selected: _selected == SessionMode.learn,
                  onTap: () => setState(() => _selected = SessionMode.learn),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _selected == null
                  ? null
                  : () => Navigator.of(context).pop(_selected),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: _selected == null ? neutral200 : brand800,
                  width: 1.4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.white,
              ),
              child: Text(
                "Mulai Sesi",
                style: bodyText16.copyWith(
                  color: _selected == null ? neutral300 : brand800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: brand900,
          borderRadius: BorderRadius.circular(16),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: brand900.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: bodyText16.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
