import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noteapp/core/utils/datetime_helper.dart';
import 'package:noteapp/data/services/export_service.dart';
import 'package:noteapp/presentation/providers/app_providers.dart';
import 'package:noteapp/presentation/providers/diary_providers.dart';
import 'package:noteapp/presentation/screens/diary_entry_screen.dart';
import 'package:noteapp/presentation/widgets/image_grid_view.dart';

class EntryDetailScreen extends ConsumerStatefulWidget {
  final String entryId;

  const EntryDetailScreen({super.key, required this.entryId});

  @override
  ConsumerState<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends ConsumerState<EntryDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Set the selected entry ID when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedEntryIdProvider.notifier).state = widget.entryId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final entryAsync = ref.watch(selectedEntryProvider);

    return entryAsync.when(
      data: (entry) {
        if (entry == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Entry not found')),
            body: const Center(child: Text('Entry not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DiaryEntryScreen(entryId: widget.entryId),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  _showMoreOptions(context, ref, entry);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    entry.title,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateTimeHelper.formatDateTime(entry.createdAt),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Text(entry.mood, style: const TextStyle(fontSize: 28)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Body
                  SelectableText(
                    entry.body,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),

                  // Tags
                  if (entry.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      children: entry.tags
                          .map((tag) => Chip(label: Text(tag)))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Images
                  if (entry.imagePaths.isNotEmpty)
                    ImageGridView(imagePaths: entry.imagePaths),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  void _showMoreOptions(BuildContext context, WidgetRef ref, dynamic entry) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export as JSON'),
            onTap: () async {
              Navigator.pop(context);
              try {
                final repository = ref.read(diaryRepositoryProvider);
                final entries = await repository.getAllDiaryEntries();
                await ExportService.exportAsJSON(entries);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Exported to Documents folder'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('Export as PDF'),
            onTap: () async {
              Navigator.pop(context);
              try {
                final repository = ref.read(diaryRepositoryProvider);
                final entries = await repository.getAllDiaryEntries();
                await ExportService.exportAsPDF(entries);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Exported to Documents folder'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              'Delete Entry',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              Navigator.pop(context);
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Entry?'),
                  content: const Text('This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                try {
                  final repository = ref.read(diaryRepositoryProvider);
                  await repository.deleteDiaryEntry(widget.entryId);
                  ref.invalidate(diaryEntriesProvider);
                  ref.invalidate(favoritesProvider);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
