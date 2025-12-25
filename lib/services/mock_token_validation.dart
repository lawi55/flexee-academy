enum TokenStatus { valid, expired, invalid }

TokenStatus mockValidateToken(String token) {
  if (token.contains("expired")) {
    return TokenStatus.expired;
  }

  if (token.contains("invalid")) {
    return TokenStatus.invalid;
  }

  // default → valid
  return TokenStatus.valid;
}

