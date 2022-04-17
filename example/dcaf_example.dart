import 'dart:convert';
import 'package:dcaf/dcaf.dart';

void main() {
  final request = AccessTokenRequest(
      clientId: "myclient",
      audience: "valve242",
      scope: TextScope("read"),
      reqCnf: KeyId([0xDC, 0xAF]));
  final List<int> serialized = request.serialize();
  assert(AccessTokenRequest.fromSerialized(serialized) == request);

  // TODO(falko17): Further examples, including responses, creation hints, etc.
}
