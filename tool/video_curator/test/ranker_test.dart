import 'package:test/test.dart';
import 'package:video_curator/ranker.dart';
import 'package:video_curator/youtube_client.dart';

Candidate candidate(String id, String title, {int views = 1000}) => Candidate(
  videoId: id,
  title: title,
  channel: 'ch',
  description: '',
  durationSeconds: 120,
  viewCount: views,
  embeddable: true,
);

void main() {
  group('parseIsoDuration', () {
    test('parses minutes and seconds', () {
      expect(parseIsoDuration('PT4M13S'), 253);
    });
    test('parses hours', () {
      expect(parseIsoDuration('PT1H2M3S'), 3723);
    });
    test('parses seconds only', () {
      expect(parseIsoDuration('PT45S'), 45);
    });
    test('returns 0 for garbage', () {
      expect(parseIsoDuration('bogus'), 0);
    });
  });

  group('heuristicRank', () {
    test('exact title match beats high-view mismatch', () {
      final ranked = heuristicRank('Diamond Push-Ups', [
        candidate('a', 'Top 10 Gym Fails', views: 90000000),
        candidate('b', 'Diamond Push-Ups: Proper Form', views: 5000),
      ]);
      expect(ranked.first.videoId, 'b');
    });

    test('views break ties between equal title matches', () {
      final ranked = heuristicRank('Wall Squat', [
        candidate('low', 'Wall Squat Tutorial', views: 10),
        candidate('high', 'Wall Squat Tutorial', views: 500000),
      ]);
      expect(ranked.first.videoId, 'high');
    });
  });
}
