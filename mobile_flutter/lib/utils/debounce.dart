import 'dart:async';

/// A simple debounce utility that delays execution of a callback
/// until after [duration] has elapsed since the last call.
///
/// Usage:
/// ```dart
/// final _debounce = Debounce(const Duration(milliseconds: 400));
///
/// // Inside onChanged:
/// _debounce.run(() => doSearch(query));
///
/// // Don't forget to dispose:
/// _debounce.dispose();
/// ```
class Debounce {
  final Duration duration;
  Timer? _timer;

  Debounce(this.duration);

  /// Schedule [action] to run after [duration].
  /// If called again before the timer fires, the previous timer is cancelled.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// Cancel any pending timer without running the action.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Cancel the timer and release resources.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  /// Whether a call is currently pending.
  bool get isPending => _timer?.isActive ?? false;
}
