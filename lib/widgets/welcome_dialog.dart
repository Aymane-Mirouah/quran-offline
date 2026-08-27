import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeDialog {
  static Future<void> showIfFirstTime(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool('welcome_shown') ?? false;
    if (shown) return;
    await prefs.setBool('welcome_shown', true);

    if (!context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'مشغل القرآن الكريم',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_book_rounded, size: 48, color: scheme.primary),
              const SizedBox(height: 16),
              const Text(
                'أهلاً بك عزيزي المستخدم',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 12),
              const Text(
                'حرصت على تقديم أفضل جودة صوتية ممكنة لتلاوة القرآن الكريم. استخدمت بعض الحيل التقنية لضمان تجربة استماع سلسة وجميلة ',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 13, height: 1.7),
              ),
              const SizedBox(height: 16),
              _InfoRow(
                icon: Icons.download_done_rounded,
                text: 'السور من 85 إلى 114 محملة مسبقاً وتعمل بدون انترنت.',
              ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.wifi_rounded,
                text: 'باقي السور تحتاج انترنت، أو حملها مسبقاً من القائمة.',
              ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.favorite_outline_rounded,
                text: 'أتمنى أن يعجبك التطبيق',
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('حسنا'),
            ),
          ],
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: scheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
      ],
    );
  }
}
