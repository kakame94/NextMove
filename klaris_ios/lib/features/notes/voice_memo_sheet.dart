import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../core/i18n/klaris_strings.dart';
import '../../core/theme/klaris_colors.dart';
import '../../core/theme/klaris_typography.dart';
import '../../data/repositories/voice_memos_repository.dart';

/// Modal sheet — record + upload a voice memo, transcribed server-side.
Future<void> showVoiceMemoSheet({
  required BuildContext context,
  required WidgetRef ref,
  String? prospectId,
}) async {
  await showCupertinoModalPopup<void>(
    context: context,
    builder: (_) => _VoiceMemoSheet(prospectId: prospectId),
  );
}

class _VoiceMemoSheet extends ConsumerStatefulWidget {
  final String? prospectId;
  const _VoiceMemoSheet({this.prospectId});

  @override
  ConsumerState<_VoiceMemoSheet> createState() => _VoiceMemoSheetState();
}

class _VoiceMemoSheetState extends ConsumerState<_VoiceMemoSheet> {
  final _rec = AudioRecorder();
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  String? _path;
  bool _recording = false;
  bool _uploading = false;
  String? _error;

  @override
  void dispose() {
    _timer?.cancel();
    _rec.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (!await _rec.hasPermission()) {
      setState(() => _error = ref.s('memo.error.permission'));
      return;
    }
    final dir = await getTemporaryDirectory();
    final path = p.join(dir.path, 'memo-${DateTime.now().millisecondsSinceEpoch}.m4a');
    await _rec.start(const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 64000, sampleRate: 22050), path: path);
    setState(() {
      _recording = true;
      _path = path;
      _elapsed = Duration.zero;
      _error = null;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  Future<void> _stop() async {
    _timer?.cancel();
    await _rec.stop();
    setState(() => _recording = false);
  }

  Future<void> _send() async {
    if (_path == null) return;
    setState(() {
      _uploading = true;
      _error = null;
    });
    try {
      await ref.read(voiceMemosRepoProvider).upload(
            audioFile: File(_path!),
            durationSeconds: _elapsed.inSeconds,
            prospectId: widget.prospectId,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fg = context.klFg();
    final mutedFg = context.klMutedFg();
    final mins = _elapsed.inMinutes.toString().padLeft(2, '0');
    final secs = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');

    return Container(
      decoration: BoxDecoration(color: context.klBg(), borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: context.klBorder(), borderRadius: BorderRadius.circular(2))),
              Text(ref.s('memo.title'), style: KlarisType.h2(fg)),
              const SizedBox(height: 8),
              Text(ref.s('memo.hint'), textAlign: TextAlign.center, style: KlarisType.bodySmall(mutedFg)),
              const SizedBox(height: 32),

              // Big mic button
              GestureDetector(
                onTap: _uploading ? null : (_recording ? _stop : _start),
                child: Container(
                  width: 96, height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _recording ? KlarisColors.destructive : context.klPrimary(),
                    boxShadow: [BoxShadow(color: (_recording ? KlarisColors.destructive : context.klPrimary()).withValues(alpha: 0.4), blurRadius: 24)],
                  ),
                  child: Icon(
                    _recording ? CupertinoIcons.stop_fill : CupertinoIcons.mic_fill,
                    color: CupertinoColors.white,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '$mins:$secs',
                style: KlarisType.h1(fg).copyWith(fontFamily: 'GeistMono', fontFeatures: const [FontFeature.tabularFigures()]),
              ),
              const SizedBox(height: 24),
              if (_path != null && !_recording)
                CupertinoButton.filled(
                  borderRadius: BorderRadius.circular(12),
                  onPressed: _uploading ? null : _send,
                  child: _uploading
                      ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                      : Text(ref.s('memo.send'), style: KlarisType.body(KlarisColors.primaryFg).copyWith(fontWeight: FontWeight.w700)),
                ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: KlarisType.bodySmall(KlarisColors.destructive)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
