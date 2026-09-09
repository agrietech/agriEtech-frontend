import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agrietech/core/utils/responsive.dart';

void main() {
  group('WindowSize.fromWidth', () {
    test('classifies the Material 3 boundaries exactly', () {
      // The boundaries themselves, not just the middle of each band — an
      // off-by-one in the comparison operator only shows up here.
      expect(WindowSize.fromWidth(0), WindowSize.compact);
      expect(WindowSize.fromWidth(599), WindowSize.compact);
      expect(WindowSize.fromWidth(599.99), WindowSize.compact);
      expect(WindowSize.fromWidth(600), WindowSize.medium);
      expect(WindowSize.fromWidth(1023), WindowSize.medium);
      expect(WindowSize.fromWidth(1023.99), WindowSize.medium);
      expect(WindowSize.fromWidth(1024), WindowSize.expanded);
      expect(WindowSize.fromWidth(4096), WindowSize.expanded);
    });

    test('breakpoint constants match the Material 3 spec', () {
      expect(Breakpoints.medium, 600);
      expect(Breakpoints.expanded, 1024);
      // main.dart's pre-runApp orientation lock keys off this; if it ever
      // diverges from `medium`, phones and tablets get classified differently
      // before and after the first frame.
      expect(Breakpoints.phoneShortestSide, Breakpoints.medium);
    });
  });

  group('ResponsiveContextExtension', () {
    /// Pumps a widget at a fixed logical window width and hands the resulting
    /// BuildContext to [inspect].
    Future<void> atWidth(
      WidgetTester tester,
      double width,
      void Function(BuildContext context) inspect,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(size: Size(width, 800)),
          child: Builder(
            builder: (BuildContext context) {
              inspect(context);
              return const SizedBox();
            },
          ),
        ),
      );
    }

    testWidgets('windowSize and the boolean getters agree', (tester) async {
      await atWidth(tester, 400, (context) {
        expect(context.windowSize, WindowSize.compact);
        expect(context.isCompact, isTrue);
        expect(context.isMedium, isFalse);
        expect(context.isExpanded, isFalse);
        expect(context.isWide, isFalse);
      });

      await atWidth(tester, 800, (context) {
        expect(context.windowSize, WindowSize.medium);
        expect(context.isCompact, isFalse);
        expect(context.isMedium, isTrue);
        expect(context.isExpanded, isFalse);
        expect(context.isWide, isTrue);
      });

      await atWidth(tester, 1400, (context) {
        expect(context.windowSize, WindowSize.expanded);
        expect(context.isCompact, isFalse);
        expect(context.isMedium, isFalse);
        expect(context.isExpanded, isTrue);
        expect(context.isWide, isTrue);
      });
    });

    testWidgets('responsive() returns the value for the active class',
        (tester) async {
      await atWidth(tester, 400, (context) {
        expect(context.responsive(compact: 2, medium: 3, expanded: 4), 2);
      });
      await atWidth(tester, 800, (context) {
        expect(context.responsive(compact: 2, medium: 3, expanded: 4), 3);
      });
      await atWidth(tester, 1400, (context) {
        expect(context.responsive(compact: 2, medium: 3, expanded: 4), 4);
      });
    });

    testWidgets('responsive() cascades to the next narrower value when a '
        'breakpoint is omitted', (tester) async {
      // expanded omitted -> falls back to medium.
      await atWidth(tester, 1400, (context) {
        expect(context.responsive(compact: 1, medium: 2), 2);
      });
      // medium omitted -> falls back to compact.
      await atWidth(tester, 800, (context) {
        expect(context.responsive(compact: 1, expanded: 3), 1);
      });
      // Both omitted -> compact everywhere. This is what makes the helper safe
      // to drop into an existing layout without changing it.
      await atWidth(tester, 1400, (context) {
        expect(context.responsive(compact: 7), 7);
      });
    });

    testWidgets('rebuilds when the window is resized', (tester) async {
      // The helper reads MediaQuery.sizeOf (not .of), so a resize must
      // propagate. If it ever regresses to reading a cached size, the second
      // expectation fails.
      final List<WindowSize> observed = <WindowSize>[];

      Widget appAt(double width) => MediaQuery(
            data: MediaQueryData(size: Size(width, 800)),
            child: Builder(
              builder: (BuildContext context) {
                observed.add(context.windowSize);
                return const SizedBox();
              },
            ),
          );

      await tester.pumpWidget(appAt(400));
      await tester.pumpWidget(appAt(1400));

      expect(observed, <WindowSize>[WindowSize.compact, WindowSize.expanded]);
    });
  });
}
