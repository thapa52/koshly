import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';

/// Entry point of the Koshly app.
/// Handles all initialization before the app starts.
void main() async {
  // ─── Ensure Flutter binding is initialized ──────────
  // Must be called before any async operations
  WidgetsFlutterBinding.ensureInitialized();

  // ─── Load environment variables ─────────────────────
  await dotenv.load(fileName: '.env');

  // ─── Initialize Hive ────────────────────────────────
  await Hive.initFlutter();

  // ─── Run the app ────────────────────────────────────
  // ProviderScope is required for Riverpod to work.
  // It must wrap the entire app.
  runApp(ProviderScope(child: KoshlyApp()));
}
