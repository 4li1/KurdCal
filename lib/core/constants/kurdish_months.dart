/// Kurdish months with their names in multiple scripts
/// The Kurdish (Solar) calendar shares its mathematical foundation with
/// the Persian/Solar Hijri calendar. Epoch: Newroz, March 21, 612 BCE.
/// Kurdish year offset from Gregorian: +700 (before Newroz) or +700 (after).
///
/// More precisely: Kurdish Year = Gregorian Year + 700 for dates on/after Newroz (Mar 21)
///                 Kurdish Year = Gregorian Year + 699 for dates before Newroz

class KurdishMonths {
  KurdishMonths._();

  static const List<KurdishMonth> months = [
    KurdishMonth(
      number: 1,
      nameSorani: 'خاکەلێوە',
      nameKurmanji: 'Xakelêwe',
      nameEnglish: 'Xakelêwe',
      gregStartMonth: 3,
      gregStartDay: 21,
      days: 31,
      season: KurdishSeason.spring,
    ),
    KurdishMonth(
      number: 2,
      nameSorani: 'گوڵان',
      nameKurmanji: 'Gullan',
      nameEnglish: 'Gullan',
      gregStartMonth: 4,
      gregStartDay: 21,
      days: 31,
      season: KurdishSeason.spring,
    ),
    KurdishMonth(
      number: 3,
      nameSorani: 'جۆزەردان',
      nameKurmanji: 'Jozerdan',
      nameEnglish: 'Jozerdan',
      gregStartMonth: 5,
      gregStartDay: 22,
      days: 31,
      season: KurdishSeason.spring,
    ),
    KurdishMonth(
      number: 4,
      nameSorani: 'پووشپەڕ',
      nameKurmanji: 'Pûşper',
      nameEnglish: 'Pûşper',
      gregStartMonth: 6,
      gregStartDay: 22,
      days: 31,
      season: KurdishSeason.summer,
    ),
    KurdishMonth(
      number: 5,
      nameSorani: 'گەلاوێژ',
      nameKurmanji: 'Gelawêj',
      nameEnglish: 'Gelawêj',
      gregStartMonth: 7,
      gregStartDay: 23,
      days: 31,
      season: KurdishSeason.summer,
    ),
    KurdishMonth(
      number: 6,
      nameSorani: 'خەرمانان',
      nameKurmanji: 'Xermanan',
      nameEnglish: 'Xermanan',
      gregStartMonth: 8,
      gregStartDay: 23,
      days: 31,
      season: KurdishSeason.summer,
    ),
    KurdishMonth(
      number: 7,
      nameSorani: 'ڕەزبەر',
      nameKurmanji: 'Rezber',
      nameEnglish: 'Rezber',
      gregStartMonth: 9,
      gregStartDay: 23,
      days: 30,
      season: KurdishSeason.autumn,
    ),
    KurdishMonth(
      number: 8,
      nameSorani: 'خەزەڵوەر',
      nameKurmanji: 'Xezellwer',
      nameEnglish: 'Xezellwer',
      gregStartMonth: 10,
      gregStartDay: 23,
      days: 30,
      season: KurdishSeason.autumn,
    ),
    KurdishMonth(
      number: 9,
      nameSorani: 'سەرماوەز',
      nameKurmanji: 'Sermawez',
      nameEnglish: 'Sermawez',
      gregStartMonth: 11,
      gregStartDay: 22,
      days: 30,
      season: KurdishSeason.autumn,
    ),
    KurdishMonth(
      number: 10,
      nameSorani: 'بەفرانبار',
      nameKurmanji: 'Befranbar',
      nameEnglish: 'Befranbar',
      gregStartMonth: 12,
      gregStartDay: 22,
      days: 30,
      season: KurdishSeason.winter,
    ),
    KurdishMonth(
      number: 11,
      nameSorani: 'ڕێبەندان',
      nameKurmanji: 'Rêbendan',
      nameEnglish: 'Rêbendan',
      gregStartMonth: 1,
      gregStartDay: 21,
      days: 30,
      season: KurdishSeason.winter,
    ),
    KurdishMonth(
      number: 12,
      nameSorani: 'ڕەشەمێ',
      nameKurmanji: 'Reşemê',
      nameEnglish: 'Reşemê',
      gregStartMonth: 2,
      gregStartDay: 20,
      days: 29, // 30 in leap years
      season: KurdishSeason.winter,
    ),
  ];

  static KurdishMonth byNumber(int month) {
    assert(month >= 1 && month <= 12, 'Month must be 1-12');
    return months[month - 1];
  }
}

enum KurdishSeason {
  spring,  // Biharê — بەهار
  summer,  // Havînê — هاوین
  autumn,  // Payîzê — پایز
  winter,  // Zivistanê — زستان
}

class KurdishMonth {
  final int number;
  final String nameSorani;
  final String nameKurmanji;
  final String nameEnglish;
  final int gregStartMonth;
  final int gregStartDay;
  final int days;
  final KurdishSeason season;

  const KurdishMonth({
    required this.number,
    required this.nameSorani,
    required this.nameKurmanji,
    required this.nameEnglish,
    required this.gregStartMonth,
    required this.gregStartDay,
    required this.days,
    required this.season,
  });

  String nameForLocale(String locale) {
    switch (locale) {
      case 'ckb':  return nameSorani;
      case 'kmr':  return nameKurmanji;
      default:     return nameEnglish;
    }
  }

  String get emoji {
    switch (season) {
      case KurdishSeason.spring: return '🌸';
      case KurdishSeason.summer: return '☀️';
      case KurdishSeason.autumn: return '🍂';
      case KurdishSeason.winter: return '❄️';
    }
  }
}
