import 'dart:io';
import 'package:flutter/material.dart';

class FullScreenImageView extends StatelessWidget {
  final String imagePath;

  const FullScreenImageView({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: InteractiveViewer(
            child: Image(image: _getImageProvider(imagePath)),
          ),
        ),
      ),
    );
  }

  ImageProvider _getImageProvider(String imagePath) {
    try {
      if (imagePath.startsWith('data:') || imagePath.startsWith('blob:')) {
        return NetworkImage(imagePath);
      }
      return FileImage(File(imagePath));
    } catch (e) {
      return const AssetImage('assets/placeholder.png');
    }
  }
}

class ImageGridView extends StatelessWidget {
  final List<String> imagePaths;
  final Function(int)? onRemove;
  final bool isEditable;

  const ImageGridView({
    super.key,
    required this.imagePaths,
    this.onRemove,
    this.isEditable = false,
  });

  ImageProvider _getImageProvider(String imagePath) {
    try {
      if (imagePath.startsWith('data:') || imagePath.startsWith('blob:')) {
        return NetworkImage(imagePath);
      }
      return FileImage(File(imagePath));
    } catch (e) {
      return const AssetImage('assets/placeholder.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (imagePaths.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Images',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: imagePaths.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) =>
                      FullScreenImageView(imagePath: imagePaths[index]),
                );
              },
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: _getImageProvider(imagePaths[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (isEditable && onRemove != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => onRemove!(index),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withAlpha(128),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
