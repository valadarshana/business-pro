String authErrorMessage(String code) => switch (code) {
  'invalid-credential' ||
  'wrong-password' ||
  'user-not-found' => 'Email or password is incorrect.',
  'email-already-in-use' => 'An account already exists for this email.',
  'invalid-email' => 'Enter a valid email address.',
  'weak-password' => 'Use a password with at least 6 characters.',
  'user-disabled' => 'This account has been disabled.',
  'too-many-requests' => 'Too many attempts. Try again later.',
  'network-request-failed' =>
    'Network error. Check your connection and try again.',
  'operation-not-allowed' =>
    'Email and password sign-in is not enabled for this Firebase project.',
  _ => 'Authentication failed ($code). Please try again.',
};
