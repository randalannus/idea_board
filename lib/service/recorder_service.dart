import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:idea_board/model/user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RecorderService with ChangeNotifier {
  final User user;
  final _recorder = FlutterSoundRecorder();
  final _storage = FirebaseStorage.instance;

  RecordingStatus _status = RecordingStatus.stopped;
  String? _recordingId;

  RecorderService({required this.user});

  RecordingStatus get status => _status;

  final _micDecibelsController = StreamController<double>.broadcast();
  StreamSubscription? _recorderDecibelsListener;
  Stream<double> get micDecibelsStream => _micDecibelsController.stream;

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
    _recorderDecibelsListener?.cancel();
    _micDecibelsController.close();
  }

  Future<void> startRecording() async {
    PermissionStatus status = await Permission.microphone.status;

    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }

    if (status.isDenied) {
      throw MicrophonePermissionError();
    }

    _recordingId = const Uuid().v4();

    await _recorder.openRecorder();
    await _recorder.startRecorder(
      toFile: await _getLocalPath(_recordingId!),
      codec: Codec.aacMP4,
    );
    _setStatus(RecordingStatus.recording);

    _recorder.setSubscriptionDuration(const Duration(milliseconds: 20));
    _recorderDecibelsListener = _recorder.onProgress!.listen((event) {
      _micDecibelsController.add(event.decibels ?? 0);
    });
  }

  Future<void> pauseRecording() async {
    if (status != RecordingStatus.recording) {
      throw NotRecordingError();
    }
    await _recorder.pauseRecorder();
    _micDecibelsController.add(0);
    _setStatus(RecordingStatus.paused);
  }

  Future<void> resumeRecording() async {
    if (status == RecordingStatus.stopped) {
      throw NotRecordingError();
    } else if (status == RecordingStatus.recording) {
      return;
    }
    await _recorder.resumeRecorder();
    _setStatus(RecordingStatus.recording);
  }

  Future<void> stopRecording() async {
    if (status == RecordingStatus.stopped) {
      throw NotRecordingError();
    }
    await _recorder.stopRecorder();
    _micDecibelsController.add(0);
    _setStatus(RecordingStatus.stopped);
    await _recorder.closeRecorder();
    await _recorderDecibelsListener?.cancel();
  }

  Future<void> uploadRecording(String ideaId) async {
    final localPath = await _getLocalPath(_recordingId!);
    final file = File(localPath);
    await _storage
        .ref(
            "users/${user.uid}/ideas/$ideaId/voiceRecordings/$_recordingId.mp4")
        .putFile(file)
        .whenComplete(() async => await file.delete());
  }

  void _setStatus(RecordingStatus status) {
    _status = status;
    notifyListeners();
  }

  Future<String> _getLocalPath(String uid) async {
    final directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/$_recordingId.mp4";
  }
}

enum RecordingStatus {
  recording,
  paused,
  stopped;
}

class MicrophonePermissionError extends Error {}

class NotRecordingError extends Error {}
