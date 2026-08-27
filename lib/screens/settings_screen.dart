import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/theme_provider.dart';
import '../widgets/player_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchGitHub() async {
    final Uri url = Uri.parse('https://github.com/Aymane-Mirouah');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  Future<void> _launchGmail() async {
    final Uri url = Uri.parse(
      'mailto:aymanemirouah3@gmail.com?subject=قرآن Offline - تواصل',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // General
          _SettingsTile(
            icon: Icons.tune_rounded,
            title: 'عام',
            subtitle: 'المظهر والتخزين',
            scheme: scheme,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GeneralSettingsScreen()),
            ),
          ),
          const SizedBox(height: 8),

          // Reciter
          _SettingsTile(
            icon: Icons.mic_rounded,
            title: 'التلاوة',
            subtitle: 'مشاري راشد العفاسي',
            scheme: scheme,
            onTap: () {},
            showArrow: false,
          ),
          const SizedBox(height: 8),

          // About
          Card(
            elevation: 0,
            color: scheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: scheme.primaryContainer,
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: scheme.onPrimaryContainer,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'مشغل القرآن الكريم',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Created by Aymane',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'هذا التطبيق مجاني ومفتوح المصدر، وهو صدقة جارية عن روح عمي عبد الفتاح رحمه الله. نسألكم الدعاء له بالرحمة والمغفرة ولجميع المسلمين والمسلمات.',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: _launchGitHub,
                        icon: const Icon(Icons.code, size: 18),
                        label: const Text('GitHub'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.tonalIcon(
                        onPressed: _launchGmail,
                        icon: const Icon(Icons.email_outlined, size: 18),
                        label: const Text('Gmail'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'V 1.0.0',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ColorScheme scheme;
  final VoidCallback onTap;
  final bool showArrow;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.scheme,
    required this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: scheme.onPrimaryContainer, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
        ),
        trailing: showArrow
            ? Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant)
            : null,
      ),
    );
  }
}

// General Settings Screen
class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('عام')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // Theme
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'المظهر',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: scheme.primary,
              ),
            ),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('تلقائي (Auto)'),
            subtitle: const Text('يتكيف مع ألوان خلفية الهاتف وتنسيق النظام'),
            value: ThemeMode.system,
            groupValue: themeProvider.themeMode,
            onChanged: (mode) {
              if (mode != null) themeProvider.setThemeMode(mode);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('الوضع الفاتح (Light Mode)'),
            value: ThemeMode.light,
            groupValue: themeProvider.themeMode,
            onChanged: (mode) {
              if (mode != null) themeProvider.setThemeMode(mode);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('الوضع الداكن (Dark Mode)'),
            value: ThemeMode.dark,
            groupValue: themeProvider.themeMode,
            onChanged: (mode) {
              if (mode != null) themeProvider.setThemeMode(mode);
            },
          ),

          const Divider(height: 32, indent: 16, endIndent: 16),

          // Storage
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'التخزين',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: scheme.primary,
              ),
            ),
          ),
          const _DownloadedSurahsList(),
        ],
      ),
    );
  }
}

class _DownloadedSurahsList extends StatefulWidget {
  const _DownloadedSurahsList();

  @override
  State<_DownloadedSurahsList> createState() => _DownloadedSurahsListState();
}

class _DownloadedSurahsListState extends State<_DownloadedSurahsList> {
  int _totalSize = 0;

  @override
  void initState() {
    super.initState();
    _loadSize();
  }

  Future<void> _loadSize() async {
    final provider = context.read<PlayerProvider>();
    final size = await provider.getDownloadedSize();
    if (mounted) setState(() => _totalSize = size);
  }

  String _formatSize(int bytes) {
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlayerProvider>();
    final scheme = Theme.of(context).colorScheme;
    final downloaded = provider.surahs
        .where((s) => provider.isDownloaded(s.number))
        .toList();

    if (downloaded.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          elevation: 0,
          color: scheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                'لا توجد سور محملة',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        color: scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${downloaded.length} سورة محملة',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    _formatSize(_totalSize),
                    style: TextStyle(
                      color: scheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ...downloaded.map(
              (surah) => ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${surah.number}',
                      style: TextStyle(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  surah.nameArabic,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  textDirection: TextDirection.rtl,
                ),
                subtitle: Text(
                  surah.nameEnglish,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
                  onPressed: () async {
                    await provider.deleteSurah(surah);
                    await _loadSize();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
