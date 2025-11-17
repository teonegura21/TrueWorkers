enum MediaFileType {
  image,
  video;

  String toJson() => name.toUpperCase();

  static MediaFileType fromJson(String json) {
    return MediaFileType.values.firstWhere(
      (e) => e.name.toUpperCase() == json.toUpperCase(),
      orElse: () => MediaFileType.image,
    );
  }
}

enum MediaCategory {
  portfolio,
  profile,
  job,
  beforeAfter,
  inspiration;

  String toJson() {
    switch (this) {
      case MediaCategory.beforeAfter:
        return 'BEFORE_AFTER';
      default:
        return name.toUpperCase();
    }
  }

  static MediaCategory fromJson(String json) {
    switch (json.toUpperCase()) {
      case 'BEFORE_AFTER':
        return MediaCategory.beforeAfter;
      case 'PORTFOLIO':
        return MediaCategory.portfolio;
      case 'PROFILE':
        return MediaCategory.profile;
      case 'JOB':
        return MediaCategory.job;
      case 'INSPIRATION':
        return MediaCategory.inspiration;
      default:
        return MediaCategory.portfolio;
    }
  }
}

enum MediaStatus {
  processing,
  active,
  failed,
  deleted;

  String toJson() => name.toUpperCase();

  static MediaStatus fromJson(String json) {
    return MediaStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == json.toUpperCase(),
      orElse: () => MediaStatus.active,
    );
  }
}
