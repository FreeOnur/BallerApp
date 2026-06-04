class AuthResult {
  const AuthResult({
    required this.userId,
    this.email,
  });

  final String userId;
  final String? email;
}
