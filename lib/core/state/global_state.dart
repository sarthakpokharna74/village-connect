import 'package:flutter/material.dart';
import '../../features/auth/data/models/user_model.dart';

/// Centralized state provider for GramConnect, implemented using native InheritedWidget.
/// Manages global state (e.g. active locale, authentication status, active user session) reactively across all routes.
class GramConnectStateProvider extends InheritedWidget {
  final Locale locale;
  final bool isLoggedIn;
  final UserProfile? currentUser;
  final ValueChanged<Locale> updateLocale;
  final ValueChanged<bool> updateLoginState;
  final void Function(UserProfile? user, bool loggedIn)? updateUserSession;

  const GramConnectStateProvider({
    super.key,
    required this.locale,
    required this.isLoggedIn,
    this.currentUser,
    required this.updateLocale,
    required this.updateLoginState,
    this.updateUserSession,
    required super.child,
  });

  /// Retrieve the state provider from the build tree
  static GramConnectStateProvider of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<GramConnectStateProvider>();
    assert(provider != null, 'No GramConnectStateProvider found in context.');
    return provider!;
  }

  @override
  bool updateShouldNotify(GramConnectStateProvider oldWidget) {
    return locale != oldWidget.locale ||
        isLoggedIn != oldWidget.isLoggedIn ||
        currentUser != oldWidget.currentUser;
  }
}
