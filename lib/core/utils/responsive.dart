import 'package:flutter/material.dart';

/// Material 3 window size classes.
///
/// Breakpoints follow the Material 3 spec so layout decisions are consistent
/// across the app instead of each screen inventing its own MediaQuery check.
///
/// See https://m3.material.io/foundations/layout/applying-layout/window-size-classes
enum WindowSize {
  /// Phones in portrait. Single column, bottom navigation.
  compact,

  /// Small tablets, phones in landscape, resized desktop windows.
  medium,

  /// Tablets in landscape, desktop, web. Room for side-by-side content.
  expanded;

  /// Classify a logical width in density-independent pixels.
  static WindowSize fromWidth(double width) {
    if (width < Breakpoints.medium) return WindowSize.compact;
    if (width < Breakpoints.expanded) return WindowSize.medium;
    return WindowSize.expanded;
  }
}

/// Raw breakpoint values, in logical pixels.
///
/// Exposed so tests and non-widget code (for example the orientation lock in
/// `main.dart`, which runs before the first `BuildContext` exists) can classify
/// a width without a [BuildContext].
abstract final class Breakpoints {
  /// Width at which [WindowSize.medium] begins. Below this is a phone.
  static const double medium = 600;

  /// Width at which [WindowSize.expanded] begins.
  static const double expanded = 1024;

  /// A device whose *shortest* side is under this is a phone in any rotation.
  ///
  /// Uses the shortest side rather than the current width so the result does
  /// not flip when the user rotates the device.
  static const double phoneShortestSide = medium;
}

/// Ergonomic [BuildContext] extensions for responsive layout, mirroring the
/// shape of the localization extension (`context.tr`) so screens read
/// consistently.
extension ResponsiveContextExtension on BuildContext {
  /// The current window size class.
  ///
  /// Reads `MediaQuery.sizeOf`, so a widget using this rebuilds when the window
  /// is resized or the device rotated.
  WindowSize get windowSize => WindowSize.fromWidth(MediaQuery.sizeOf(this).width);

  /// True on phones — the single-column case.
  bool get isCompact => windowSize == WindowSize.compact;

  /// True on small tablets and resized desktop windows.
  bool get isMedium => windowSize == WindowSize.medium;

  /// True on large tablets, desktop and web.
  bool get isExpanded => windowSize == WindowSize.expanded;

  /// True for anything wider than a phone. Convenient for "show the second
  /// pane" style decisions.
  bool get isWide => windowSize != WindowSize.compact;

  /// Pick a value per window size class.
  ///
  /// [medium] and [expanded] fall back to the next narrower value when omitted,
  /// so callers only specify the breakpoints they actually care about:
  ///
  /// ```dart
  /// final columns = context.responsive(compact: 1, expanded: 2);
  /// ```
  T responsive<T>({required T compact, T? medium, T? expanded}) {
    switch (windowSize) {
      case WindowSize.compact:
        return compact;
      case WindowSize.medium:
        return medium ?? compact;
      case WindowSize.expanded:
        return expanded ?? medium ?? compact;
    }
  }
}
