import 'package:flutter/material.dart';
import 'dart:ui';

// <CustomScroll>
/* 
This page scroll physics make it possible to scroll page by page even though the page is not full of device-screen.
*/
class MyPageScrollPhysics extends ScrollPhysics {
  final double pageWidthInPixel;
  const MyPageScrollPhysics({super.parent, required this.pageWidthInPixel});

  @override
  MyPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return MyPageScrollPhysics(
        parent: buildParent(ancestor), pageWidthInPixel: pageWidthInPixel);
  }

  double _getPage(ScrollMetrics position) {
    return position.pixels / pageWidthInPixel;
  }

  double _getPixels(double pageIdx) {
    return pageIdx * pageWidthInPixel;
  }

  double _getTargetPixels(
      ScrollMetrics position, Tolerance tolerance, double velocity) {
    double page = _getPage(position);
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    return _getPixels(page.roundToDouble());
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at a page boundary.
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final Tolerance tolerance = toleranceFor(position);
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}

/* This custom scroll behavior enables mouse wheel */
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  const MyCustomScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
// </CustomScroll>