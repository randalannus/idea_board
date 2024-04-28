import 'dart:math';

import 'package:flutter/material.dart';
import 'package:idea_board/model/user.dart';
import 'package:idea_board/service/recorder_service.dart';
import 'package:idea_board/ui/widgets/confimation_dialog.dart';
import 'package:provider/provider.dart';

class RecordingPage extends StatelessWidget {
  final String ideaId;

  const RecordingPage({required this.ideaId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (context) {
          final user = Provider.of<User>(context, listen: false);
          return RecorderService(user: user);
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: constraints.maxHeight / 8,
                  child: const MicIcon(),
                ),
                Positioned(
                  top: constraints.maxHeight / 3.7,
                  child: const RecordingButton(),
                ),
                Positioned(
                  bottom: constraints.maxHeight / 9,
                  width: constraints.maxWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const CancelButton(),
                      SaveButton(ideaId: ideaId),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class MicIcon extends StatelessWidget {
  const MicIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final recorderService =
        Provider.of<RecorderService>(context, listen: false);
    return StreamBuilder<double>(
      stream: recorderService.micDecibelsStream,
      initialData: 0,
      builder: (context, snapshot) {
        final dB = (snapshot.data ?? 0);
        final volume = min(max(0, (dB - 30) / 40), 1).toDouble();
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [colorScheme.primary, colorScheme.onBackground],
              stops: [volume, volume],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Icon(
            Icons.mic,
            size: 48,
            color: colorScheme.onBackground,
          ),
        );
      },
    );
  }
}

class RecordingButton extends StatelessWidget {
  const RecordingButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<RecorderService>(
      builder: (context, recorderService, _) => TextButton(
        style: TextButton.styleFrom(
          minimumSize: const Size.fromRadius(150),
          backgroundColor: recorderService.status == RecordingStatus.recording
              ? theme.colorScheme.primary
              : theme.colorScheme.primaryContainer,
          shape: const CircleBorder(
            eccentricity: 0,
          ),
        ),
        onPressed: () => _onPressed(recorderService),
        child: Text(
          _buttonText(recorderService.status),
          style: theme.textTheme.titleLarge!.copyWith(
            color: recorderService.status == RecordingStatus.recording
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }

  Future<void> _onPressed(RecorderService recorderService) async {
    final status = recorderService.status;
    if (status == RecordingStatus.stopped) {
      await recorderService.startRecording();
      return;
    }
    if (status == RecordingStatus.paused) {
      await recorderService.resumeRecording();
      return;
    }
    if (status == RecordingStatus.recording) {
      await recorderService.pauseRecording();
      return;
    }
  }

  String _buttonText(RecordingStatus status) {
    if (status == RecordingStatus.stopped) return "Start recording";
    if (status == RecordingStatus.paused) return "Resume recording";
    return "Pause recording";
  }
}

class SaveButton extends StatelessWidget {
  final String ideaId;

  const SaveButton({required this.ideaId, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecorderService>(builder: (context, recorderService, _) {
      final theme = Theme.of(context);
      return IconButton.filled(
        icon: const Icon(
          Icons.done,
          size: 50,
        ),
        style: IconButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          //shape: CircleBorder(Bord),
        ),
        onPressed: () async {
          Navigator.pop(context);
          if (recorderService.status != RecordingStatus.stopped) {
            await recorderService.stopRecording();
          }
          await recorderService.uploadRecording(ideaId);
        },
      );
    });
  }
}

class CancelButton extends StatefulWidget {
  const CancelButton({super.key});

  @override
  State<CancelButton> createState() => _CancelButtonState();
}

class _CancelButtonState extends State<CancelButton> {
  @override
  Widget build(BuildContext context) {
    return Consumer<RecorderService>(builder: (context, recorderService, _) {
      final theme = Theme.of(context);
      return PopScope(
        canPop: recorderService.status == RecordingStatus.stopped,
        onPopInvoked: (didPop) async {
          if (didPop) return;
          final userAccepted = await _confirmDiscard(context);
          if (!userAccepted || !mounted) return;
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        },
        child: IconButton.filled(
          icon: const Icon(
            Icons.cancel,
            size: 50,
          ),
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          onPressed: () => _onPressed(context, recorderService),
        ),
      );
    });
  }

  Future<void> _onPressed(
      BuildContext context, RecorderService recorderService) async {
    if (recorderService.status != RecordingStatus.stopped) {
      final userAccepted = await _confirmDiscard(context);
      if (!userAccepted) return;
      recorderService.stopRecording();
    }
    if (!mounted) return;
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  Future<bool> _confirmDiscard(BuildContext context) async {
    return await showConfirmationDialog(
      context: context,
      dialog: const ConfirmationDialog(
        title: "Warning",
        content: "Are you sure you want to discard the recording?",
        confirmButton: "Discard",
      ),
    );
  }
}
