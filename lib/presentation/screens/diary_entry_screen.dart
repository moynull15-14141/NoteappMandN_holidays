import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noteapp/core/utils/datetime_helper.dart';
import 'package:noteapp/data/models/diary_entry_model.dart';
import 'package:noteapp/data/services/image_service.dart';
import 'package:noteapp/presentation/providers/app_providers.dart';
import 'package:noteapp/presentation/providers/diary_providers.dart';
import 'package:noteapp/presentation/widgets/mood_selector.dart';
import 'package:noteapp/presentation/widgets/image_grid_view.dart';
import 'package:uuid/uuid.dart';

class DiaryEntryScreen extends ConsumerStatefulWidget {
  final String? entryId;

  const DiaryEntryScreen({super.key, this.entryId});

  @override
  ConsumerState<DiaryEntryScreen> createState() => _DiaryEntryScreenState();
}

class _DiaryEntryScreenState extends ConsumerState<DiaryEntryScreen> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late TextEditingController _tagsController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  String _selectedMood = '😊';
  List<String> _imagePaths = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
    _tagsController = TextEditingController();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _loadEntryIfExists();
  }

  void _loadEntryIfExists() async {
    if (widget.entryId != null) {
      final repository = ref.read(diaryRepositoryProvider);
      final entry = await repository.getDiaryEntry(widget.entryId!);
      if (entry != null) {
        _titleController.text = entry.title;
        _bodyController.text = entry.body;
        _tagsController.text = entry.tags.join(', ');
        _selectedMood = entry.mood;
        _imagePaths = entry.imagePaths;
        _selectedDate = entry.createdAt;
        _selectedTime = TimeOfDay.fromDateTime(entry.createdAt);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(diaryRepositoryProvider);
      final createdAt = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      DiaryEntryModel entry;
      if (widget.entryId != null) {
        final existingEntry = await repository.getDiaryEntry(widget.entryId!);
        entry = existingEntry!.copyWith(
          title: _titleController.text,
          body: _bodyController.text,
          updatedAt: DateTime.now(),
          mood: _selectedMood,
          imagePaths: _imagePaths,
          tags: tags,
        );
        await repository.updateDiaryEntry(entry);
      } else {
        entry = DiaryEntryModel(
          id: const Uuid().v4(),
          title: _titleController.text,
          body: _bodyController.text,
          createdAt: createdAt,
          updatedAt: DateTime.now(),
          mood: _selectedMood,
          imagePaths: _imagePaths,
          isFavorite: false,
          tags: tags,
        );
        await repository.saveDiaryEntry(entry);
      }

      // Invalidate providers to refresh the list
      ref.invalidate(diaryEntriesProvider);
      ref.invalidate(favoritesProvider);
      ref.invalidate(entriesCountProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.entryId != null
                  ? 'Entry updated successfully'
                  : 'Entry saved successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving entry: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addImage() async {
    try {
      final imagePath = await ImageService.pickImage();
      if (imagePath != null) {
        setState(() {
          if (_imagePaths.length < 5) {
            _imagePaths.add(imagePath);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Maximum 5 images allowed'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entryId != null ? 'Edit Entry' : 'New Entry'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _saveEntry,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Title',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: Theme.of(context).textTheme.headlineMedium,
                maxLines: 1,
              ),
              const SizedBox(height: 8),
              Text(
                DateTimeHelper.formatDate(_selectedDate),
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 24),

              // Date & Time
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _selectedDate = date);
                        }
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateTimeHelper.formatDate(_selectedDate),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                        );
                        if (time != null) {
                          setState(() => _selectedTime = time);
                        }
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Time',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateTimeHelper.formatTime(
                                  DateTime(
                                    2000,
                                    1,
                                    1,
                                    _selectedTime.hour,
                                    _selectedTime.minute,
                                  ),
                                ),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Mood Selector
              MoodSelector(
                selectedMood: _selectedMood,
                onMoodSelected: (mood) {
                  setState(() => _selectedMood = mood);
                },
              ),
              const SizedBox(height: 24),

              // Body
              TextField(
                controller: _bodyController,
                decoration: InputDecoration(
                  hintText: 'Write your thoughts...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                minLines: 10,
                maxLines: null,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),

              // Tags
              TextField(
                controller: _tagsController,
                decoration: InputDecoration(
                  hintText: 'Add tags (comma separated)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Images
              if (_imagePaths.isNotEmpty)
                ImageGridView(
                  imagePaths: _imagePaths,
                  isEditable: true,
                  onRemove: (index) {
                    setState(() {
                      _imagePaths.removeAt(index);
                    });
                  },
                ),
              if (_imagePaths.isNotEmpty) const SizedBox(height: 12),

              // Add Image Button
              OutlinedButton.icon(
                onPressed: _addImage,
                icon: const Icon(Icons.image),
                label: const Text('Add Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
