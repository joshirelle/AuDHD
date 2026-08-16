import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Nasa app-private na folder ang litrato ng bata, hindi sa gallery kung saan
/// mababasa ito ng ibang app.
class ChildPhotoService {
  static Directory? _directory;

  static Future<void> init() async {
    _directory = await getApplicationDocumentsDirectory();
  }

  /// Pangalan lang ang iniimbak sa Hive: nagbabago ang buong path ng container
  /// tuwing nag-a-update ang iOS app, kaya masisira ang naka-save na absolute path.
  static File fileFor(String fileName) =>
      File('${_directory!.path}/$fileName');

  /// `null` kapag kinansela ng magulang ang pagpili.
  static Future<String?> pick(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked == null) return null;

    // Bagong pangalan kada palit: naka-cache ang `Image.file` batay sa path,
    // kaya mananatiling luma ang ipinapakita kung gagamitin muli ang pangalan.
    final fileName = 'child_${const Uuid().v4()}.jpg';
    await File(picked.path).copy(fileFor(fileName).path);
    return fileName;
  }

  static Future<void> delete(String? fileName) async {
    if (fileName == null) return;
    final file = fileFor(fileName);
    if (file.existsSync()) await file.delete();
  }
}
