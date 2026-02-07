import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noteapp/core/utils/datetime_helper.dart';
import 'package:noteapp/data/models/diary_entry_model.dart';
import 'package:noteapp/presentation/providers/app_providers.dart';
import 'package:noteapp/presentation/providers/diary_providers.dart';
import 'package:noteapp/presentation/screens/diary_entry_screen.dart';
import 'package:noteapp/presentation/screens/entry_detail_screen.dart';
import 'package:noteapp/presentation/screens/settings_screen.dart';
import 'package:noteapp/presentation/screens/search_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 3, 59, 143),
        title: const Text(
          'Digital Diary',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        titleTextStyle: const TextStyle(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Row(
        children: [
          // Desktop Sidebar
          if (!isMobile)
            NavigationRail(
              selectedIndex: _selectedNavIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedNavIndex = index);
              },
              labelType: NavigationRailLabelType.selected,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  selectedIcon: Icon(Icons.home_filled),
                  label: Text('All Entries'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite_outline),
                  selectedIcon: Icon(Icons.favorite),
                  label: Text('Favorites'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
            ),
          // Main Content
          Expanded(child: _buildContent(_selectedNavIndex)),
        ],
      ),
      bottomNavigationBar: isMobile
          ? BottomNavigationBar(
              currentIndex: _selectedNavIndex,
              onTap: (index) => setState(() => _selectedNavIndex = index),
              selectedItemColor: Colors.purple,
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'All'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: 'Favorites',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            )
          : null,

      floatingActionButton: _selectedNavIndex != 2
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DiaryEntryScreen()),
                );
              },
              backgroundColor: const Color.fromARGB(255, 18, 5, 129),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildContent(int index) {
    switch (index) {
      case 0:
        return const _AllEntriesView();
      case 1:
        return const _FavoritesView();
      case 2:
        return const SettingsScreen();
      default:
        return const _AllEntriesView();
    }
  }
}

class _AllEntriesView extends ConsumerWidget {
  const _AllEntriesView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(diaryEntriesProvider);

    return entriesAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/empty_state.png', height: 150),
                const SizedBox(height: 16),
                Text(
                  'No entries yet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start by creating your first diary entry!',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return _EntryCard(
              entry: entry,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EntryDetailScreen(entryId: entry.id),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class _FavoritesView extends ConsumerWidget {
  const _FavoritesView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);

    return favoritesAsync.when(
      data: (favorites) {
        if (favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_outline,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No favorites yet',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final entry = favorites[index];
            return _EntryCard(
              entry: entry,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EntryDetailScreen(entryId: entry.id),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class _EntryCard extends ConsumerWidget {
  final DiaryEntryModel entry;
  final VoidCallback onTap;

  const _EntryCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateTimeHelper.formatDateTime(entry.createdAt),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(entry.mood, style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 8),
                      IconButton(
                        icon: Icon(
                          entry.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_outline,
                          color: entry.isFavorite ? Colors.red : null,
                        ),
                        onPressed: () async {
                          final repository = ref.read(diaryRepositoryProvider);
                          await repository.updateDiaryEntry(
                            entry.copyWith(isFavorite: !entry.isFavorite),
                          );
                          ref.invalidate(diaryEntriesProvider);
                          ref.invalidate(favoritesProvider);
                        },
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                entry.body,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (entry.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: entry.tags
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                          labelStyle: Theme.of(context).textTheme.labelSmall,
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
