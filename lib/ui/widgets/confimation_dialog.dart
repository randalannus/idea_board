import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  /// Title of the dialog window
  final String title;

  /// Text that is shown in the body of the dialog
  final String content;

  /// Text on the button that corresponds to confirming the action.
  /// The cancel button always has the text "Cancel".
  final String confirmButton;

  const ConfirmationDialog({
    required this.title,
    required this.content,
    required this.confirmButton,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmButton),
        ),
        const SizedBox(width: 8)
      ],
    );
  }
}

/// Show a dialog like [showDialog].
///
/// Returns [true] if the user chooses the confirm option and [false] if they
/// choose cancel or navigate out of the dialog.
Future<bool> showConfirmationDialog({
  required BuildContext context,
  required ConfirmationDialog dialog,
}) async {
  bool? userAccepted = await showDialog<bool>(
    context: context,
    builder: (context) => dialog,
  );
  return userAccepted ?? false;
}
