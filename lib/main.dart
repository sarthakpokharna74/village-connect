import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/localization/app_localizations.dart';
import 'core/navigation/app_router.dart';
import 'core/state/global_state.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/models/user_model.dart';
import 'features/auth/data/repositories/auth_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

/// Root widget for the GramConnect application.
/// Manages global localizations, themes, reactive states, and navigation routes.
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  // Application-wide reactive state variables
  Locale _locale = const Locale('en', '');
  bool _isLoggedIn = false;
  UserProfile? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
    _loadUserSession();
  }

  Future<void> _loadLanguagePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLang = prefs.getString('selected_language');
      if (savedLang != null) {
        setState(() {
          _locale = Locale(savedLang, '');
        });
      }
    } catch (_) {
      // Fallback gracefully on local storage failure
    }
  }

  Future<void> _loadUserSession() async {
    try {
      final user = await LocalAuthRepository().getCurrentUser();
      if (user != null) {
        setState(() {
          _currentUser = user;
          _isLoggedIn = true;
        });
      }
    } catch (_) {
      // Fallback gracefully
    }
  }

  void _updateLocale(Locale newLocale) async {
    setState(() {
      _locale = newLocale;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_language', newLocale.languageCode);
    } catch (_) {
      // Gracefully ignore write issues
    }
  }

  void _updateLoginState(bool loggedIn) {
    setState(() {
      _isLoggedIn = loggedIn;
      if (!loggedIn) {
        _currentUser = null;
        LocalAuthRepository().logout();
      }
    });
  }

  void _updateUserSession(UserProfile? user, bool loggedIn) {
    setState(() {
      _currentUser = user;
      _isLoggedIn = loggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GramConnectStateProvider(
      locale: _locale,
      isLoggedIn: _isLoggedIn,
      currentUser: _currentUser,
      updateLocale: _updateLocale,
      updateLoginState: _updateLoginState,
      updateUserSession: _updateUserSession,
      child: MaterialApp(
        title: 'GramConnect',
        
        // --- Theme Configuration (Material 3 Enabled) ---
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Dynamically follows user device theme
        
        // --- Localization Setup ---
        locale: _locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          // Auto-resolve locale if system has preference, fallback to English
          if (locale != null) {
            for (final supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode) {
                return supportedLocale;
              }
            }
          }
          return supportedLocales.first;
        },

        // --- Navigation Setup ---
        initialRoute: AppRouter.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
