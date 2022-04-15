import 'package:cbor/cbor.dart';
import 'package:dcaf/src/cbor.dart';
import 'package:dcaf/src/constants/grant_types.dart';

enum GrantType with CborIntSerializable {
  password(PASSWORD),

  authorizationCode(AUTHORIZATION_CODE),

  clientCredentials(CLIENT_CREDENTIALS),

  refreshToken(REFRESH_TOKEN);

  // Note: "Other" is not supported.

  @override
  final int cbor;

  const GrantType(this.cbor);

  static GrantType fromCborValue(CborValue value) {
    final valueInt = CborIntSerializable.valueToInt(value);
    return GrantType.values.singleWhere((e) => e.cbor == valueInt);
  }
}