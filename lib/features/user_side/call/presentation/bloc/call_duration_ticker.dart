import 'dart:async';

/// One-second call-duration timer extracted out of [CallScreenCubit] — a
/// self-contained ticker with no state/termination-guard dependency.
class CallDurationTicker {
  Timer? _timer;

  void start(void Function() onTick) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => onTick());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
