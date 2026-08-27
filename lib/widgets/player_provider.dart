import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/surah.dart';
import '../data/surahs_data.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

enum PlayMode { normal, loop, shuffle }

class PlayerProvider extends ChangeNotifier {
  Surah? _currentSurah;
  bool _isPlaying = false;
  final List<Surah> _savedSurahs = [];
  final List<Surah> _surahs = List.from(surahsData);
  PlayMode _playMode = PlayMode.normal;
  Timer? _sleepTimer;
  int? _sleepMinutesLeft;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  ConcatenatingAudioSource? _playlist;

  final Map<int, bool> _downloadedSurahs = {};
  final Map<int, double> _downloadProgress = {};
  final Map<int, CancelToken> _cancelTokens = {};
  final Map<int, String> _downloadedPaths = {};

  Surah? get currentSurah => _currentSurah;
  bool get isPlaying => _isPlaying;
  List<Surah> get savedSurahs => _savedSurahs;
  List<Surah> get surahs => _surahs;
  PlayMode get playMode => _playMode;
  int? get sleepMinutesLeft => _sleepMinutesLeft;
  Duration get position => _position;
  Duration get duration => _duration;
  Map<int, bool> get downloadedSurahs => _downloadedSurahs;
  Map<int, double> get downloadProgress => _downloadProgress;
  bool isBundled(int number) => number >= 85;
  bool isDownloaded(int number) => _downloadedSurahs[number] ?? false;

  PlayerProvider() {
    _initPlaylist();

    _audioPlayer.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _audioPlayer.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
      notifyListeners();
    });

    _audioPlayer.playingStream.listen((playing) {
      _isPlaying = playing;
      notifyListeners();
    });

    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null && index >= 0 && index < _surahs.length) {
        _currentSurah = _surahs[index];
        _position = Duration.zero;
        _duration = Duration.zero;
        notifyListeners();
      }
    });
  }

  String _getAudioUri(Surah surah) {
    if (isBundled(surah.number)) {
      return 'asset:///assets/audio/${surah.number}.mp3';
    }
    if (isDownloaded(surah.number) &&
        _downloadedPaths.containsKey(surah.number)) {
      return 'file://${_downloadedPaths[surah.number]}';
    }
    return 'https://download.quranicaudio.com/quran/mishaari_raashid_al_3afaasee/${surah.number.toString().padLeft(3, '0')}.mp3';
  }

  AudioSource _buildSource(Surah surah) {
    final uri = _getAudioUri(surah);
    return AudioSource.uri(
      Uri.parse(uri),
      tag: MediaItem(
        id: uri,
        album: 'قرآن offline',
        title: surah.nameArabic,
        artist: 'القرآن الكريم',
        artUri: Uri.parse('asset:///assets/icon/app_icon.png'),
      ),
    );
  }

  void _initPlaylist() {
    _playlist = ConcatenatingAudioSource(
      useLazyPreparation: true,
      children: _surahs.map(_buildSource).toList(),
    );
  }

  Future<void> playSurah(Surah surah) async {
    final index = _surahs.indexWhere((s) => s.number == surah.number);
    if (index == -1) return;

    _currentSurah = surah;
    _position = Duration.zero;
    _duration = Duration.zero;
    notifyListeners();

    try {
      // Always reset the player to avoid stuck error state
      await _audioPlayer.stop();
      await _audioPlayer.setAudioSource(
        _playlist!,
        initialIndex: index,
        preload: false,
      );
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Audio error: $e');
      // Reset player completely on error so next surah works
      try {
        await _audioPlayer.stop();
        _isPlaying = false;
        notifyListeners();
      } catch (_) {}
    }
  }

  Future<void> togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  Future<void> seekTo(double value) async {
    if (_duration.inMilliseconds == 0) return;
    final seekPos = Duration(
      milliseconds: (value * _duration.inMilliseconds).round(),
    );
    await _audioPlayer.seek(seekPos);
  }

  void toggleSave(Surah surah) {
    final idx = _surahs.indexWhere((s) => s.number == surah.number);
    if (idx == -1) return;
    _surahs[idx].isSaved = !_surahs[idx].isSaved;
    if (_surahs[idx].isSaved) {
      if (!_savedSurahs.any((s) => s.number == surah.number)) {
        _savedSurahs.add(_surahs[idx]);
      }
    } else {
      _savedSurahs.removeWhere((s) => s.number == surah.number);
    }
    notifyListeners();
  }

  void cyclePlayMode() {
    switch (_playMode) {
      case PlayMode.normal:
        _playMode = PlayMode.loop;
        _audioPlayer.setLoopMode(LoopMode.one);
        _audioPlayer.setShuffleModeEnabled(false);
        break;
      case PlayMode.loop:
        _playMode = PlayMode.shuffle;
        _audioPlayer.setLoopMode(LoopMode.all);
        _audioPlayer.setShuffleModeEnabled(true);
        break;
      case PlayMode.shuffle:
        _playMode = PlayMode.normal;
        _audioPlayer.setLoopMode(LoopMode.off);
        _audioPlayer.setShuffleModeEnabled(false);
        break;
    }
    notifyListeners();
  }

  Future<void> playNext() async {
    if (_audioPlayer.hasNext) {
      await _audioPlayer.seekToNext();
    } else {
      // Loop back to first surah
      await _audioPlayer.seek(Duration.zero, index: 0);
      await _audioPlayer.play();
    }
  }

  Future<void> playPrevious() async {
    if (_audioPlayer.hasPrevious) {
      await _audioPlayer.seekToPrevious();
    }
  }

  void setSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    _sleepMinutesLeft = minutes;
    notifyListeners();
    _sleepTimer = Timer.periodic(const Duration(minutes: 1), (t) {
      if (_sleepMinutesLeft == null || _sleepMinutesLeft! <= 1) {
        _audioPlayer.pause();
        _sleepMinutesLeft = null;
        t.cancel();
      } else {
        _sleepMinutesLeft = _sleepMinutesLeft! - 1;
      }
      notifyListeners();
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepMinutesLeft = null;
    notifyListeners();
  }

  Future<void> downloadSurah(Surah surah) async {
    if (isBundled(surah.number) || isDownloaded(surah.number)) return;
    if (_downloadProgress.containsKey(surah.number)) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/surah_${surah.number}.mp3';
      final url =
          'https://download.quranicaudio.com/quran/mishaari_raashid_al_3afaasee/${surah.number.toString().padLeft(3, '0')}.mp3';

      _downloadProgress[surah.number] = 0.0;
      final cancelToken = CancelToken();
      _cancelTokens[surah.number] = cancelToken;
      notifyListeners();

      final dio = Dio();
      await dio.download(
        url,
        path,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            _downloadProgress[surah.number] = received / total;
            notifyListeners();
          }
        },
      );

      _downloadedSurahs[surah.number] = true;
      _downloadedPaths[surah.number] = path;
      _downloadProgress.remove(surah.number);
      _cancelTokens.remove(surah.number);

      // Update playlist source to use local file
      final index = _surahs.indexWhere((s) => s.number == surah.number);
      if (index != -1 && _playlist != null) {
        await _playlist!.removeAt(index);
        await _playlist!.insert(index, _buildSource(surah));
      }

      notifyListeners();
    } catch (e) {
      _downloadProgress.remove(surah.number);
      _cancelTokens.remove(surah.number);
      if (e is! DioException || e.type != DioExceptionType.cancel) {
        debugPrint('Download error: $e');
      }
      notifyListeners();
    }
  }

  void cancelDownload(int surahNumber) {
    _cancelTokens[surahNumber]?.cancel('User cancelled');
    _cancelTokens.remove(surahNumber);
    _downloadProgress.remove(surahNumber);
    notifyListeners();
  }

  Future<void> deleteSurah(Surah surah) async {
    if (isBundled(surah.number) || !isDownloaded(surah.number)) return;
    try {
      final path = _downloadedPaths[surah.number];
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
      _downloadedSurahs.remove(surah.number);
      _downloadedPaths.remove(surah.number);

      // Reset playlist source back to stream URL
      final index = _surahs.indexWhere((s) => s.number == surah.number);
      if (index != -1 && _playlist != null) {
        await _playlist!.removeAt(index);
        await _playlist!.insert(index, _buildSource(surah));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }

  Future<int> getDownloadedSize() async {
    int total = 0;
    for (final path in _downloadedPaths.values) {
      final file = File(path);
      if (await file.exists()) {
        total += await file.length();
      }
    }
    return total;
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
