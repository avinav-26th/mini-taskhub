// [1] VERSION: 1.0.0 - Category Controller
// UI segment: State Management

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/category_repository.dart';
import '../../domain/category_model.dart';

final categoryListProvider = StateNotifierProvider<CategoryController, AsyncValue<List<Category>>>((ref) {
  final repo = ref.read(categoryRepositoryProvider);
  return CategoryController(repo);
});

class CategoryController extends StateNotifier<AsyncValue<List<Category>>> {
  final CategoryRepository _repo;

  CategoryController(this._repo) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final categories = await _repo.fetchCategories();
      state = AsyncValue.data(categories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addCategory(String name, String colorHex) async {
    try {
      // Calculate next position
      final currentList = state.value ?? [];
      final nextPos = currentList.length;

      final newCat = await _repo.addCategory(name, colorHex, nextPos);

      // Update UI locally
      state = AsyncValue.data([...currentList, newCat]);
    } catch (e) {
      // Handle error
    }
  }
}