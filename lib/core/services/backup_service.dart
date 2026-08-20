import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';

import '../../data/models/behavior_log.dart';
import '../../data/models/child_profile.dart';
import '../../data/models/sensory_profile_result.dart';
import '../../data/services/hive_service.dart';
import '../i18n/language_controller.dart';
import '../models/schedule_task.dart';
import 'child_photo_service.dart';

enum BackupStatus { success, cancelled, failure }

class BackupResult {
  const BackupResult(this.status, this.message);

  final BackupStatus status;
  final String message;

  bool get isSuccess => status == BackupStatus.success;
  bool get isCancelled => status == BackupStatus.cancelled;
}

/// Kopya ng lahat ng datos sa iisang JSON file na hawak ng magulang.
///
/// Hindi ito cloud sync. Walang internet ang app at hindi ito magkakaroon —
/// ang file ang dala ng magulang, siya ang may hawak nito.
///
/// HINDI kasama ang PIN at ang biometric setting. Maaaring maipadala ang file
/// sa iba (email, chat), kaya hindi dapat may kredensyal sa loob nito.
class BackupService {
  /// Taasan lang kapag hindi na kayang basahin ang lumang file.
  static const int _formatVersion = 1;

  static const String _lastBackupKey = 'last_backup_at';

  static Box<String> get _meta => HiveService.getBackupMetaBox();

  /// `null` kapag wala pang ginagawang kopya.
  static DateTime? lastBackupAt() {
    final raw = _meta.get(_lastBackupKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  static bool get hasBackup => lastBackupAt() != null;

  // ---------------------------------------------------------------- export

  static Future<BackupResult> exportToFile() async {
    try {
      final payload = await buildPayload();
      final bytes = Uint8List.fromList(
        utf8.encode(const JsonEncoder.withIndent('  ').convert(payload)),
      );

      final uri = await FilePicker.saveFile(
        dialogTitle: 'Saan ilalagay ang kopya?',
        fileName: _suggestedFileName(),
        bytes: bytes,
        mimeType: 'application/json',
      );

      if (uri == null) {
        return const BackupResult(BackupStatus.cancelled, '');
      }

      await _meta.put(_lastBackupKey, DateTime.now().toIso8601String());
      return const BackupResult(
        BackupStatus.success,
        'Nailigtas ang kopya ng datos.',
      );
    } catch (_) {
      return const BackupResult(
        BackupStatus.failure,
        'Hindi nagawa ang kopya. Subukan ulit.',
      );
    }
  }

  static String _suggestedFileName() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return 'audhd-kopya-${now.year}-$month-$day.json';
  }

  /// Buong laman ng backup. Hiwalay sa pagsulat ng file para masuri ito
  /// nang walang file picker.
  static Future<Map<String, dynamic>> buildPayload() async {
    final profile = HiveService.getChildProfile();

    String? photoBase64;
    final photoFileName = profile?.photoFileName;
    if (photoFileName != null) {
      final file = ChildPhotoService.fileFor(photoFileName);
      if (file.existsSync()) {
        photoBase64 = base64Encode(await file.readAsBytes());
      }
    }

    return {
      'format': _formatVersion,
      'app': 'AuDHD',
      'createdAt': DateTime.now().toIso8601String(),
      'profile': profile?.toMap(),
      'photoBase64': photoBase64,
      'behaviorLogs': HiveService.getBehaviorBox()
          .values
          .map((log) => log.toJson())
          .toList(),
      'sensoryResults': HiveService.getSensoryBox()
          .values
          .map((result) => result.toJson())
          .toList(),
      'scheduleTasks': HiveService.getScheduleBox()
          .values
          .map((task) => task.toJson())
          .toList(),
      'sensoryCompletion': _dump(HiveService.getCompletionBox()),
      'mood': _dump(HiveService.getMoodBox()),
      'milestones': _dump(HiveService.getMilestoneBox()),
      'settings': _dump(HiveService.getSettingsBox()),
      'scheduleCompletion': _dump(HiveService.getScheduleDoneBox()),
      'rewards': _dump(HiveService.getRewardBox()),
      'guideBookmarks': _dump(HiveService.getGuideBookmarkBox()),
      'guideTips': _dump(HiveService.getGuideTipBox()),
      'scheduleOrder': _dump(HiveService.getScheduleOrderBox()),
      'scheduleHidden': _dump(HiveService.getScheduleHiddenBox()),
      'prefs': _dump(HiveService.getPrefsBox()),
    };
  }

  static Map<String, dynamic> _dump<T>(Box<T> box) {
    final result = <String, dynamic>{};
    for (final key in box.keys) {
      result[key.toString()] = box.get(key);
    }
    return result;
  }

  // ---------------------------------------------------------------- import

  /// Pinapalitan ang kasalukuyang datos ng laman ng file.
  ///
  /// Buo munang binabasa at sinusuri ang file bago galawin ang kahit ano.
  /// Kung sira ang file, walang mababawasan sa datos na nasa telepono na.
  static Future<BackupResult> importFromFile() async {
    try {
      final picked = await FilePicker.pickFile(
        dialogTitle: 'Piliin ang kopya ng datos',
        type: FileType.any,
      );

      if (picked == null) {
        return const BackupResult(BackupStatus.cancelled, '');
      }

      final decoded = jsonDecode(utf8.decode(await picked.readAsBytes()));
      if (decoded is! Map<String, dynamic> || decoded['app'] != 'AuDHD') {
        return const BackupResult(
          BackupStatus.failure,
          'Hindi ito kopya mula sa AuDHD.',
        );
      }

      final format = decoded['format'];
      if (format is! int || format > _formatVersion) {
        return const BackupResult(
          BackupStatus.failure,
          'Gawa ito ng mas bagong bersyon. I-update muna ang app.',
        );
      }

      await restorePayload(decoded);
      return const BackupResult(
        BackupStatus.success,
        'Naibalik ang datos mula sa kopya.',
      );
    } on FormatException {
      return const BackupResult(
        BackupStatus.failure,
        'Sira o hindi mabasa ang file na ito.',
      );
    } catch (_) {
      return const BackupResult(
        BackupStatus.failure,
        'Hindi naibalik ang datos. Subukan ulit.',
      );
    }
  }

  /// Pinapalitan ang laman ng bawat box ng laman ng payload.
  static Future<void> restorePayload(Map<String, dynamic> data) async {
    final profileMap = data['profile'];
    if (profileMap is Map) {
      final profile = ChildProfile.fromMap(profileMap);
      await HiveService.saveChildProfile(profile);

      final photoBase64 = data['photoBase64'];
      final photoFileName = profile.photoFileName;
      if (photoBase64 is String && photoFileName != null) {
        await ChildPhotoService.fileFor(
          photoFileName,
        ).writeAsBytes(base64Decode(photoBase64));
      }
    } else {
      await HiveService.deleteChildProfile();
    }

    final behaviorBox = HiveService.getBehaviorBox();
    await behaviorBox.clear();
    for (final raw in _listOf(data['behaviorLogs'])) {
      final log = BehaviorLog.fromJson(raw);
      await behaviorBox.put(log.id, log);
    }

    final sensoryBox = HiveService.getSensoryBox();
    await sensoryBox.clear();
    for (final raw in _listOf(data['sensoryResults'])) {
      final result = SensoryProfileResult.fromJson(raw);
      await sensoryBox.put(result.id, result);
    }

    final scheduleBox = HiveService.getScheduleBox();
    await scheduleBox.clear();
    for (final raw in _listOf(data['scheduleTasks'])) {
      final task = ScheduleTask.fromJson(raw);
      await scheduleBox.put(task.id, task);
    }

    await _restore(HiveService.getCompletionBox(), data['sensoryCompletion']);
    await _restore(HiveService.getMoodBox(), data['mood']);
    await _restore(HiveService.getMilestoneBox(), data['milestones']);
    await _restore(HiveService.getSettingsBox(), data['settings']);
    await _restore(
      HiveService.getScheduleDoneBox(),
      data['scheduleCompletion'],
    );
    await _restore(HiveService.getRewardBox(), data['rewards']);
    await _restore(HiveService.getGuideBookmarkBox(), data['guideBookmarks']);
    await _restore(HiveService.getGuideTipBox(), data['guideTips']);
    await _restore(HiveService.getScheduleOrderBox(), data['scheduleOrder']);
    await _restore(HiveService.getScheduleHiddenBox(), data['scheduleHidden']);
    await _restore(HiveService.getPrefsBox(), data['prefs']);

    // Nasa Hive na ang naibalik na wika pero luma pa ang hawak sa memorya.
    LanguageController.refreshFromStorage();

    // Ang file na kababalik lang ay siya na mismong huling kopya niya. Kung
    // hindi ito isusulat, sasabihin ng app na wala siyang kopya kahit hawak
    // niya mismo ang file na pinagbalikan.
    final createdAt = data['createdAt'];
    if (createdAt is String && DateTime.tryParse(createdAt) != null) {
      await _meta.put(_lastBackupKey, createdAt);
    }
  }

  static List<Map<String, dynamic>> _listOf(dynamic raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().toList();
  }

  static Future<void> _restore<T>(Box<T> box, dynamic raw) async {
    await box.clear();
    if (raw is! Map) return;
    final entries = <String, T>{};
    raw.forEach((key, value) {
      if (value is T) entries[key.toString()] = value;
    });
    await box.putAll(entries);
  }
}
