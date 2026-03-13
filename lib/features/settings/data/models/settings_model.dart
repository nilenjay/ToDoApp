import 'package:hive/hive.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 3)
class AppSettings extends HiveObject {
  @HiveField(0)
  final bool isDarkMode;

  @HiveField(1)
  final int defaultDurationMinutes;

  @HiveField(2)
  final int defaultFocusTypeIndex; // 0=study, 1=deepWork, 2=creative

  @HiveField(3)
  final bool notificationsEnabled;

  AppSettings({
    this.isDarkMode = true,
    this.defaultDurationMinutes = 50,
    this.defaultFocusTypeIndex = 1,
    this.notificationsEnabled = true,
  });

  AppSettings copyWith({
    bool? isDarkMode,
    int? defaultDurationMinutes,
    int? defaultFocusTypeIndex,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      defaultDurationMinutes:
      defaultDurationMinutes ?? this.defaultDurationMinutes,
      defaultFocusTypeIndex:
      defaultFocusTypeIndex ?? this.defaultFocusTypeIndex,
      notificationsEnabled:
      notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}