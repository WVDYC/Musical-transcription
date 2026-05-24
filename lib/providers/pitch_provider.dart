import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/pitch_service.dart';

final pitchServiceProvider = Provider<PitchService>((ref) {
  return PitchService();
});

final currentNoteProvider = StateProvider<String>((ref) => '--');
