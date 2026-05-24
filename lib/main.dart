import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Note Recognizer',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.grey[100],
        colorScheme: const ColorScheme.light(
          primary: Colors.blueAccent,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurpleAccent,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),
      home: const HomeScreen(),
    );
  }
}
