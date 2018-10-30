// Copyright 2018 the Charts project authors. Please see the AUTHORS file
// for details.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:math' show Point, Rectangle;

import 'package:charts_common/common.dart' as common show Color;
import 'package:charts_flutter/src/util/monotone.dart';
import 'package:flutter/material.dart';

/// Draws a simple line.
///
/// Lines may be styled with dash patterns similar to stroke-dasharray in SVG
/// path elements. Dash patterns are currently only supported between vertical
/// or horizontal line segments at this time.
class PolygonPainter {
  /// Draws a simple line.
  ///
  /// [dashPattern] controls the pattern of dashes and gaps in a line. It is a
  /// list of lengths of alternating dashes and gaps. The rendering is similar
  /// to stroke-dasharray in SVG path elements. An odd number of values in the
  /// pattern will be repeated to derive an even number of values. "1,2,3" is
  /// equivalent to "1,2,3,1,2,3."
  void draw(
      {Canvas canvas,
      Paint paint,
      List<Point> points,
      Rectangle<num> clipBounds,
      common.Color fill,
      common.Color stroke,
      double strokeWidthPx,
      bool fillGradient,
      bool smoothLine}) {
    if (points.isEmpty) {
      return;
    }

    // Apply clip bounds as a clip region.
    if (clipBounds != null) {
      canvas
        ..save()
        ..clipRect(new Rect.fromLTWH(
            clipBounds.left.toDouble(),
            clipBounds.top.toDouble(),
            clipBounds.width.toDouble(),
            clipBounds.height.toDouble()));
    }

    final strokeColor = stroke != null
        ? new Color.fromARGB(stroke.a, stroke.r, stroke.g, stroke.b)
        : null;

    final fillColor = fill != null
        ? new Color.fromARGB(fill.a, fill.r, fill.g, fill.b)
        : null;

    // If the line has a single point, draw a circle.
    if (points.length == 1) {
      final point = points.first;
      paint.color = fillColor;
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(new Offset(point.x, point.y), strokeWidthPx, paint);
    } else {
      if (strokeColor != null && strokeWidthPx != null) {
        paint.strokeWidth = strokeWidthPx;
        paint.strokeJoin = StrokeJoin.bevel;
        paint.style = PaintingStyle.stroke;
      }

      if (fillColor != null) {
        paint.style = PaintingStyle.fill;

        if (fillGradient == true) {
          Rect rect = Rect.fromLTWH(
              clipBounds.left.toDouble(),
              clipBounds.top.toDouble(),
              clipBounds.width.toDouble(),
              clipBounds.height.toDouble());
          paint.shader = LinearGradient(
            colors: [
              Color.fromARGB(
                60,
                fillColor.red,
                fillColor.green,
                fillColor.blue,
              ),
              Color.fromARGB(
                10,
                fillColor.red,
                fillColor.green,
                fillColor.blue,
              )
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(rect);
        } else {
          paint.color = fillColor;
        }
      }

      final path = new Path();

      if (smoothLine) {
        if (points[0].y == points[1].y && points[1].x == points[2].x) {
          path.moveTo(points.last.x.toDouble(), points.last.y.toDouble());
          path.lineTo(points[0].x.toDouble(), points[0].y.toDouble());
          path.lineTo(points[1].x.toDouble(), points[1].y.toDouble());
          path.lineTo(points[2].x.toDouble(), points[2].y.toDouble());
          _addCurve(path, points.sublist(2));
        } else {
          path.moveTo(points.last.x.toDouble(), points.last.y.toDouble());
          path.lineTo(points[0].x.toDouble(), points[0].y.toDouble());

          _addCurve(path,
              points.sublist(0, points.length ~/ 2).reversed.toList(), true);
          path.lineTo(points[points.length ~/ 2].x,
              points[points.length ~/ 2].y.toDouble());

          _addCurve(path, points.sublist(points.length ~/ 2));

          path.lineTo(points.last.x.toDouble(), points.last.y.toDouble());
        }
      } else {
        path.moveTo(points.first.x.toDouble(), points.first.y.toDouble());
        for (var point in points) {
          path.lineTo(point.x.toDouble(), point.y.toDouble());
        }
      }

      canvas.drawPath(path, paint);
      paint.shader = null;
    }

    if (clipBounds != null) {
      canvas.restore();
    }
  }

  void _addCurve(Path path, List<Point> points, [bool reversed = false]) {
    var targetPoints = List<Point>();
    targetPoints.addAll(points);
    targetPoints.add(Point(
        points[points.length - 1].x * 2, points[points.length - 1].y * 2));
    var x0, y0, x1, y1, t0;
    var tmp = [];
    for (int i = 0; i < targetPoints.length; i++) {
      var t1;
      var x = targetPoints[i].x.toDouble();
      var y = targetPoints[i].y.toDouble();
      if (x == x1 && y == y1) return;
      switch (i) {
        case 0:
          break;
        case 1:
          break;
        case 2:
          t1 = MonotoneX.slope3(x0, y0, x1, y1, x, y);
          tmp.add([x0, y0, x1, y1, MonotoneX.slope2(x0, y0, x1, y1, t1), t1]);
          break;
        default:
          t1 = MonotoneX.slope3(x0, y0, x1, y1, x, y);
          tmp.add([x0, y0, x1, y1, t0, t1]);
      }
      x0 = x1;
      y0 = y1;
      x1 = x;
      y1 = y;
      t0 = t1;
    }
    if (reversed) {
      tmp.reversed.forEach((f) {
        MonotoneX.point(path, f[2], f[3], f[0], f[1], f[5], f[4]);
      });
    } else {
      tmp.forEach((f) {
        MonotoneX.point(path, f[0], f[1], f[2], f[3], f[4], f[5]);
      });
    }
  }
}
