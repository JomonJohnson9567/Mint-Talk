import 'dart:math' as math;

import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ScreenUtil-style sizing whose growth is capped, for dense layouts that
/// should look the same on large phones and tablets as on the 375pt design.
///
/// Values still shrink proportionally on small phones, but never grow past
/// [_maxScale] — so a 430pt Pro Max or a tablet gets more room (e.g. extra
/// grid columns) instead of bigger widgets.
extension CompactSize on num {
  static const double _maxScale = 1.05;

  /// Like `.w`, capped at [_maxScale]. Also used for vertical sizes so heights
  /// track the (width-scaled) content they hold.
  double get cw => this * math.min(ScreenUtil().scaleWidth, _maxScale);

  /// Like `.sp`, capped at [_maxScale].
  double get csp => this * math.min(ScreenUtil().scaleText, _maxScale);
}
