import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/utils/user_errors.dart';

void main() {
  group('describe', () {
    group('network errors', () {
      test('socket error', () {
        expect(
          UserErrors.describe(Exception('SocketException: no internet')),
          'Check your connection and try again.',
        );
      });

      test('connection refused', () {
        expect(
          UserErrors.describe(Exception('Connection refused')),
          'Check your connection and try again.',
        );
      });

      test('timeout', () {
        expect(
          UserErrors.describe(Exception('Request timeout')),
          'Check your connection and try again.',
        );
      });

      test('host lookup failure', () {
        expect(
          UserErrors.describe(Exception('Host lookup failed')),
          'Check your connection and try again.',
        );
      });
    });

    group('state errors', () {
      test('StateError maps correctly', () {
        expect(
          UserErrors.describe(StateError('Bad state: no element')),
          'Something got into a bad state. Try again.',
        );
      });
    });

    group('permission errors', () {
      test('permission denied', () {
        expect(
          UserErrors.describe(Exception('Permission denied')),
          'Permission was denied. Open Settings to grant access.',
        );
      });

      test('unauthorized', () {
        expect(
          UserErrors.describe(Exception('Unauthorized access')),
          'Permission was denied. Open Settings to grant access.',
        );
      });
    });

    group('database constraint errors', () {
      test('unique constraint', () {
        expect(
          UserErrors.describe(Exception('UNIQUE constraint failed')),
          'That change conflicts with existing data.',
        );
      });

      test('foreign key constraint', () {
        expect(
          UserErrors.describe(Exception('FOREIGN KEY constraint failed')),
          'That change conflicts with existing data.',
        );
      });
    });

    group('not found errors', () {
      test('no element', () {
        expect(
          UserErrors.describe(Exception('No element')),
          'Not found — it may have been deleted.',
        );
      });

      test('not found', () {
        expect(
          UserErrors.describe(Exception('Resource not found')),
          'Not found — it may have been deleted.',
        );
      });
    });

    group('generic fallback', () {
      test('unrecognized error falls back', () {
        expect(
          UserErrors.describe(Exception('something completely random')),
          'Something went wrong. Try again in a moment.',
        );
      });
    });

    group('context prefix', () {
      test('adds "Couldn\'t {context}" prefix', () {
        expect(
          UserErrors.describe(
            Exception('random error'),
            context: 'Save session',
          ),
          "Couldn't Save session — Something went wrong. Try again in a moment.",
        );
      });

      test('no prefix when context is null', () {
        expect(
          UserErrors.describe(Exception('random error')),
          'Something went wrong. Try again in a moment.',
        );
      });

      test('no prefix when context is empty', () {
        expect(
          UserErrors.describe(Exception('random error'), context: '  '),
          'Something went wrong. Try again in a moment.',
        );
      });
    });
  });
}
