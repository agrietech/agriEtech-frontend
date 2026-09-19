import 'dart:io';
import 'package:flutter/foundation.dart';

/// Helper to interface with Windows Camera app and Camera Roll repository
class WindowsCameraHelper {
  /// Check if the current platform is Windows desktop
  static bool get isWindows => !kIsWeb && Platform.isWindows;

  /// Get all possible camera roll and pictures directories where Windows Camera may store photos
  static List<String> getCameraRollCandidatePaths() {
    if (!isWindows) return [];
    final userProfile = Platform.environment['USERPROFILE'] ?? '';
    if (userProfile.isEmpty) return [];

    final candidatePaths = <String>[
      '$userProfile\\OneDrive\\Pictures\\Camera Roll',
      '$userProfile\\Pictures\\Camera Roll',
      '$userProfile\\OneDrive\\Pictures',
      '$userProfile\\Pictures',
    ];

    // Check any other OneDrive variants (e.g. OneDrive - Personal, OneDrive - Work, etc.)
    try {
      final userDir = Directory(userProfile);
      if (userDir.existsSync()) {
        for (final entity in userDir.listSync()) {
          if (entity is Directory) {
            final name =
                entity.path.split(Platform.pathSeparator).last.toLowerCase();
            if (name.contains('onedrive')) {
              candidatePaths.add('${entity.path}\\Pictures\\Camera Roll');
              candidatePaths.add('${entity.path}\\Pictures');
            }
          }
        }
      }
    } catch (_) {}

    final existing = <String>{};
    for (final p in candidatePaths) {
      if (Directory(p).existsSync()) {
        existing.add(p);
      }
    }
    return existing.toList();
  }

  /// Get recent photos taken with the camera or stored in Pictures
  static List<File> getRecentPhotos({int limit = 8}) {
    if (!isWindows) return [];
    final dirs = getCameraRollCandidatePaths();
    if (dirs.isEmpty) return [];

    final fileMap = <String, File>{};

    for (final dirPath in dirs) {
      try {
        final dir = Directory(dirPath);
        if (!dir.existsSync()) continue;

        final entries = dir.listSync().whereType<File>();
        for (final f in entries) {
          final path = f.path.toLowerCase();
          if (path.endsWith('.jpg') ||
              path.endsWith('.jpeg') ||
              path.endsWith('.png') ||
              path.endsWith('.webp')) {
            fileMap[f.path] = f;
          }
        }
      } catch (_) {}
    }

    final files = fileMap.values.toList();
    files.sort((a, b) {
      try {
        return b.lastModifiedSync().compareTo(a.lastModifiedSync());
      } catch (_) {
        return 0;
      }
    });

    return files.take(limit).toList();
  }

  /// Launch Windows native Camera app and monitor Camera Roll for captured photo
  static Future<File?> capturePhotoFromWindowsCamera({
    Duration timeout = const Duration(seconds: 60),
    void Function(String status)? onStatus,
  }) async {
    if (!isWindows) return null;

    final candidateDirs = getCameraRollCandidatePaths();
    if (candidateDirs.isEmpty) {
      onStatus?.call('Camera Roll folder not found.');
      return null;
    }

    // Baseline: record all existing file paths and their modification times
    final baselineFiles = <String, DateTime>{};
    for (final dirPath in candidateDirs) {
      try {
        final dir = Directory(dirPath);
        if (dir.existsSync()) {
          for (final entity in dir.listSync()) {
            if (entity is File) {
              try {
                baselineFiles[entity.path] = entity.lastModifiedSync();
              } catch (_) {
                baselineFiles[entity.path] =
                    DateTime.fromMillisecondsSinceEpoch(0);
              }
            }
          }
        }
      } catch (_) {}
    }

    onStatus?.call('Opening Windows Camera (HP Wide Vision)...');

    // Launch official Microsoft Windows Camera protocol
    try {
      await Process.run('cmd', ['/c', 'start', 'microsoft.windows.camera:']);
    } catch (e) {
      debugPrint('Failed to launch Windows Camera protocol: $e');
      onStatus?.call('Could not launch Windows Camera: $e');
      return null;
    }

    onStatus?.call('Camera ready! Snap your photo in the Camera window.');

    final startTime = DateTime.now();
    const pollInterval = Duration(milliseconds: 350);

    while (DateTime.now().difference(startTime) < timeout) {
      await Future.delayed(pollInterval);

      for (final dirPath in candidateDirs) {
        try {
          final dir = Directory(dirPath);
          if (!dir.existsSync()) continue;

          final files = dir.listSync().whereType<File>();
          for (final f in files) {
            final path = f.path.toLowerCase();
            final isImage = path.endsWith('.jpg') ||
                path.endsWith('.jpeg') ||
                path.endsWith('.png') ||
                path.endsWith('.webp');

            if (!isImage) continue;

            final isNew = !baselineFiles.containsKey(f.path);
            DateTime? lastMod;
            try {
              lastMod = f.lastModifiedSync();
            } catch (_) {}

            final isModifiedSinceStart = lastMod != null &&
                (lastMod.isAfter(startTime.subtract(const Duration(seconds: 2))) ||
                    (baselineFiles.containsKey(f.path) &&
                        lastMod.isAfter(baselineFiles[f.path]!)));

            if (isNew || isModifiedSinceStart) {
              // Windows camera may still be flushing the buffer; wait a moment
              await Future.delayed(const Duration(milliseconds: 300));
              try {
                if (f.existsSync() && f.lengthSync() > 1024) {
                  onStatus?.call('Photo captured successfully!');
                  return f;
                }
              } catch (_) {}
            }
          }
        } catch (_) {}
      }
    }

    onStatus?.call('Camera capture timed out or no new photo snapped.');
    return null;
  }
}
