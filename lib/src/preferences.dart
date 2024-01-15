import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:orgro/src/error.dart';
import 'package:orgro/src/pages/pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum RemoteImagesPolicy { allow, deny, ask }

enum LocalLinksPolicy { deny, ask }

enum SaveChangesPolicy { allow, deny, ask }

enum DecryptPolicy { deny, ask }

const kDefaultFontFamily = 'Fira Code';
const kDefaultTextScale = 1.0;
const String? kDefaultQueryString = null;
const kDefaultFilterKeywords = <String>[];
const kDefaultFilterTags = <String>[];
const kDefaultReaderMode = false;
const kDefaultRemoteImagesPolicy = RemoteImagesPolicy.ask;
const kDefaultLocalLinksPolicy = LocalLinksPolicy.ask;
const kDefaultSaveChangesPolicy = SaveChangesPolicy.ask;
const kDefaultDecryptPolicy = DecryptPolicy.ask;
const kDefaultFullWidth = false;

const kMaxRecentFiles = 10;

const _kFontFamilyKey = 'font_family';
const _kTextScaleKey = 'text_scale';
const _kReaderModeKey = 'reader_mode';
const _kRemoteImagesPolicyKey = 'remote_images_policy';
const _kLocalLinksPolicyKey = 'local_links_policy';
const _kSaveChangesPolicyKey = 'save_changes_policy';
const _kDecryptPolicyKey = 'decrypt_policy';
const _kRecentFilesJsonKey = 'recent_files_json';
const _kAccessibleDirectoriesKey = 'accessible_directories_json';
const _kFullWidthKey = 'full_width';

const _kThemeModeKey = 'theme_mode';

class Preferences extends InheritedWidget {
  static Preferences of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Preferences>()!;

  const Preferences(this._prefs, {required super.child, super.key});

  final SharedPreferences _prefs;

  Future<void> reload() => _prefs.reload();

  String? get fontFamily => _prefs.getString(_kFontFamilyKey);

  Future<bool> setFontFamily(String? value) =>
      _setOrRemove(_kFontFamilyKey, value);

  double? get textScale => _prefs.getDouble(_kTextScaleKey);

  Future<bool> setTextScale(double? value) =>
      _setOrRemove(_kTextScaleKey, value);

  bool? get readerMode => _prefs.getBool(_kReaderModeKey);

  Future<bool> setReaderMode(bool? value) =>
      _setOrRemove(_kReaderModeKey, value);

  List<String> get recentFilesJson =>
      _prefs.getStringList(_kRecentFilesJsonKey) ?? [];

  Future<bool> setRecentFilesJson(List<String> value) =>
      _prefs.setStringList(_kRecentFilesJsonKey, value);

  String? get themeMode => _prefs.getString(_kThemeModeKey);

  Future<bool> setThemeMode(String? value) =>
      _setOrRemove(_kThemeModeKey, value);

  RemoteImagesPolicy? get remoteImagesPolicy =>
      RemoteImagesPolicyPersistence.fromString(
          _prefs.getString(_kRemoteImagesPolicyKey));

  Future<bool> setRemoteImagesPolicy(RemoteImagesPolicy? value) =>
      _setOrRemove(_kRemoteImagesPolicyKey, value.persistableString);

  LocalLinksPolicy? get localLinksPolicy =>
      LocalLinksPolicyPersistence.fromString(
          _prefs.getString(_kLocalLinksPolicyKey));

  Future<bool> setLocalLinksPolicy(LocalLinksPolicy? value) =>
      _setOrRemove(_kLocalLinksPolicyKey, value.persistableString);

  SaveChangesPolicy? get saveChangesPolicy =>
      SaveChangesPolicyPersistence.fromString(
          _prefs.getString(_kSaveChangesPolicyKey));

  Future<bool> setSaveChangesPolicy(SaveChangesPolicy? value) =>
      _setOrRemove(_kSaveChangesPolicyKey, value.persistableString);

  DecryptPolicy? get decryptPolicy =>
      DecryptPolicyPersistence.fromString(_prefs.getString(_kDecryptPolicyKey));

  Future<bool> setDecryptPolicy(DecryptPolicy? value) =>
      _setOrRemove(_kDecryptPolicyKey, value.persistableString);

  /// List of identifiers
  List<String> get accessibleDirs =>
      _prefs.getStringList(_kAccessibleDirectoriesKey) ?? [];

  Future<bool> setAccessibleDirs(List<String> value) =>
      _prefs.setStringList(_kAccessibleDirectoriesKey, value);

  bool? get fullWidth => _prefs.getBool(_kFullWidthKey);

  Future<bool> setFullWidth(bool? value) => _setOrRemove(_kFullWidthKey, value);

  @override
  bool updateShouldNotify(Preferences oldWidget) => _prefs != oldWidget._prefs;

  Future<bool> _setOrRemove<T>(String key, T? value) {
    if (value == null) {
      return _prefs.remove(key);
    } else if (value is String) {
      return _prefs.setString(key, value);
    } else if (value is bool) {
      return _prefs.setBool(key, value);
    } else if (value is double) {
      return _prefs.setDouble(key, value);
    } else {
      throw OrgroError(
        'Unknown type: $T',
        localizedMessage: (context) =>
            AppLocalizations.of(context)!.errorUnknownType(T),
      );
    }
  }
}

class PreferencesProvider extends StatefulWidget {
  const PreferencesProvider({required this.child, this.waiting, super.key});
  final Widget child;
  final Widget? waiting;

  @override
  State<PreferencesProvider> createState() => _PreferencesProviderState();
}

class _PreferencesProviderState extends State<PreferencesProvider> {
  late final Future<SharedPreferences> _instance;

  @override
  void initState() {
    super.initState();
    _instance = SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: _instance,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Preferences(snapshot.data!, child: widget.child);
        } else if (snapshot.hasError) {
          return ErrorPage(error: snapshot.error.toString());
        } else {
          return widget.waiting ?? const SizedBox.shrink();
        }
      },
    );
  }
}

extension RemoteImagesPolicyPersistence on RemoteImagesPolicy? {
  static RemoteImagesPolicy? fromString(String? value) {
    switch (value) {
      case _kRemoteImagesPolicyAllow:
        return RemoteImagesPolicy.allow;
      case _kRemoteImagesPolicyDeny:
        return RemoteImagesPolicy.deny;
      case _kRemoteImagesPolicyAsk:
        return RemoteImagesPolicy.ask;
    }
    return null;
  }

  String? get persistableString => switch (this) {
        RemoteImagesPolicy.allow => _kRemoteImagesPolicyAllow,
        RemoteImagesPolicy.deny => _kRemoteImagesPolicyDeny,
        RemoteImagesPolicy.ask => _kRemoteImagesPolicyAsk,
        null => null,
      };
}

const _kRemoteImagesPolicyAllow = 'remote_images_policy_allow';
const _kRemoteImagesPolicyDeny = 'remote_images_policy_deny';
const _kRemoteImagesPolicyAsk = 'remote_images_policy_ask';

extension LocalLinksPolicyPersistence on LocalLinksPolicy? {
  static LocalLinksPolicy? fromString(String? value) {
    switch (value) {
      case _kLocalLinksPolicyDeny:
        return LocalLinksPolicy.deny;
      case _kLocalLinksPolicyAsk:
        return LocalLinksPolicy.ask;
    }
    return null;
  }

  String? get persistableString => switch (this) {
        LocalLinksPolicy.deny => _kLocalLinksPolicyDeny,
        LocalLinksPolicy.ask => _kLocalLinksPolicyAsk,
        null => null,
      };
}

const _kLocalLinksPolicyDeny = 'remote_images_policy_deny';
const _kLocalLinksPolicyAsk = 'remote_images_policy_ask';

extension SaveChangesPolicyPersistence on SaveChangesPolicy? {
  static SaveChangesPolicy? fromString(String? value) {
    switch (value) {
      case _kSaveChangesPolicyAllow:
        return SaveChangesPolicy.allow;
      case _kSaveChangesPolicyDeny:
        return SaveChangesPolicy.deny;
      case _kSaveChangesPolicyAsk:
        return SaveChangesPolicy.ask;
    }
    return null;
  }

  String? get persistableString => switch (this) {
        SaveChangesPolicy.allow => _kSaveChangesPolicyAllow,
        SaveChangesPolicy.deny => _kSaveChangesPolicyDeny,
        SaveChangesPolicy.ask => _kSaveChangesPolicyAsk,
        null => null
      };
}

const _kSaveChangesPolicyAllow = 'save_changes_policy_allow';
const _kSaveChangesPolicyDeny = 'save_changes_policy_deny';
const _kSaveChangesPolicyAsk = 'save_changes_policy_ask';

extension DecryptPolicyPersistence on DecryptPolicy? {
  static DecryptPolicy? fromString(String? value) {
    switch (value) {
      case _kDecryptPolicyDeny:
        return DecryptPolicy.deny;
      case _kDecryptPolicyAsk:
        return DecryptPolicy.ask;
    }
    return null;
  }

  String? get persistableString => switch (this) {
        DecryptPolicy.deny => _kDecryptPolicyDeny,
        DecryptPolicy.ask => _kDecryptPolicyAsk,
        null => null,
      };
}

const _kDecryptPolicyDeny = 'decrypt_policy_deny';
const _kDecryptPolicyAsk = 'decrypt_policy_ask';
