import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  // We need to load dotenv manually
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

  final client = SupabaseClient(url, key);

  try {
    final response = await client.from('workspaces').select().limit(1);
    print('Workspaces columns:');
    if ((response as List).isNotEmpty) {
      print((response[0] as Map<String, dynamic>).keys.toList());
    } else {
      print('Table is empty, but query succeeded.');
    }
  } catch (e) {
    print('Error: $e');
  }
}
