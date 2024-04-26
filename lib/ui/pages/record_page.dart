import 'package:flutter/material.dart';
import 'package:idea_board/model/user.dart';
import 'package:idea_board/service/ideas_service.dart';
import 'package:idea_board/service/recorder_service.dart';
import 'package:provider/provider.dart';

class RecordPage extends StatelessWidget {
  const RecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: ChangeNotifierProvider(
        create: (context) {
          final user = Provider.of<User>(context, listen: false);
          return RecorderService(user: user);
        },
        child: Consumer<RecorderService>(
          builder: (context, recorderService, _) => Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: constraints.maxHeight / 10,
                      child: Icon(
                        Icons.mic,
                        size: 40,
                        color:
                            recorderService.status == RecordingStatus.recording
                                ? theme.colorScheme.onBackground
                                : theme.colorScheme.primary,
                      ),
                    ),
                    Center(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          textStyle: theme.textTheme.titleLarge!.copyWith(
                            color: recorderService.status ==
                                    RecordingStatus.recording
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onPrimaryContainer,
                          ),
                          minimumSize: const Size.fromRadius(150),
                          backgroundColor: recorderService.status ==
                                  RecordingStatus.recording
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primaryContainer,
                          shape: const CircleBorder(
                            eccentricity: 0,
                          ),
                        ),
                        onPressed: () async {
                          final ideasService =
                              Provider.of<IdeasService>(context, listen: false);
                          if (recorderService.status ==
                              RecordingStatus.recording) {
                            await recorderService.stopRecording();
                            final idea = await ideasService.newIdea(
                              isProcessingAudio: true,
                            );
                            await recorderService.uploadRecording(idea.id);
                            return;
                          }
                          await recorderService.startRecording();
                        },
                        child: Text(
                          "Start recording",
                          style: theme.textTheme.titleLarge!.copyWith(
                              color: theme.colorScheme.onPrimaryContainer),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
