import 'package:flutter/material.dart';
import 'package:idea_board/model/user.dart';
import 'package:idea_board/service/ideas_service.dart';
import 'package:idea_board/service/recorder_service.dart';
import 'package:provider/provider.dart';

class RecordingPage extends StatelessWidget {
  const RecordingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
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
                  top: constraints.maxHeight / 10,
                  child: const MicIcon(),
                ),
                const Center(
                  child: RecordingButton(),
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
    final theme = Theme.of(context);
    return Consumer<RecorderService>(
      builder: (context, recorderService, _) => Icon(
        Icons.mic,
        size: 40,
        color: recorderService.status == RecordingStatus.recording
            ? theme.colorScheme.onBackground
            : theme.colorScheme.primary,
      ),
    );
  }
}

class RecordingButton extends StatefulWidget {
  const RecordingButton({super.key});

  @override
  State<RecordingButton> createState() => _RecordingButtonState();
}

class _RecordingButtonState extends State<RecordingButton> {
  late final String ideaId;

  @override
  void initState() {
    Provider.of<IdeasService>(context, listen: false)
        .newIdea(isProcessingAudio: false)
        .then((idea) => ideaId = idea.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<RecorderService>(
      builder: (context, recorderService, _) => TextButton(
        style: TextButton.styleFrom(
          textStyle: theme.textTheme.titleLarge!.copyWith(
            color: recorderService.status == RecordingStatus.recording
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onPrimaryContainer,
          ),
          minimumSize: const Size.fromRadius(150),
          backgroundColor: recorderService.status == RecordingStatus.recording
              ? theme.colorScheme.primary
              : theme.colorScheme.primaryContainer,
          shape: const CircleBorder(
            eccentricity: 0,
          ),
        ),
        onPressed: () async {
          if (recorderService.status == RecordingStatus.recording) {
            await recorderService.stopRecording();
            await recorderService.uploadRecording(ideaId);
            return;
          }
          await recorderService.startRecording();
        },
        child: Text(
          recorderService.status == RecordingStatus.recording
              ? "Stop recording"
              : "Start recording",
          style: theme.textTheme.titleLarge!
              .copyWith(color: theme.colorScheme.onPrimaryContainer),
        ),
      ),
    );
  }
}
