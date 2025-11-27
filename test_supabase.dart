import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jenjelfbnpkxeevgmfjs.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImplbmplbGZibnBreGVldmdtZmpzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIwMzc0NzYsImV4cCI6MjA3NzYxMzQ3Nn0.RNyuDvvd_hr3kJUYzCetsvIC-VNhIZNdbdyPi5gsQ68',
  );

  final supabase = Supabase.instance.client;

  try {
    print('Conectando a Supabase...');
    final response = await supabase.from('products').select();
    print('Productos obtenidos: $response');
    print('Cantidad: ${(response as List).length}');
  } catch (e) {
    print('Error: $e');
  }
}
