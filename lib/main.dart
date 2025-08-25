import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/app_state.dart';
import 'providers/theme_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/idea_listing_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://opjcagprnkgnpouoslzy.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9wamNhZ3BybmtnbnBvdW9zbHp5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUwODY5MjMsImV4cCI6MjA3MDY2MjkyM30.OysXHouaJikfXzGGfKjoAOsnq-EkzuW7q1hMawRRhSo',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Startup Idea Evaluator',
            themeMode: themeProvider.themeMode,
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.purple,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.grey[50],
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    const ColorScheme darkColorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFBB86FC),
      onPrimary: Color(0xFF000000),
      secondary: Color(0xFF03DAC6),
      onSecondary: Color(0xFF000000),
      tertiary: Color(0xFFCF6679),
      onTertiary: Color(0xFF000000),
      surface: Color(0xFF1E1E1E),
      onSurface: Color(0xFFE1E1E1),
      surfaceVariant: Color(0xFF2D2D2D),
      onSurfaceVariant: Color(0xFFCACACA),
      background: Color(0xFF121212),
      onBackground: Color(0xFFE1E1E1),
      error: Color(0xFFCF6679),
      onError: Color(0xFF000000),
      outline: Color(0xFF938F94),
      shadow: Color(0xFF000000),
      inverseSurface: Color(0xFFE1E1E1),
      onInverseSurface: Color(0xFF121212),
      inversePrimary: Color(0xFF6200EE),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: darkColorScheme,
      scaffoldBackgroundColor: const Color(0xFF121212),
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark().textTheme.apply(
          bodyColor: const Color(0xFFE1E1E1),
          displayColor: const Color(0xFFE1E1E1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Color(0xFFE1E1E1),
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Color(0xFFE1E1E1),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color(0xFF2D2D2D),
            width: 0.5,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFBB86FC),
          foregroundColor: const Color(0xFF000000),
          disabledBackgroundColor: const Color(0xFF3C3C3C),
          disabledForegroundColor: const Color(0xFF6E6E6E),
          elevation: 3,
          shadowColor: Colors.black.withOpacity(0.4),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFBB86FC),
        ),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFFCACACA),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2D2D2D),
        thickness: 0.5,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF2D2D2D),
        contentTextStyle: TextStyle(color: Color(0xFFE1E1E1)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;
        if (session != null) {
          return const IdeaListingScreen();
        }
        return const AuthScreen();
      },
    );
  }
}
