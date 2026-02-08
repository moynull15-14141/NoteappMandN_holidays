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
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  File? _videoFile;

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

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      final videoFile = File(pickedFile.path);
      // Validate video size (2 GB limit)
      final videoSize = await videoFile.length();
      if (videoSize <= 2 * 1024 * 1024 * 1024) {
        setState(() {
          _videoFile = videoFile;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video selected: ${videoFile.path}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video size exceeds 2 GB limit.')),
        );
      }
    }
  }

  Future<void> _openVideo() async {
    if (_videoFile != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Video will be saved with your diary entry')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entryId != null ? 'Edit Entry' : 'New Entry'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.transparent
                    : Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _isLoading ? null : _saveEntry,
              child: Text(
                'Save',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Input Field
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Give your entry a title...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Date and Time Display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateTimeHelper.formatDate(_selectedDate),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  _selectedTime.format(context),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mood Selector
            Text(
              'How are you feeling today?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            MoodSelector(
              selectedMood: _selectedMood,
              onMoodSelected: (mood) {
                setState(() => _selectedMood = mood);
              },
            ),
            const SizedBox(height: 16),

            // Text Area for Thoughts
            TextField(
              controller: _bodyController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Write your thoughts, memories or reflections...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Tags Input
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Add tags (comma separated)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Photo Upload Section
            GestureDetector(
              onTap: _addImage,
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.05),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Click to add photos',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Video Upload Section
            ElevatedButton.icon(
              onPressed: _pickVideo,
              icon: const Icon(Icons.video_library),
              label: const Text('Upload Video'),
            ),
            if (_videoFile != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Video Selected:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _videoFile!.path.split('/').last,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _openVideo,
                          icon: const Icon(Icons.play_circle_fill, size: 20),
                          label: const Text('Open Video'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Display Selected Images
            if (_imagePaths.isNotEmpty)
              ImageGridView(
                imagePaths: _imagePaths,
                onRemove: (path) {
                  setState(() => _imagePaths.remove(path));
                },
              ),
          ],
        ),
      ),
    );
  }
}
