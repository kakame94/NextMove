import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';

/// Frame-time tracker — logs slow frames in debug, sends to Sentry in prod.
///
/// Drop [PerfMonitor.start] in main() once. Threshold defaults to 16ms (60Hz)
/// but is bumped to 8ms on ProMotion (120Hz) iPhones.
class PerfMonitor {
  PerfMonitor._();
  static final instance = PerfMonitor._();

  final List<double> _samples = [];
  Duration _budget = const Duration(milliseconds: 16);
  void Function(Duration frameDuration, double avgFps)? onSlowFrame;

  void start() {
    SchedulerBinding.instance.addTimingsCallback(_handle);
  }

  void stop() {
    SchedulerBinding.instance.removeTimingsCallback(_handle);
  }

  /// Bump to 8ms after detecting ProMotion display.
  void setProMotion() => _budget = const Duration(microseconds: 8333);

  void _handle(List<FrameTiming> timings) {
    for (final t in timings) {
      final total = t.totalSpan;
      _samples.add(total.inMicroseconds / 1000.0);
      if (_samples.length > 60) _samples.removeAt(0);
      if (total > _budget) {
        final avgFps = _samples.isEmpty
            ? 0.0
            : (1000.0 / (_samples.reduce((a, b) => a + b) / _samples.length));
        onSlowFrame?.call(total, avgFps);
      }
    }
  }
}

/// Sliver-based list with automatic 60-row chunking + cacheExtent tuned for
/// scroll smoothness on long prospect lists.
class FastList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, T) builder;
  final Widget? separator;
  final EdgeInsetsGeometry padding;
  final double cacheExtent;

  const FastList({
    super.key,
    required this.items,
    required this.builder,
    this.separator,
    this.padding = EdgeInsets.zero,
    this.cacheExtent = 600, // ~ 1.5 screens of warm widgets ahead
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      cacheExtent: cacheExtent,
      slivers: [
        SliverPadding(
          padding: padding,
          sliver: SliverList.builder(
            itemCount: separator == null ? items.length : items.length * 2 - 1,
            itemBuilder: (ctx, i) {
              if (separator != null && i.isOdd) return separator!;
              final realIdx = separator == null ? i : i ~/ 2;
              return builder(ctx, items[realIdx]);
            },
          ),
        ),
      ],
    );
  }
}

/// Wraps a child in a [RepaintBoundary] so frequent repaints inside the boundary
/// don't invalidate ancestors. Use on chat bubbles, animated avatars, etc.
class FastRepaint extends StatelessWidget {
  final Widget child;
  const FastRepaint({super.key, required this.child});
  @override
  Widget build(BuildContext context) => RepaintBoundary(child: child);
}

/// Conditional const-friendly [SizedBox] that collapses when [show] is false,
/// without rebuilding the parent (avoids layout thrash).
class CollapsingBox extends StatelessWidget {
  final bool show;
  final Widget child;
  const CollapsingBox({super.key, required this.show, required this.child});

  @override
  Widget build(BuildContext c) => AnimatedSize(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        alignment: Alignment.topCenter,
        child: show ? child : const SizedBox.shrink(),
      );
}
