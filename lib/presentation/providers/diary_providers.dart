import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noteapp/data/models/diary_entry_model.dart';
import 'package:noteapp/presentation/providers/app_providers.dart';

// All Diary Entries
final diaryEntriesProvider = FutureProvider<List<DiaryEntryModel>>((ref) async {
  final repository = ref.watch(diaryRepositoryProvider);
  return repository.getAllDiaryEntries();
});

// Favorite Entries
final favoritesProvider = FutureProvider<List<DiaryEntryModel>>((ref) async {
  final repository = ref.watch(diaryRepositoryProvider);
  return repository.getFavoriteDiaryEntries();
});

// Search Entries
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<DiaryEntryModel>>((
  ref,
) async {
  final query = ref.watch(searchQueryProvider);
  final repository = ref.watch(diaryRepositoryProvider);

  if (query.isEmpty) {
    return [];
  }

  return repository.searchDiaryEntries(query);
});

// Single Entry
final selectedEntryIdProvider = StateProvider<String?>((ref) => null);

final selectedEntryProvider = FutureProvider<DiaryEntryModel?>((ref) async {
  final entryId = ref.watch(selectedEntryIdProvider);
  if (entryId == null) return null;

  final repository = ref.watch(diaryRepositoryProvider);
  return repository.getDiaryEntry(entryId);
});

// Entries Count
final entriesCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(diaryRepositoryProvider);
  return repository.getTotalEntriesCount();
});

// Filter Provider
final entryFilterProvider = StateProvider<EntryFilter>((ref) {
  return EntryFilter.all;
});

enum EntryFilter { all, today, thisWeek, thisMonth, favorites }
