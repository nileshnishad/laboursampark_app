String maskPhone(String phone) {
  final cleaned = phone.trim();
  if (cleaned.isEmpty) return 'xxxxxxx';
  final visible = cleaned.length >= 3
      ? cleaned.substring(cleaned.length - 3)
      : cleaned;
  return 'xxxx$visible';
}

String maskEmail(String email) {
  final trimmed = email.trim();
  if (trimmed.isEmpty || !trimmed.contains('@')) {
    return 'xxxxxx@xxxx.com';
  }
  final parts = trimmed.split('@');
  final domain = parts.length > 1 ? parts[1] : 'xxxx.com';
  return 'xxxxxx@$domain';
}
