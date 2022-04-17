/*
 * Copyright (c) 2022 The NAMIB Project Developers.
 * Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
 * https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
 * <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
 * option. This file may not be copied, modified, or distributed
 * except according to those terms.
 *
 * SPDX-License-Identifier: MIT OR Apache-2.0
 */

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
