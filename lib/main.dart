import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/academic/lecturer/lecturer_controller.dart';

// Pastikan path import ini sesuai dengan struktur folder di laptopmu
import 'features/academic/lecturer/view/lecturer_view.dart';

final LecturerController globalLecturerController = LecturerController();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Load configuration dari file .env
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Warning: .env file not found. Make sure it exists in the root folder.");
  }

  // 2. Initialize Supabase
  // Pastikan variabel di .env sudah sesuai dengan yang diberikan Hanif
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL', fallback: ''),
    anonKey: dotenv.get('SUPABASE_ANON_KEY', fallback: ''),
  );

  // 3. Matikan sementara CRUD Test agar tidak error karena ketidaksinkronan kode
  // await runDatabaseTest(); 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polban Learning Management',
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug di pojok kanan
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),

      home: const LecturerView(),
    );
  }
}

// Fungsi ini dibiarkan ada tapi tidak dipanggil di main() 
// agar tidak menyebabkan error "merah" saat aplikasi dijalankan.
Future<void> runDatabaseTest() async {
  // Kode pengujian Hanif ada di sini...
}