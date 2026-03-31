/// Calendar Conversion Engine
/// Uses Julian Day Numbers (JDN) as the universal intermediate format.
/// All conversions: Source → JDN → Target
///
/// Kurdish calendar shares its mathematical leap-year algorithm with the
/// Persian/Solar Hijri calendar (the Jalali calendar).
/// Kurdish year offset: Kurdish Year = Gregorian Year + 700 (approximately)

library calendar_converter;

class KurdishDate {
  final int year;
  final int month;  // 1-12
  final int day;    // 1-31

  const KurdishDate({
    required this.year,
    required this.month,
    required this.day,
  });

  @override
  String toString() => '$year/$month/$day';
  
  @override
  bool operator ==(Object other) =>
      other is KurdishDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);
}

class HijriDate {
  final int year;
  final int month;  // 1-12
  final int day;

  const HijriDate({
    required this.year,
    required this.month,
    required this.day,
  });

  static const List<String> monthNames = [
    'Muharram', 'Safar', "Rabi' al-Awwal", "Rabi' al-Akhir",
    'Jumada al-Awwal', 'Jumada al-Akhir', 'Rajab', "Sha'ban",
    'Ramadan', 'Shawwal', "Dhu al-Qi'dah", 'Dhu al-Hijjah',
  ];

  static const List<String> monthNamesArabic = [
    'محرم', 'صفر', 'ربیع الاول', 'ربیع الثانی',
    'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان',
    'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة',
  ];

  @override
  String toString() => '$year/$month/$day';
}

/// The Calendar Converter — core conversion logic
class CalendarConverter {
  CalendarConverter._();

  // ── Julian Day Number conversions ─────────────────────────────────────

  /// Convert a Gregorian date to Julian Day Number
  static int gregorianToJdn(int year, int month, int day) {
    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    return day +
        (153 * m + 2) ~/ 5 +
        365 * y +
        y ~/ 4 -
        y ~/ 100 +
        y ~/ 400 -
        32045;
  }

  /// Convert a Julian Day Number to a Gregorian date [year, month, day]
  static List<int> jdnToGregorian(int jdn) {
    final a = jdn + 32044;
    final b = (4 * a + 3) ~/ 146097;
    final c = a - (146097 * b) ~/ 4;
    final d = (4 * c + 3) ~/ 1461;
    final e = c - (1461 * d) ~/ 4;
    final m = (5 * e + 2) ~/ 153;
    final day = e - (153 * m + 2) ~/ 5 + 1;
    final month = m + 3 - 12 * (m ~/ 10);
    final year = 100 * b + d - 4800 + m ~/ 10;
    return [year, month, day];
  }

  // ── Kurdish (Solar Hijri-based) Calendar ──────────────────────────────

  /// The Kurdish calendar epoch as a JDN.
  /// Corresponds to the Kurdish year 1, month 1, day 1 = March 22, 612 BCE (proleptic Gregorian).
  /// In practice, we use the Solar Hijri epoch adjusted by 1029 years:
  /// Kurdish Year = Solar Hijri Year + 1029
  /// Solar Hijri epoch JDN = 1948320 (March 22, 622 CE proleptic Julian)
  /// Kurdish epoch = 1948320 - (1029 * 365.2422) ≈ adjusted accordingly.
  ///
  /// Simpler approach: directly from Solar Hijri algorithms.
  /// Kurdish Year = Persian/Solar Year + 1029
  static const int _persianEpoch = 1948320;

  /// Convert Gregorian to Kurdish date
  static KurdishDate gregorianToKurdish(int gYear, int gMonth, int gDay) {
    final jdn = gregorianToJdn(gYear, gMonth, gDay);
    return _jdnToKurdish(jdn);
  }

  /// Convert Kurdish date to Gregorian
  static List<int> kurdishToGregorian(int kYear, int kMonth, int kDay) {
    final jdn = _kurdishToJdn(kYear, kMonth, kDay);
    return jdnToGregorian(jdn);
  }

  /// Convert DateTime to Kurdish date
  static KurdishDate dateTimeToKurdish(DateTime date) {
    return gregorianToKurdish(date.year, date.month, date.day);
  }

  static KurdishDate _jdnToKurdish(int jdn) {
    // Offset to Solar Hijri, then add 1029 for Kurdish year
    final dep = jdn - _persianEpoch;
    
    // 2820-year grand cycle of Solar Hijri calendar
    final cycle        = dep ~/ 1029983;
    final rem          = dep % 1029983;
    
    int yCycle;
    if (rem == 1029982) {
      yCycle = 2820;
    } else {
      final aux         = (820 * rem + 196196) ~/ 1029983;
      yCycle            = ((-128 + 2134 * aux + 2820 * cycle) + ((128 * rem - 196196 + dep) ~/ 366)) ~/ 2820;
      // Simplified approximation for the year within cycle:
      yCycle           = (2134 * (rem ~/ 366) + 1) ~/ 2820;
    }
    
    // Fallback to simple epoch-based approach (more reliable for our scope)
    return _solveBySubtraction(jdn);
  }

  /// Reliable day-counting approach for Kurdish date from JDN
  static KurdishDate _solveBySubtraction(int jdn) {
    // Find the Kurdish year by binary search / iteration
    // Kurdish year 1 starts at JDN = gregorianToJdn(-611, 3, 21)
    // (612 BCE = year -611 in astronomical year numbering)
    
    // Approximate year first
    const epochJdn = 1317746; // JDN for March 21, 612 BCE (Kurdish year 1 start)
    final approxYear = ((jdn - epochJdn) / 365.2422).floor() + 1;
    
    // Find the exact year by checking year start JDNs
    int year = approxYear;
    
    // Ensure we are in correct year
    while (_kurdishYearStartJdn(year + 1) <= jdn) {
      year++;
    }
    while (_kurdishYearStartJdn(year) > jdn) {
      year--;
    }
    
    // Now find month
    final yearStart = _kurdishYearStartJdn(year);
    int dayOfYear = jdn - yearStart + 1; // 1-indexed
    
    int month = 1;
    while (month < 12 && dayOfYear > _daysInKurdishMonth(year, month)) {
      dayOfYear -= _daysInKurdishMonth(year, month);
      month++;
    }
    
    return KurdishDate(year: year, month: month, day: dayOfYear);
  }

  /// JDN of the first day of a Kurdish year
  static int _kurdishYearStartJdn(int kYear) {
    // Kurdish year start corresponds to Gregorian March 21 approximately
    // More precisely, use leap year math to find exact Nowruz JDN
    // Kurdish Year N starts on the same day as Persian/Solar Year (N - 1029)
    final persianYear = kYear - 1029;
    return _persianNewYearJdn(persianYear);
  }

  /// JDN of Persian New Year (Nowruz) for a given Persian year
  static int _persianNewYearJdn(int persianYear) {
    // Based on Borkowski's algorithm
    final epbase = persianYear - (persianYear >= 0 ? 474 : 473);
    final epyear = 474 + epbase % 2820;
    
    return (((epyear * 682) - 110) ~/ 2816) +
        (epyear - 1) * 365 +
        (epbase ~/ 2820) * 1029983 +
        (_persianEpoch - 1);
  }

  /// Days in a specific Kurdish month (accounts for leap years in month 12)
  static int _daysInKurdishMonth(int year, int month) {
    if (month <= 6) return 31;
    if (month <= 11) return 30;
    // Month 12: 29 days normally, 30 in leap year
    return isKurdishLeapYear(year) ? 30 : 29;
  }

  /// Is this Kurdish year a leap year?
  /// Uses the same 2820-year cycle as the Solar Hijri calendar.
  static bool isKurdishLeapYear(int year) {
    final persianYear = year - 1029;
    return _isPersianLeapYear(persianYear);
  }

  static bool _isPersianLeapYear(int year) {
    final rem = ((year - (year > 0 ? 474 : 473)) % 2820 + 474 + 38) * 682 % 2816;
    return rem < 682;
  }

  /// Convert Kurdish date to JDN
  static int _kurdishToJdn(int kYear, int kMonth, int kDay) {
    final yearStart = _kurdishYearStartJdn(kYear);
    int doy = 0;
    for (int m = 1; m < kMonth; m++) {
      doy += _daysInKurdishMonth(kYear, m);
    }
    return yearStart + doy + kDay - 1;
  }

  // ── Islamic (Hijri) Calendar ──────────────────────────────────────────
  // Tabular Islamic calendar (civil, Friday epoch, most common for display)

  static const int _hijriEpoch = 1948440; // JDN of 1 Muharram 1 AH

  /// Convert Gregorian to Hijri
  static HijriDate gregorianToHijri(int gYear, int gMonth, int gDay) {
    final jdn = gregorianToJdn(gYear, gMonth, gDay);
    return _jdnToHijri(jdn);
  }

  /// Convert DateTime to Hijri
  static HijriDate dateTimeToHijri(DateTime date) {
    return gregorianToHijri(date.year, date.month, date.day);
  }

  static HijriDate _jdnToHijri(int jdn) {
    final d = jdn - _hijriEpoch;
    final n = 30 * d + 29;
    final year = n ~/ 10631 + 1;
    final yearStart = _hijriEpoch + ((year - 1) * 10631) ~/ 30;
    final dayOfYear = jdn - yearStart + 1;

    int month = 1;
    int remaining = dayOfYear;
    while (month <= 12) {
      final daysInMonth = _hijriMonthDays(year, month);
      if (remaining <= daysInMonth) break;
      remaining -= daysInMonth;
      month++;
    }
    if (month > 12) month = 12;

    return HijriDate(year: year, month: month, day: remaining.clamp(1, 30));
  }

  static int _hijriMonthDays(int year, int month) {
    // Odd months = 30 days, even months = 29 days
    // Last month (12) = 30 days in leap years
    if (month % 2 == 1) return 30;
    if (month == 12 && _isHijriLeapYear(year)) return 30;
    return 29;
  }

  static bool _isHijriLeapYear(int year) {
    return (11 * year + 14) % 30 < 11;
  }

  // ── Convenience Methods ───────────────────────────────────────────────

  /// Get all three calendar representations for a DateTime
  static Map<String, dynamic> allCalendarsForDate(DateTime date) {
    return {
      'gregorian': date,
      'kurdish': dateTimeToKurdish(date),
      'hijri': dateTimeToHijri(date),
    };
  }

  /// Get the Kurdish date for today
  static KurdishDate get todayKurdish => dateTimeToKurdish(DateTime.now());

  /// Get the Hijri date for today
  static HijriDate get todayHijri => dateTimeToHijri(DateTime.now());
}
