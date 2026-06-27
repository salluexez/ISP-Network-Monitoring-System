import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/devices/presentation/device_detail_screen.dart';
import '../../features/devices/presentation/device_form_screen.dart';
import '../../features/devices/presentation/device_list_screen.dart';
import '../../features/locations/presentation/location_detail_screen.dart';
import '../../features/locations/presentation/location_form_screen.dart';
import '../../features/locations/presentation/location_list_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final authenticated = authState.hasValue && authState.value != null;
      final loggingIn = state.matchedLocation == '/login';

      if (!authenticated && !loggingIn) return '/login';
      if (authenticated && loggingIn) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/devices',
        name: 'devices',
        builder: (context, state) => const DeviceListScreen(),
      ),
      GoRoute(
        path: '/devices/new',
        name: 'device-create',
        builder: (context, state) => const DeviceFormScreen(),
      ),
      GoRoute(
        path: '/devices/:deviceId',
        name: 'device-detail',
        builder: (context, state) =>
            DeviceDetailScreen(deviceId: state.pathParameters['deviceId']!),
      ),
      GoRoute(
        path: '/devices/:deviceId/edit',
        name: 'device-edit',
        builder: (context, state) =>
            DeviceFormScreen(deviceId: state.pathParameters['deviceId']!),
      ),
      GoRoute(
        path: '/locations',
        name: 'locations',
        builder: (context, state) => const LocationListScreen(),
      ),
      GoRoute(
        path: '/locations/new',
        name: 'location-create',
        builder: (context, state) => const LocationFormScreen(),
      ),
      GoRoute(
        path: '/locations/:locationId',
        name: 'location-detail',
        builder: (context, state) => LocationDetailScreen(
          locationId: state.pathParameters['locationId']!,
        ),
      ),
      GoRoute(
        path: '/locations/:locationId/edit',
        name: 'location-edit',
        builder: (context, state) =>
            LocationFormScreen(locationId: state.pathParameters['locationId']!),
      ),
    ],
  );
});
