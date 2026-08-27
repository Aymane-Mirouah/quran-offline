import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/player_provider.dart';
import '../models/surah.dart';
import '../widgets/mini_player.dart';
import 'player_screen.dart';
import 'saved_screen.dart';
import 'settings_screen.dart';
import '../widgets/welcome_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WelcomeDialog.showIfFirstTime(context);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final provider = context.watch<PlayerProvider>();

    final List<Surah> filtered = provider.surahs.where((s) {
      final q = _searchQuery.toLowerCase();
      return s.nameArabic.contains(q) ||
          s.nameEnglish.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: [
              _buildSurahList(filtered, scheme, provider),
              const SavedScreen(),
            ],
          ),
          if (provider.currentSurah != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: kBottomNavigationBarHeight - 24,
              child: const MiniPlayer(),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'السور',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: 'المحفوظة',
          ),
        ],
      ),
    );
  }

  Widget _buildSurahList(
    List<Surah> filtered,
    ColorScheme scheme,
    PlayerProvider provider,
  ) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 120,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: const Text(
              'القرآن الكريم',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: false,
            titlePadding: const EdgeInsets.only(
              left: 16,
              bottom: 16,
              right: 16,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'ابحث عن سورة...',
              leading: const Icon(Icons.search),
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor: WidgetStatePropertyAll(
                scheme.surfaceContainerHighest,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, i) {
            final surah = filtered[i];
            return _SurahTile(
              surah: surah,
              provider: provider,
              onTap: () {
                if (provider.currentSurah?.number != surah.number) {
                  provider.playSurah(surah);
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PlayerScreen()),
                );
              },
              onSave: () => provider.toggleSave(surah),
            );
          }, childCount: filtered.length),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 160)),
      ],
    );
  }
}

class _SurahTile extends StatelessWidget {
  final Surah surah;
  final VoidCallback onTap;
  final VoidCallback onSave;
  final PlayerProvider provider;

  const _SurahTile({
    required this.surah,
    required this.onTap,
    required this.onSave,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isPlaying = provider.currentSurah?.number == surah.number;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Card(
        elevation: 1,
        shadowColor: scheme.shadow,
        color: isPlaying
            ? scheme.primaryContainer
            : scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isPlaying
              ? BorderSide(color: scheme.primary, width: 1.5)
              : BorderSide.none,
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isPlaying ? scheme.primary : scheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: isPlaying
                  ? Icon(Icons.graphic_eq, color: scheme.onPrimary, size: 20)
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
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              surah.number >= 85
                  ? Icon(
                      Icons.download_done_rounded,
                      color: scheme.primary,
                      size: 20,
                    )
                  : provider.downloadProgress.containsKey(surah.number)
                  ? GestureDetector(
                      onTap: () => provider.cancelDownload(surah.number),
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: provider.downloadProgress[surah.number],
                              strokeWidth: 2.5,
                              color: scheme.primary,
                            ),
                            Icon(Icons.close, size: 14, color: scheme.primary),
                          ],
                        ),
                      ),
                    )
                  : provider.downloadedSurahs[surah.number] == true
                  ? Icon(
                      Icons.download_done_rounded,
                      color: scheme.primary,
                      size: 20,
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.download_outlined,
                        color: scheme.onSurfaceVariant,
                      ),
                      onPressed: () => provider.downloadSurah(surah),
                    ),
              IconButton(
                icon: Icon(
                  surah.isSaved ? Icons.bookmark : Icons.bookmark_outline,
                  color: surah.isSaved
                      ? scheme.primary
                      : scheme.onSurfaceVariant,
                ),
                onPressed: onSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
