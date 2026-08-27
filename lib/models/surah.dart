class Surah {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final int versesCount;
  final String revelationType;
  bool isSaved;

  Surah({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.versesCount,
    required this.revelationType,
    this.isSaved = false,
  });
}
