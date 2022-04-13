import 'package:dcaf/src/constants/grant_types.dart';

enum GrantType {
  Password,

  AuthorizationCode,

  ClientCredentials,

  RefreshToken,

  Other
}

const Map<int, GrantType> _grantTypeMapping = {
  PASSWORD: GrantType.Password,
  AUTHORIZATION_CODE: GrantType.AuthorizationCode,
  CLIENT_CREDENTIALS: GrantType.ClientCredentials,
  REFRESH_TOKEN: GrantType.RefreshToken
};

Map<GrantType, int> _reversedGrantTypeMapping = _grantTypeMapping
    .map((k, v) => MapEntry(v, k));

extension GrantTypeCbor on GrantType {
  int get cborKey {
    final int? result = _reversedGrantTypeMapping[this];
    if (result != null) {
      return result;
    } else if (this == GrantType.Other) {
      throw UnsupportedError("Custom grant types are not yet supported.");
    } else {
      throw RangeError("Unknown grant type '${this}'");
    }
  }

  static GrantType fromCborKey(int key) {
    final GrantType? result = _grantTypeMapping[key];
    if (result != null) {
      return result;
    } else {
      throw UnsupportedError("Custom grant types are not yet supported.");
    }
  }
}

