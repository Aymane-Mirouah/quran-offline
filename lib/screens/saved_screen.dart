import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/player_provider.dart';
import 'player_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final provider = context.watch<PlayerProvider>();
    final saved = provider.savedSurahs;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(title: const Text('المحفوظة'), centerTitle: false),
      body: saved.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bookmark_outline,
                    size: 64,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد سور محفوظة',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: saved.length,
              itemBuilder: (context, i) {
                final surah = saved[i];
                final isPlaying = provider.currentSurah?.number == surah.number;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Card(
                    elevation: 2,
                    shadowColor: scheme.shadow,
                    color: isPlaying
                        ? scheme.primaryContainer
                        : scheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: isPlaying
                          ? BorderSide(color: scheme.primary, width: 1.5)
                          : BorderSide.none,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isPlaying
                              ? scheme.primary
                              : scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: isPlaying
                              ? Icon(
                                  Icons.graphic_eq,
                                  color: scheme.onPrimary,
                                  size: 20,
                                )
                              : Text(
                                  '${surah.number}',
                                  style: TextStyle(
                                    color: scheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            surah.nameArabic,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: isPlaying
                                  ? scheme.onPrimaryContainer
                                  : scheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '· ${surah.nameEnglish}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: scheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        '${surah.revelationType} · عدد آياتها : ${surah.versesCount}',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.bookmark, color: scheme.primary),
                        onPressed: () => provider.toggleSave(surah),
                      ),
                      onTap: () {
                        if (provider.currentSurah?.number != surah.number) {
                          provider.playSurah(surah);
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PlayerScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
