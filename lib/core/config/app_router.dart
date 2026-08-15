///
/// @file app_router.dart
/// @description GoRouter configuration defining navigation hierarchy, bottom nav shell, and deep linking.
/// @author Frontend Core / Navigation Lead
///
library app_router;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // TODO: Define ShellRoute with BottomNavigationBar and Feature Routes
    ],
  );
});
