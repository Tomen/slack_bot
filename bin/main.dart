// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "dart:io" as io;
import "dart:convert";
import "package:yaml/yaml.dart";
import "package:logging/logging.dart";
import 'package:slack_bot/slack_bot.dart';
import "package:slack_bot/plugins/reddit_command_plugin.dart";
import "package:slack_bot/plugins/response_plugin.dart";
import "package:slack_bot/plugins/fylter_command_plugin.dart";
import "package:slack_bot/plugins/command_listing_plugin.dart";
import "package:slack_bot/plugins/ots_command_plugin.dart";
import "package:slack_bot/plugins/google_search_command_plugin.dart";

SlackClient client;
String defaultChannel;

/*

  provide a config.yaml file with the following configuration. (the reddit config is optional)

  slack:
    token: xxxx
    defaultChannel: xxxx
  reddit:
    identifier: xxxx
    secret: xxxx

*/
main(List<String> arguments) async {

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  String raw = new io.File("config.yaml").readAsStringSync();
  YamlMap yaml = loadYaml(raw);

  YamlMap slackConfig = yaml["slack"];
  if(slackConfig == null){
    print("no slack_token provided in config.yaml. Exiting");
    return;
  }

  client = new SlackClient(slackConfig["token"]);
  defaultChannel = slackConfig["defaultChannel"];

  for(String key in yaml.keys){
    if(key == "commands"){
      CommandListingCommandPlugin commandsPlugin = new CommandListingCommandPlugin();
      client.registerPlugin(commandsPlugin);
    }

    if(key == "reddit"){
      YamlMap config = yaml[key];
      final String identifier = config["identifier"];
      final String secret = config["secret"];
      RedditCommandPlugin reddit = new RedditCommandPlugin(identifier, secret);
      client.registerPlugin(reddit);
    }

    if(key == "fylter"){
      YamlMap config = yaml[key];
      final String loginUrl = config["login_url"];
      final String bookmarkUrl = config["bookmark_url"];
      FylterCommandPlugin fylter = new FylterCommandPlugin(loginUrl, bookmarkUrl);
      client.registerPlugin(fylter);
    }

    if(key == "ots"){
      YamlMap config = yaml[key];
      final String apiKey = config["api_key"];
      OTSCommandPlugin ots = new OTSCommandPlugin(apiKey);
      client.registerPlugin(ots);
    }
    if(key == "search"){
      YamlMap config = yaml[key];
      final String apiKey = config["api_key"];
      final String customSearchId = config["custom_search_id"];
      GoogleSearchCommandPlugin search = new GoogleSearchCommandPlugin(apiKey, customSearchId);
      client.registerPlugin(search);
    }
  }

  ResponsePlugin responder = new ResponsePlugin();
  client.registerPlugin(responder);

  await client.connect().then(readCommands);
}

readCommands(_) {
  io.stdin.transform(UTF8.decoder).transform(new LineSplitter()).listen((String line){
    processCommand(line);
  });
}

processCommand(String command) async{
  return client.postMessage(command, defaultChannel);
}