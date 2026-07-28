import 'dart:convert';

import 'package:http/http.dart' as http;

/// One YouTube video candidate for an exercise.
class Candidate {
  Candidate({
    required this.videoId,
    required this.title,
    required this.channel,
    required this.description,
    required this.durationSeconds,
    required this.viewCount,
    required this.embeddable,
  });

  final String videoId;
  final String title;
  final String channel;
  final String description;
  final int durationSeconds;
  final int viewCount;
  final bool embeddable;

  Map<String, dynamic> toJson() => {
    'videoId': videoId,
    'title': title,
    'channel': channel,
    'description': description,
    'durationSeconds': durationSeconds,
    'viewCount': viewCount,
    'embeddable': embeddable,
  };
}

/// Parses ISO-8601 durations as returned by the YouTube API (e.g. PT4M13S).
int parseIsoDuration(String iso) {
  final match = RegExp(
    r'^PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?$',
  ).firstMatch(iso);
  if (match == null) return 0;
  final hours = int.parse(match.group(1) ?? '0');
  final minutes = int.parse(match.group(2) ?? '0');
  final seconds = int.parse(match.group(3) ?? '0');
  return hours * 3600 + minutes * 60 + seconds;
}

class QuotaTracker {
  int spent = 0;
}

class YoutubeClient {
  YoutubeClient(this.apiKey, {http.Client? httpClient, QuotaTracker? quota})
    : _http = httpClient ?? http.Client(),
      quota = quota ?? QuotaTracker();

  final String apiKey;
  final http.Client _http;
  final QuotaTracker quota;

  static const _base = 'www.googleapis.com';

  /// Searches for embeddable videos and returns verified candidates.
  ///
  /// Costs 100 quota units for the search plus 1 for verification.
  Future<List<Candidate>> searchCandidates(
    String query, {
    int maxResults = 8,
    Set<String> excludeIds = const {},
  }) async {
    final searchJson = await _get('/youtube/v3/search', {
      'part': 'snippet',
      'q': query,
      'type': 'video',
      'videoEmbeddable': 'true',
      'videoSyndicated': 'true',
      'maxResults': '$maxResults',
      'relevanceLanguage': 'en',
      'safeSearch': 'none',
    });
    quota.spent += 100;

    final ids = [
      for (final item in searchJson['items'] as List)
        item['id']['videoId'] as String,
    ].where((id) => !excludeIds.contains(id)).toList();
    if (ids.isEmpty) return [];

    final videosJson = await _get('/youtube/v3/videos', {
      'part': 'snippet,contentDetails,statistics,status',
      'id': ids.join(','),
    });
    quota.spent += 1;

    return [
      for (final item in videosJson['items'] as List)
        Candidate(
          videoId: item['id'] as String,
          title: item['snippet']['title'] as String? ?? '',
          channel: item['snippet']['channelTitle'] as String? ?? '',
          description: item['snippet']['description'] as String? ?? '',
          durationSeconds: parseIsoDuration(
            item['contentDetails']['duration'] as String,
          ),
          viewCount:
              int.tryParse(item['statistics']?['viewCount'] as String? ?? '') ??
              0,
          embeddable: item['status']?['embeddable'] as bool? ?? false,
        ),
    ].where((c) => c.embeddable).toList();
  }

  Future<Map<String, dynamic>> _get(
    String path,
    Map<String, String> params,
  ) async {
    final uri = Uri.https(_base, path, {...params, 'key': apiKey});
    final response = await _http.get(uri);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      final message = json['error']?['message'] ?? response.body;
      throw YoutubeApiException(response.statusCode, '$message');
    }
    return json;
  }

  void close() => _http.close();
}

class YoutubeApiException implements Exception {
  YoutubeApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;

  bool get isQuotaExceeded =>
      statusCode == 403 && message.toLowerCase().contains('quota');

  @override
  String toString() => 'YoutubeApiException($statusCode): $message';
}
