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

/// Constants for COSE_Key objects, as specified in
/// [section 7 of RFC 8152](https://datatracker.ietf.org/doc/html/rfc8152#section-7).

/// Constant for the Key Type.
const int kty = 1;

/// Constant for the Key ID.
const int kid = 2;

/// Constant for the Key Algorithm.
const int alg = 3;

/// Constant for the allowed key operations.
const int keyOps = 4;

/// Constant for the base Initialization Vector.
const int baseIv = 5;
