import 'package:flutter/material.dart';

class PinInputDialog extends StatefulWidget {
  final String title;
  final String description;
  final String buttonText;
  final Function(String, String)
  onSubmit; // Updated to accept current and new PINs

  const PinInputDialog({
    super.key,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onSubmit,
  });

  @override
  State<PinInputDialog> createState() => _PinInputDialogState();
}

class _PinInputDialogState extends State<PinInputDialog> {
  late TextEditingController _currentPinController;
  late TextEditingController _newPinController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentPinController = TextEditingController();
    _newPinController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.description,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _currentPinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              hintText: 'Enter Current PIN',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              counterText: '',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _newPinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              hintText: 'Enter New PIN',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              counterText: '',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () async {
                  if (_currentPinController.text.isEmpty ||
                      _newPinController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter both current and new PINs'),
                      ),
                    );
                    return;
                  }

                  setState(() => _isLoading = true);
                  await widget.onSubmit(
                    _currentPinController.text,
                    _newPinController.text,
                  );
                  setState(() => _isLoading = false);

                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.buttonText),
        ),
      ],
    );
  }
}
