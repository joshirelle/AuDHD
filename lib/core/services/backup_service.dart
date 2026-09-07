import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/behavior_log.dart';
import '../../data/models/child_profile.dart';
import '../../data/models/sensory_profile_result.dart';
import '../../data/services/hive_service.dart';
import '../../data/services/scoped_box.dart';
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
  ///
  /// 2 — maraming bata sa `children`; ang 1 ay may iisang `profile`.
  static const int _formatVersion = 2;

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
    final children = <Map<String, dynamic>>[];
    for (final child in HiveService.getChildProfiles()) {
      children.add({
        'profile': child.toMap(),
        'photoBase64': await _photoBase64(child.photoFileName),
      });
    }

    return {
      'format': _formatVersion,
      'app': 'AuDHD',
      'createdAt': DateTime.now().toIso8601String(),
      'children': children,
      'activeChildId': HiveService.getActiveChildId(),
      // Naka-Map at hindi listahan: nasa susi ang kung kaninong bata ito, at
      // ang `id` ng bagay ay walang alam tungkol doon.
      'behaviorLogs': _dumpJson(
        HiveService.getBehaviorRawBox(),
        (log) => log.toJson(),
      ),
      'sensoryResults': _dumpJson(
        HiveService.getSensoryRawBox(),
        (result) => result.toJson(),
      ),
      'scheduleTasks': _dumpJson(
        HiveService.getScheduleRawBox(),
        (task) => task.toJson(),
      ),
      'sensoryCompletion': _dump(HiveService.getCompletionRawBox()),
      'mood': _dump(HiveService.getMoodRawBox()),
      'milestones': _dump(HiveService.getMilestoneRawBox()),
      'settings': _dump(HiveService.getSettingsBox()),
      'scheduleCompletion': _dump(HiveService.getScheduleDoneRawBox()),
      'rewards': _dump(HiveService.getRewardRawBox()),
      'guideBookmarks': _dump(HiveService.getGuideBookmarkBox()),
      'guideTips': _dump(HiveService.getGuideTipBox()),
      'dswdChecklist': _dump(HiveService.getDswdChecklistRawBox()),
      'scheduleOrder': _dump(HiveService.getScheduleOrderRawBox()),
      'scheduleHidden': _dump(HiveService.getScheduleHiddenRawBox()),
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

  static Map<String, dynamic> _dumpJson<T>(
    Box<T> box,
    Map<String, dynamic> Function(T) toJson,
  ) {
    final result = <String, dynamic>{};
    for (final key in box.keys) {
      final value = box.get(key);
      if (value != null) result[key.toString()] = toJson(value);
    }
    return result;
  }

  /// Ang `format: 1` ay walang prefix sa susi. Idinidikit ito sa nag-iisang
  /// bata ng file; kung wala, walang naibabalik.
  static String? _legacyScopeOf(
    Map<String, dynamic> data,
    List<(ChildProfile, String?)> entries,
  ) => data['children'] is List ? null : entries.firstOrNull?.$1.id;

  static String _scopedKey(Object key, String? scope) =>
      scope == null ? key.toString() : '$scope${ScopedBox.separator}$key';

  /// Ang tatlong box na may buong bagay sa loob.
  ///
  /// Naka-Map ang `format: 2`, kaya ang susi mismo ang dala ng kung kaninong
  /// bata. Listahan ang `format: 1`, kaya doon lang ginagamit ang `id` ng
  /// bagay — at idinidikit sa nag-iisang bata ng file.
  static Future<void> _restoreObjects<T>(
    Box<T> box,
    dynamic raw,
    String? scope,
    T Function(Map<String, dynamic>) fromJson,
    String Function(T) idOf,
  ) async {
    await box.clear();

    if (raw is Map) {
      for (final entry in raw.entries) {
        final value = entry.value;
        if (value is Map) {
          await box.put(
            entry.key.toString(),
            fromJson(Map<String, dynamic>.from(value)),
          );
        }
      }
      return;
    }

    for (final json in _listOf(raw)) {
      final value = fromJson(json);
      await box.put(_scopedKey(idOf(value), scope), value);
    }
  }

  static Future<String?> _photoBase64(String? fileName) async {
    if (fileName == null) return null;
    final file = ChildPhotoService.fileFor(fileName);
    if (!file.existsSync()) return null;
    return base64Encode(await file.readAsBytes());
  }

  /// Ang mga bata at ang litrato nila.
  static Future<void> _restoreChildren(
    Map<String, dynamic> data,
    List<(ChildProfile, String?)> entries,
  ) async {
    final box = HiveService.getProfilesBox();
    await box.clear();

    for (final (profile, photoBase64) in entries) {
      await box.put(profile.id, profile.toMap());

      final fileName = profile.photoFileName;
      if (photoBase64 != null && fileName != null) {
        await ChildPhotoService.fileFor(
          fileName,
        ).writeAsBytes(base64Decode(photoBase64));
      }
    }

    final saved = data['activeChildId'];
    final activeId = saved is String && box.containsKey(saved)
        ? saved
        : entries.firstOrNull?.$1.id;

    if (activeId == null) {
      await HiveService.clearActiveChild();
    } else {
      await HiveService.setActiveChild(activeId);
    }
  }

  /// Ang `format: 1` ay may iisang `profile` na walang id, kaya binibigyan
  /// dito. Ang bagong id ay hindi mahalaga: bawat restore ay nililinis muna
  /// ang box, kaya walang lumang susing maiiwang nakaturo sa wala.
  static List<(ChildProfile, String?)> _childEntriesFrom(
    Map<String, dynamic> data,
  ) {
    final children = data['children'];
    if (children is List) {
      return children
          .whereType<Map>()
          .map((raw) {
            final profile = raw['profile'];
            if (profile is! Map) return null;
            return (
              ChildProfile.fromMap(profile, idIfMissing: const Uuid().v4()),
              raw['photoBase64'] as String?,
            );
          })
          .nonNulls
          .toList();
    }

    final profile = data['profile'];
    if (profile is! Map) return const [];
    return [
      (
        ChildProfile.fromMap(profile, idIfMissing: const Uuid().v4()),
        data['photoBase64'] as String?,
      ),
    ];
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
    final entries = _childEntriesFrom(data);
    final scope = _legacyScopeOf(data, entries);

    await _restoreObjects<BehaviorLog>(
      HiveService.getBehaviorRawBox(),
      data['behaviorLogs'],
      scope,
      BehaviorLog.fromJson,
      (log) => log.id,
    );
    await _restoreObjects<SensoryProfileResult>(
      HiveService.getSensoryRawBox(),
      data['sensoryResults'],
      scope,
      SensoryProfileResult.fromJson,
      (result) => result.id,
    );
    await _restoreObjects<ScheduleTask>(
      HiveService.getScheduleRawBox(),
      data['scheduleTasks'],
      scope,
      ScheduleTask.fromJson,
      (task) => task.id,
    );

    await _restore(
      HiveService.getCompletionRawBox(),
      data['sensoryCompletion'],
      scope: scope,
    );
    await _restore(HiveService.getMoodRawBox(), data['mood'], scope: scope);
    await _restore(
      HiveService.getMilestoneRawBox(),
      data['milestones'],
      scope: scope,
    );
    // Pang-app at hindi pang-bata, kaya walang prefix.
    await _restore(HiveService.getSettingsBox(), data['settings']);
    await _restore(
      HiveService.getScheduleDoneRawBox(),
      data['scheduleCompletion'],
      scope: scope,
    );
    await _restore(
      HiveService.getRewardRawBox(),
      data['rewards'],
      scope: scope,
    );
    await _restore(HiveService.getGuideBookmarkBox(), data['guideBookmarks']);
    await _restore(HiveService.getGuideTipBox(), data['guideTips']);
    await _restore(
      HiveService.getDswdChecklistRawBox(),
      data['dswdChecklist'],
      scope: scope,
    );
    await _restore(
      HiveService.getScheduleOrderRawBox(),
      data['scheduleOrder'],
      scope: scope,
    );
    await _restore(
      HiveService.getScheduleHiddenRawBox(),
      data['scheduleHidden'],
      scope: scope,
    );
    await _restore(HiveService.getPrefsBox(), data['prefs']);

    // Pagkatapos ng `prefs`: nasa box na iyon ang `active_child_id`, at
    // nililinis ito ng `_restore` bago magsulat. Kung mauuna ang mga bata,
    // mabubura ang aktibo — at sa `format: 1` ay wala itong ibabalik.
    await _restoreChildren(data, entries);

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

  static Future<void> _restore<T>(
    Box<T> box,
    dynamic raw, {
    String? scope,
  }) async {
    await box.clear();
    if (raw is! Map) return;
    final entries = <String, T>{};
    raw.forEach((key, value) {
      if (value is T) entries[_scopedKey(key as Object, scope)] = value;
    });
    await box.putAll(entries);
  }
}
