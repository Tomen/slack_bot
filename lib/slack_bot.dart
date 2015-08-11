// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// The Mat library.
library slack_bot;


import 'dart:io';
import "dart:async";
import "dart:convert";
import 'package:http/http.dart' as http;


part "core/slack_client.dart";
part "core/slack_model.dart";
part "core/plugin.dart";
part "core/command_plugin.dart";
