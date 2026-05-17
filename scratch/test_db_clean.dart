import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final envFile = File('.env');
  if (!await envFile.exists()) {
    print('No .env file found');
    return;
  }
  
  final lines = await envFile.readAsLines();
  String url = '';
  String key = '';
  
  for (var line in lines) {
    if (line.startsWith('SUPABASE_URL=')) url = line.split('=')[1].trim();
    if (line.startsWith('SUPABASE_ANON_KEY=')) key = line.split('=')[1].trim();
  }

  // Remove quotes if any
  url = url.replaceAll('"', '').replaceAll("'", '');
  key = key.replaceAll('"', '').replaceAll("'", '');

  print('URL: $url');
  
  final client = SupabaseClient(url, key);

  try {
    final response = await client.from('projects').select();
    print('Projects data:');
    print(response);
  } catch (e) {
    print('Error: $e');
  }
}
