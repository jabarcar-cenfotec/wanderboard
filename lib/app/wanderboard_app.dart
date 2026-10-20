import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/wander_typography.dart';
import '../features/auth/data/fake_auth_service.dart';
import '../features/boards/data/in_memory_board_repository.dart';
import '../features/places/data/in_memory_place_repository.dart';
import '../features/places/domain/place_repository.dart';
import '../features/profile/data/mock_profile.dart';
import 'app_scope.dart';
import 'device_frame.dart';
import 'router.dart';

class WanderboardApp extends StatefulWidget {
  const WanderboardApp({super.key, this.fonts = const GoogleFontResolver()});

  /// Injected so tests can avoid network font fetching.
  final FontResolver fonts;

  @override
  State<WanderboardApp> createState() => _WanderboardAppState();
}

class _WanderboardAppState extends State<WanderboardApp> {
  late final GoRouter _router = createRouter();
  late final PlaceRepository _places = InMemoryPlaceRepository();
  late final FakeAuthService _auth = FakeAuthService();
  late final ThemeData _theme = AppTheme.light(fonts: widget.fonts);

  @override
  void dispose() {
    _router.dispose();
    _places.dispose();
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      boards: const InMemoryBoardRepository(),
      places: _places,
      auth: _auth,
      profile: mockProfile,
      child: MaterialApp.router(
        title: 'Wanderboard',
        debugShowCheckedModeBanner: false,
        theme: _theme,
        locale: const Locale('es'),
        supportedLocales: const [Locale('es')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        routerConfig: _router,
        builder: (context, child) => DeviceFrame(child: child!),
      ),
    );
  }
}
