import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../core/config/sentry_config.dart';
import '../../core/env/env.dart';
import '../../core/services/sentry_service.dart';
import '../../core/theme/skins/skins.dart';

/// Debug screen for testing and troubleshooting Sentry integration.
///
/// This screen is only accessible in debug builds.
class SentryDebugScreen extends StatefulWidget {
  const SentryDebugScreen({super.key});

  @override
  State<SentryDebugScreen> createState() => _SentryDebugScreenState();
}

class _SentryDebugScreenState extends State<SentryDebugScreen> {
  String _statusLog = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  void _loadStatus() {
    final buffer = StringBuffer()
      ..writeln('═══════════════════════════════════════')
      ..writeln('SENTRY CONFIGURATION STATUS')
      ..writeln('═══════════════════════════════════════')
      ..writeln()
      ..writeln('Environment Variables:')
      ..writeln('  • DSN present: ${Env.hasSentryDsn}')
      ..writeln('  • DSN value: ${_maskDsn(Env.sentryDsn)}')
      ..writeln()
      ..writeln('SentryConfig:')
      ..writeln('  • Enabled: ${SentryConfig.enabled}')
      ..writeln('  • Environment: ${SentryConfig.environment}')
      ..writeln('  • Release: ${SentryConfig.release}')
      ..writeln('  • Should initialize: ${SentryConfig.shouldInitialize}')
      ..writeln('  • Traces sample rate: ${SentryConfig.tracesSampleRate}')
      ..writeln()
      ..writeln('SentryService:')
      ..writeln('  • Initialized: ${SentryService.instance.isInitialized}')
      ..writeln()
      ..writeln('═══════════════════════════════════════');

    setState(() {
      _statusLog = buffer.toString();
    });
  }

  String _maskDsn(String dsn) {
    if (dsn.isEmpty) return '<empty>';
    if (dsn.length < 20) return '<too short>';
    return '${dsn.substring(0, 10)}...${dsn.substring(dsn.length - 10)}';
  }

  Future<void> _sendTestMessage() async {
    setState(() => _isLoading = true);
    _appendLog('\n📤 Sending test message...');
    _appendLog('   DSN present: ${Env.hasSentryDsn}');
    _appendLog('   DSN: ${_maskDsn(Env.sentryDsn)}');

    final id = await SentryService.instance.sendTestEvent();
    final isEmpty = id.toString() == SentryId.empty().toString();

    _appendLog(
      isEmpty
          ? '❌ Failed - empty ID returned (DSN likely missing)'
          : '✅ Test message sent! ID: $id',
    );

    setState(() => _isLoading = false);
  }

  Future<void> _sendTestException() async {
    setState(() => _isLoading = true);
    _appendLog('\n📤 Sending test exception...');

    try {
      final id = await SentryService.instance.captureException(
        Exception('Test exception from YAWA4U debug screen'),
        message: 'This is a test exception for debugging',
      );
      final isEmpty = id.toString() == SentryId.empty().toString();

      _appendLog(
        isEmpty
            ? '❌ Failed - empty ID returned (DSN likely missing)'
            : '✅ Test exception sent! ID: $id',
      );
    } catch (e) {
      _appendLog('❌ Error sending exception: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _sendTestFeedback() async {
    setState(() => _isLoading = true);
    _appendLog('\n📤 Sending test feedback...');

    try {
      await SentryService.instance.captureFeedback(
        message: 'Test feedback from YAWA4U debug screen',
        email: 'debug@test.com',
        name: 'Debug User',
      );

      _appendLog('✅ Test feedback sent!');
    } catch (e) {
      _appendLog('❌ Error sending feedback: $e');
    }

    setState(() => _isLoading = false);
  }

  void _triggerTestCrash() {
    _appendLog('\n💥 Triggering test crash...');
    // This will be caught by Flutter's error handling and sent to Sentry
    throw Exception('Intentional test crash from YAWA4U debug screen');
  }

  void _appendLog(String message) {
    setState(() {
      _statusLog += '\n$message';
    });
  }

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    if (!kDebugMode) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sentry Debug')),
        body: const Center(
          child: Text('Debug screen only available in debug builds'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sentry Debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatus,
            tooltip: 'Refresh status',
          ),
        ],
      ),
      body: Column(
        children: [
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _sendTestMessage,
                  icon: const Icon(Icons.message),
                  label: const Text('Test Message'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _sendTestException,
                  icon: const Icon(Icons.bug_report),
                  label: const Text('Test Exception'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _sendTestFeedback,
                  icon: const Icon(Icons.feedback),
                  label: const Text('Test Feedback'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _triggerTestCrash,
                  icon: const Icon(Icons.dangerous),
                  label: const Text('Test Crash'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.errorColor,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                ),
              ],
            ),
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: LinearProgressIndicator(),
            ),

          const Divider(),

          // Status log
          Expanded(
            child: Container(
              color: Colors.grey[900],
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: SelectableText(
                  _statusLog,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
