import 'package:flutter/material.dart';
import '../../features/shared/screens/feature_detail_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/village/presentation/screens/our_village_screen.dart';
import '../../features/notices/data/models/notice_model.dart';
import '../../features/notices/presentation/screens/notices_screen.dart';
import '../../features/notices/presentation/screens/notice_details_screen.dart';
import '../../features/community/presentation/screens/community_screen.dart';
import '../../features/community/presentation/screens/community_detail_screen.dart';
import '../../features/community/presentation/screens/suggest_activity_screen.dart';
import '../../features/community/data/models/community_model.dart';
import '../../features/places/presentation/screens/places_screen.dart';
import '../../features/places/presentation/screens/place_detail_screen.dart';
import '../../features/places/presentation/screens/suggest_place_screen.dart';
import '../../features/places/presentation/screens/report_place_issue_screen.dart';
import '../../features/places/data/models/place_model.dart';
import '../../features/contacts/presentation/screens/emergency_contacts_screen.dart';
import '../../features/contacts/presentation/screens/emergency_contact_detail_screen.dart';
import '../../features/contacts/data/models/contact_model.dart';
import '../../features/services/presentation/screens/govt_services_screen.dart';
import '../../features/services/presentation/screens/gov_service_detail_screen.dart';
import '../../features/services/data/models/gov_service_model.dart';
import '../../features/events/data/models/event_model.dart';
import '../../features/events/presentation/screens/events_screen.dart';
import '../../features/events/presentation/screens/event_details_screen.dart';
import '../../features/events/presentation/screens/suggest_event_screen.dart';
import '../../features/agri/presentation/screens/agri_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/news/presentation/screens/news_screen.dart';
import '../../features/news/presentation/screens/news_article_detail_screen.dart';
import '../../features/news/presentation/screens/suggest_news_screen.dart';
import '../../features/news/presentation/screens/saved_news_screen.dart';
import '../../features/news/data/models/news_article_model.dart';
import '../state/global_state.dart';

/// Centralized route manager for named routing in GramConnect.
/// Provides smooth animations and clean separation of navigation logic.
class AppRouter {
  AppRouter._();

  static const String home = '/';
  static const String splash = '/splash';
  static const String login = '/login';
  static const String profile = '/profile';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String featureDetail = '/feature-detail';
  static const String noticeDetail = '/notice-detail';
  static const String eventDetail = '/event-detail';
  static const String eventSuggest = '/event-suggest';
  static const String communityDetail = '/community-detail';
  static const String communitySuggest = '/community-suggest';
  static const String placeDetail = '/place-detail';
  static const String placeSuggest = '/place-suggest';
  static const String placeReport = '/place-report';
  static const String emergencyContactDetail = '/emergency-contact-detail';
  static const String govServiceDetail = '/gov-service-detail';
  static const String newsList = '/news';
  static const String newsDetail = '/news-detail';
  static const String newsSuggest = '/news-suggest';
  static const String newsSaved = '/news-saved';
  static const String agriHome = '/agri';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    Widget page;
    
    switch (settings.name) {
      case splash:
        page = const SplashScreen();
        break;
      case home:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            final state = GramConnectStateProvider.of(context);
            return HomeScreen(
              currentLocale: state.locale,
              onLocaleChanged: state.updateLocale,
              isLoggedIn: state.isLoggedIn,
              onLoginStateChanged: state.updateLoginState,
            );
          },
        );
      case login:
        page = const LoginScreen();
        break;
      case profile:
        page = const ProfileScreen();
        break;
      case register:
        page = const RegisterScreen();
        break;
      case forgotPassword:
        page = const ForgotPasswordScreen();
        break;
      case featureDetail:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final featureKey = args['key'] as String? ?? 'unknown';
        if (featureKey == 'our_village') {
          page = const OurVillageScreen();
        } else if (featureKey == 'village_notices') {
          page = const NoticesScreen();
        } else if (featureKey == 'community') {
          page = const CommunityScreen();
        } else if (featureKey == 'important_places') {
          page = const PlacesScreen();
        } else if (featureKey == 'emergency_contacts') {
          page = const EmergencyContactsScreen();
        } else if (featureKey == 'govt_services') {
          page = const GovtServicesScreen();
        } else if (featureKey == 'events_festivals') {
          page = const EventsScreen();
        } else if (featureKey == 'village_news' || featureKey == 'news') {
          page = const NewsScreen();
        } else if (featureKey == 'agri_info') {
          page = const AgriScreen();
        } else {
          page = FeatureDetailScreen(
            featureKey: featureKey,
            icon: args['icon'] as IconData? ?? Icons.help_outline,
            accentColor: args['color'] as Color? ?? Colors.teal,
          );
        }
        break;
      case noticeDetail:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        page = NoticeDetailsScreen(
          notice: args['notice'] as NoticeItem,
        );
        break;
      case eventDetail:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        page = EventDetailsScreen(
          event: args['event'] as EventItem,
        );
        break;
      case eventSuggest:
        page = const SuggestEventScreen();
        break;
      case communityDetail:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        page = CommunityDetailScreen(
          item: args['item'] as CommunityItem,
        );
        break;
      case communitySuggest:
        page = const SuggestActivityScreen();
        break;
      case placeDetail:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        page = PlaceDetailScreen(
          place: args['place'] as Place,
        );
        break;
      case placeSuggest:
        page = const SuggestPlaceScreen();
        break;
      case placeReport:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        page = ReportPlaceIssueScreen(
          place: args['place'] as Place,
        );
        break;
      case emergencyContactDetail:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        page = EmergencyContactDetailScreen(
          contact: args['contact'] as EmergencyContact,
        );
        break;
      case govServiceDetail:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        page = GovServiceDetailScreen(
          service: args['service'] as GovernmentService,
        );
        break;
      case newsList:
        page = const NewsScreen();
        break;
      case newsDetail:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        page = NewsArticleDetailScreen(
          article: args['article'] as NewsArticle,
        );
        break;
      case newsSuggest:
        page = const SuggestNewsScreen();
        break;
      case newsSaved:
        page = const SavedNewsScreen();
        break;
      case agriHome:
        page = const AgriScreen();
        break;
      default:
        page = Scaffold(
          body: Center(
            child: Text('No route defined for ${settings.name}'),
          ),
        );
    }

    // Custom fade/slide transition for premium feel
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.05); // Subtle upwards lift
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        
        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

// AppRouter transitions and routes managed centrally.
