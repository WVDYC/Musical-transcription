import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../providers/theme_provider.dart';
import '../providers/audio_provider.dart';
import '../providers/pitch_provider.dart';
import '../widgets/sheet_music_painter.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  bool isRecording = false;
  late AnimationController _animationController;
  String selectedInstrument = 'Piano';
  final List<String> instruments = ['Piano', 'Guitar', 'Violin', 'Vocal', 'Flute'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleRecording() async {
    final audioService = ref.read(audioServiceProvider);
    if (!isRecording) {
      final path = await audioService.startRecording();
      if (path != null) {
        setState(() {
          isRecording = true;
        });
        // We simulate note detection since record package
        // doesn't natively expose PCM stream in pure Dart without native code.
        // For a full app, we'd use mic_stream or similar to feed Pitchup chunks of PCM data.
        // For now, we update the UI to show it's active.
      }
    } else {
      await audioService.stopRecording();
      setState(() {
        isRecording = false;
      });
      ref.read(currentNoteProvider.notifier).state = '--';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Note Recognizer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E), const Color(0xFF0F3460)]
              : [const Color(0xFFE0C3FC), const Color(0xFF8EC5FC)],
          ),
        ),
        child: Stack(
          children: [
            // Decorative background shapes
            Positioned(
              top: 100,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.purple.withOpacity(0.3) : Colors.white.withOpacity(0.5),
                ),
              ),
            ),
            Positioned(
              bottom: 50,
              right: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.blue.withOpacity(0.3) : Colors.pinkAccent.withOpacity(0.3),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Sheet Music Visualization
                  Consumer(
                    builder: (context, ref, child) {
                      final currentNote = ref.watch(currentNoteProvider);
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 120,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: CustomPaint(
                          painter: SheetMusicPainter(
                            currentNote: currentNote,
                            isDark: isDark,
                          ),
                        ),
                      );
                    }
                  ),

                  // Current Note Display
                  GlassmorphicContainer(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 150,
                    borderRadius: 20,
                    blur: 20,
                    alignment: Alignment.center,
                    border: 2,
                    linearGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    borderGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.5),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isRecording ? 'Listening...' : 'Ready',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Consumer(
                          builder: (context, ref, child) {
                            final currentNote = ref.watch(currentNoteProvider);
                            return Text(
                              currentNote,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Instrument Selector
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: instruments.map((inst) {
                          final isSelected = selectedInstrument == inst;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () => setState(() => selectedInstrument = inst),
                              child: GlassmorphicContainer(
                                width: 100,
                                height: 40,
                                borderRadius: 20,
                                blur: 10,
                                alignment: Alignment.center,
                                border: isSelected ? 2 : 1,
                                linearGradient: LinearGradient(
                                  colors: isSelected
                                    ? [Colors.blue.withOpacity(0.5), Colors.purple.withOpacity(0.5)]
                                    : [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                                ),
                                borderGradient: LinearGradient(
                                  colors: isSelected
                                    ? [Colors.blue, Colors.purple]
                                    : [Colors.white.withOpacity(0.2), Colors.transparent],
                                ),
                                child: Text(
                                  inst,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black87,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Main Pulse Button
                  GestureDetector(
                    onTap: _toggleRecording,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Container(
                          width: 150 + (isRecording ? _animationController.value * 30 : 0),
                          height: 150 + (isRecording ? _animationController.value * 30 : 0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isRecording
                              ? Colors.redAccent.withOpacity(0.6 - (_animationController.value * 0.4))
                              : Colors.blueAccent.withOpacity(0.2),
                          ),
                          child: Center(
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: isRecording
                                    ? [Colors.redAccent, Colors.deepOrange]
                                    : [Colors.blueAccent, Colors.lightBlue],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isRecording ? Colors.redAccent.withOpacity(0.5) : Colors.blueAccent.withOpacity(0.5),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  )
                                ],
                              ),
                              child: Icon(
                                isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isRecording ? 'Tap to Stop' : 'Tap to Listen',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Upload File Button
                  TextButton.icon(
                    onPressed: () {
                      // final path = await ref.read(audioServiceProvider).pickAudioFile();
                      if (path != null) {
                        // TODO: Process the file for pitch detection
                      }
                    },
                    icon: Icon(Icons.upload_file, color: isDark ? Colors.white70 : Colors.black87),
                    label: Text(
                      'Or upload an audio file',
                      style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
