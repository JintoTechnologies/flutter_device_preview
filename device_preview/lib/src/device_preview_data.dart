import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

/// A [DevicePreview] configuration snapshot that can be
/// serialized to be persisted between session.
class DevicePreviewData {
  static const Size freeformMaxSize = Size(2400, 2400);

  final Orientation orientation;
  final int deviceIndex;
  final String locale;
  final bool isFrameVisible;
  final bool isDarkMode;
  final bool boldText;
  final bool disableAnimations;
  final bool highContrast;
  final bool accessibleNavigation;
  final bool invertColors;
  final double textScaleFactor;
  final Size freeformSize;

  /// Creates a new [DevicePreviewData] configuration from all
  /// properties.
  const DevicePreviewData({
    this.orientation = Orientation.portrait,
    this.deviceIndex = 0,
    this.locale,
    this.isFrameVisible = true,
    this.isDarkMode = false,
    this.boldText = false,
    this.disableAnimations = false,
    this.highContrast = false,
    this.accessibleNavigation = false,
    this.invertColors = false,
    this.textScaleFactor = 1.0,
    this.freeformSize = freeformMaxSize,
  });

  /// Copy the current configuration, but updates the given
  /// properties.
  DevicePreviewData copyWith({
    Orientation orientation,
    int deviceIndex,
    String locale,
    bool isFrameVisible,
    bool isDarkMode,
    bool boldText,
    bool disableAnimations,
    bool highContrast,
    bool accessibleNavigation,
    bool invertColors,
    double textScaleFactor,
    Size freeformSize,
  }) =>
      DevicePreviewData(
        orientation: orientation ?? this.orientation,
        deviceIndex: deviceIndex ?? this.deviceIndex,
        locale: locale ?? this.locale,
        isFrameVisible: isFrameVisible ?? this.isFrameVisible,
        isDarkMode: isDarkMode ?? this.isDarkMode,
        boldText: boldText ?? this.boldText,
        disableAnimations: disableAnimations ?? this.disableAnimations,
        highContrast: highContrast ?? this.highContrast,
        accessibleNavigation: accessibleNavigation ?? this.accessibleNavigation,
        invertColors: invertColors ?? this.invertColors,
        textScaleFactor: textScaleFactor ?? this.textScaleFactor,
        freeformSize: freeformSize ?? this.freeformSize,
      );

  /// Convert the instance to a dynamic map (for serialization).
  Map<String, dynamic> toMap() {
    return {
      'orientation': orientation.index,
      'deviceIndex': deviceIndex,
      'locale': locale,
      'isFrameVisible': isFrameVisible,
      'isDarkMode': isDarkMode,
      'boldText': boldText,
      'disableAnimations': disableAnimations,
      'highContrast': highContrast,
      'accessibleNavigation': accessibleNavigation,
      'invertColors': invertColors,
      'textScaleFactor': textScaleFactor,
      'freeformSize': [
        freeformSize.width,
        freeformSize.height,
      ],
    };
  }

  /// Convert a dynamic map to an instance (for deserialization).
  factory DevicePreviewData.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
    final size =
        map['freeformSize'] ?? [freeformMaxSize.width, freeformMaxSize.height];
    return DevicePreviewData(
      orientation: Orientation.values[map['orientation'] ?? 0],
      deviceIndex: map['deviceIndex'] ?? 0,
      locale: map['locale'],
      isFrameVisible: map['isFrameVisible'] ?? false,
      isDarkMode: map['isDarkMode'] ?? false,
      boldText: map['boldText'] ?? false,
      disableAnimations: map['disableAnimations'] ?? false,
      highContrast: map['highContrast'] ?? false,
      accessibleNavigation: map['accessibleNavigation'] ?? false,
      invertColors: map['invertColors'] ?? false,
      textScaleFactor: map['textScaleFactor'] ?? 1.0,
      freeformSize: Size(
        size[0],
        size[1],
      ),
    );
  }

  /// Load the last saved preferences (until [ignore] is `true`).
  static Future<DevicePreviewData> load([bool ignore = false]) async {
    if (!ignore) {
      final dir = await getApplicationSupportDirectory();
      final file = File('${dir.path}/$_preferencesFile');
      if (!await file.exists()) return null;
      final json = await file.readAsString();
      if (json == null || json.isEmpty) return null;
      return DevicePreviewData.fromMap(jsonDecode(json));
    }
    return null;
  }

  /// Save the current preferences (until [ignore] is `true`).
  Future<void> save([bool ignore = false]) async {
    if (!ignore) {
      _saveData = this;
      _saveTask ??= _save();
      await _saveTask;
    }
  }

  static const String _preferencesFile = 'device_preview.config';
  static Future _saveTask;
  static DevicePreviewData _saveData;

  static Future _save() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_saveData != null) {
      final dir = await getApplicationSupportDirectory();
      final file = File('${dir.path}/$_preferencesFile');
      await file.writeAsString(jsonEncode(_saveData.toMap()));
    }
    _saveTask = null;
  }
}
