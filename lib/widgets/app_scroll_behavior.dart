import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Enables natural drag scrolling across touch, mouse, trackpad, and stylus
/// input devices for the portfolio's horizontal rails and page scrolling.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<ui.PointerDeviceKind> get dragDevices => <ui.PointerDeviceKind>{
        ui.PointerDeviceKind.touch,
        ui.PointerDeviceKind.mouse,
        ui.PointerDeviceKind.trackpad,
        ui.PointerDeviceKind.stylus,
      };
}
