class Utils {
  static DateTime convertUtcTimestampToLocal(int timestamp) {
    // Convert timestamp to DateTime object in UTC
    final DateTime utcDateTime = DateTime.fromMillisecondsSinceEpoch(
        timestamp * 1000, // Convert seconds to milliseconds
        isUtc: true
    );

    // Convert UTC to local time
    final DateTime localDateTime = utcDateTime.toLocal();

    return localDateTime;
  }
}