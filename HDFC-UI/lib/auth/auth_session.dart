/// In-memory session after login (JWT from customer-service).
class AuthSession {
  AuthSession._();

  static String? bearerToken;
  static String? customerId;
  static String? displayName;

  static void setFromLogin({
    required String token,
    required String customerIdStr,
    String? name,
  }) {
    bearerToken = token;
    customerId = customerIdStr;
    displayName = name;
  }

  static void clear() {
    bearerToken = null;
    customerId = null;
    displayName = null;
  }

  static bool get isLoggedIn => customerId != null && customerId!.isNotEmpty;
}
