class ProfileEntity {
  final String userId;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String preferredCurrency;

  const ProfileEntity({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.preferredCurrency = 'USD',
  });

  String get resolvedName {
    if (fullName.trim().isNotEmpty) {
      return _capitalizeWords(fullName.trim());
    }
    final combined = '${firstName.trim()} ${lastName.trim()}'.trim();
    return combined.isNotEmpty ? _capitalizeWords(combined) : 'User';
  }

  String get alias {
    final name = resolvedName.replaceAll(RegExp(r'\s+'), '');
    if (name.isEmpty) {
      return 'UN';
    }
    if (name.length == 1) {
      return name.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  String _capitalizeWords(String value) {
    final parts = value.split(RegExp(r'\s+'));
    final normalized = <String>[];

    for (final part in parts) {
      if (part.isEmpty) {
        continue;
      }
      final head = part.substring(0, 1).toUpperCase();
      final tail = part.length > 1 ? part.substring(1).toLowerCase() : '';
      normalized.add('$head$tail');
    }

    return normalized.join(' ');
  }
}
