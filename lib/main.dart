import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vittaonline/app.dart';
import 'package:vittaonline/config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize localization
  await initializeDateFormatting('pt_BR', null);
  
  // Initialize Supabase
  SupabaseConfig.validate();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(
    const ProviderScope(
      child: VittaOnlineApp(),
    ),
  );
}
