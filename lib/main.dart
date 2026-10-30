import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/analytics_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/community_provider.dart';
import 'providers/decision_provider.dart';
import 'providers/discussion_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/poll_provider.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/main/main_shell.dart';
import 'services/realtime_database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Firebase Realtime Database
  await RealtimeDatabaseService().initialize();

  runApp(const CommunityPollingApp());
}

class CommunityPollingApp extends StatelessWidget {
  const CommunityPollingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => PollProvider()),
        ChangeNotifierProvider(create: (_) => DiscussionProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => DecisionProvider()),
      ],
      child: MaterialApp(
        title: 'Community Polling',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return auth.isAuthenticated ? const MainShell() : const WelcomeScreen();
          },
        ),
      ),
    );
  }
}
