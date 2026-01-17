// [1] VERSION: 1.0.0 - Category Repository
// UI segment: n/a
// BACKEND segment: Supabase CRUD

import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/category_model.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final supabase = ref.read(supabaseServiceProvider);
  return CategoryRepository(supabase.client);
});

class CategoryRepository {
  final SupabaseClient _client;

  CategoryRepository(this._client);

  // 1. Fetch Categories (Ordered by position)
  Future<List<Category>> fetchCategories() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      final data = await _client
          .from('categories')
          .select()
          .eq('user_id', user.id)
          .order('position_index', ascending: true);

      return (data as List).map((e) => Category.fromMap(e)).toList();
    } catch (e) {
      log('Error fetching categories: $e');
      rethrow;
    }
  }

  // 2. Add New Category
  Future<Category> addCategory(String name, String colorHex, int position) async {
    final user = _client.auth.currentUser;
    if (user == null) throw 'User not logged in';

    final res = await _client.from('categories').insert({
      'user_id': user.id,
      'name': name,
      'color_hex': colorHex,
      'position_index': position,
    }).select().single();

    return Category.fromMap(res);
  }
}