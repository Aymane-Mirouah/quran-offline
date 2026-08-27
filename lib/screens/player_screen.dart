import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/player_provider.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  void _showSleepTimerSheet(BuildContext context, PlayerProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مؤقت النوم',
                style: Theme.of(
                  ctx,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (provider.sleepMinutesLeft != null)
                ListTile(
                  leading: const Icon(Icons.timer_off_outlined),
                  title: Text(
                    'إلغاء المؤقت (${provider.sleepMinutesLeft} دقيقة متبقية)',
                  ),
                  onTap: () {
                    provider.cancelSleepTimer();
                    Navigator.pop(ctx);
                  },
                ),
              for (final min in [15, 30, 45, 60, 120])
                ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: Text('$min دقيقة'),
                  onTap: () {
                    provider.setSleepTimer(min);
                    Navigator.pop(ctx);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      final hours = d.inHours.toString();
      final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final provider = context.watch<PlayerProvider>();
    final surah = provider.currentSurah;

    if (surah == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (provider.sleepMinutesLeft != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  '${provider.sleepMinutesLeft}د',
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.timer_outlined),
            onPressed: () => _showSleepTimerSheet(context, provider),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Artwork Container
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          surah.nameArabic,
                          style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.bold,
                            color: scheme.onPrimaryContainer,
                            letterSpacing: 2,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          surah.nameEnglish,
                          style: TextStyle(
                            fontSize: 14,
                            color: scheme.onPrimaryContainer.withValues(
                              alpha: 0.6,
                            ),
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'مشاري راشد العفاسي',
                            style: TextStyle(
                              fontSize: 14,
                              color: scheme.onPrimaryContainer.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Title and Mode / Favorite Buttons
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${surah.revelationType} · عدد آياتها  : ${surah.versesCount}',
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Row(
                    children: [
                      _CircleIconButton(
                        icon: provider.playMode == PlayMode.loop
                            ? Icons.repeat_one_rounded
                            : provider.playMode == PlayMode.shuffle
                            ? Icons.shuffle_rounded
                            : Icons.repeat_rounded,
                        iconColor: provider.playMode == PlayMode.normal
                            ? scheme.onSurface
                            : scheme.primary,
                        onPressed: provider.cyclePlayMode,
                        scheme: scheme,
                      ),
                      const SizedBox(width: 8),
                      _CircleIconButton(
                        icon: surah.isSaved
                            ? Icons.bookmark
                            : Icons.bookmark_outline,
                        iconColor: surah.isSaved
                            ? scheme.primary
                            : scheme.onSurface,
                        onPressed: () => provider.toggleSave(surah),
                        scheme: scheme,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 14,
                  ),
                ),
                child: Slider(
                  value:
                      provider.duration.inSeconds > 0 &&
                          provider.position.inSeconds <=
                              provider.duration.inSeconds
                      ? (provider.position.inMilliseconds /
                                provider.duration.inMilliseconds)
                            .clamp(0.0, 1.0)
                      : 0.0,
                  onChanged: (v) => provider.seekTo(v),
                  activeColor: scheme.onSurface,
                  inactiveColor: scheme.onSurface.withOpacity(0.2),
                ),
              ),

              // Timers
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(provider.position),
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      provider.duration.inSeconds > 0
                          ? _formatDuration(provider.duration)
                          : '--:--',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Main Control Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _MainControlButton(
                    icon: Icons.skip_previous_rounded,
                    size: 30,
                    containerSize: 56,
                    backgroundColor: scheme.surfaceContainerHighest,
                    iconColor: scheme.onSurface,
                    onPressed: provider.playPrevious,
                  ),
                  const SizedBox(width: 24),
                  _MainControlButton(
                    icon: provider.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 36,
                    containerSize: 72,
                    backgroundColor: scheme.onSurface,
                    iconColor: scheme.surface,
                    onPressed: provider.togglePlay,
                  ),
                  const SizedBox(width: 24),
                  _MainControlButton(
                    icon: Icons.skip_next_rounded,
                    size: 30,
                    containerSize: 56,
                    backgroundColor: scheme.surfaceContainerHighest,
                    iconColor: scheme.onSurface,
                    onPressed: provider.playNext,
                  ),
                ],
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onPressed;
  final ColorScheme scheme;

  const _CircleIconButton({
    required this.icon,
    required this.iconColor,
    required this.onPressed,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: iconColor),
        onPressed: onPressed,
      ),
    );
  }
}

class _MainControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final double containerSize;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onPressed;

  const _MainControlButton({
    required this.icon,
    required this.size,
    required this.containerSize,
    required this.backgroundColor,
    required this.iconColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(icon, size: size, color: iconColor),
        onPressed: onPressed,
      ),
    );
  }
}
