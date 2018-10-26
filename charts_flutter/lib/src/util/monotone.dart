import 'dart:ui';

class MonotoneX {
  static num sign(x) {
    return x < 0 ? -1 : 1;
  }

  static num slope3(x0, y0, x1, y1, x2, y2) {
    num h0 = x1 - x0;
    num h1 = x2 - x1;
    num s0 = (y1 - y0) /
        (h0 != 0 ? h0 : (h1 < 0 ? -double.infinity : double.infinity));
    num s1 = (y2 - y1) /
        (h1 != 0 ? h1 : (h0 < 0 ? -double.infinity : double.infinity));
    num p = (s0 * h1 + s1 * h0) / (h0 + h1);
    var source = [s0.abs(), s1.abs(), 0.5 * p.abs()];
    source.sort();
    return (sign(s0) + sign(s1)) * source.first ?? 0;
  }

// Calculate a one-sided slope.
  static num slope2(x0, y0, x1, y1, t) {
    var h = x1 - x0;
    return h != 0 ? (3 * (y1 - y0) / h - t) / 2 : t;
  }

// According to https://en.wikipedia.org/wiki/Cubic_Hermite_spline#Representations
// "you can express cubic Hermite interpolation in terms of cubic Bézier curves
// with respect to the four values p0, p0 + m0 / 3, p1 - m1 / 3, p1".
  static Path point(path, x0, y0, x1, y1, t0, t1) {
    var dx = (x1 - x0) / 3;
    path.cubicTo(x0 + dx, y0 + dx * t0, x1 - dx, y1 - dx * t1, x1, y1);
    return path;
  }
}
