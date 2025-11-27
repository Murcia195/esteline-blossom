import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient supabase;

  SupabaseService({required this.supabase});

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final response = await supabase.from('products').select();
    return List<Map<String, dynamic>>.from(response as List);
  }
}
