// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "dart:io" as io;
import "dart:convert";
import "package:yaml/yaml.dart";
import 'package:slack_bot/slack_bot.dart';
import "package:slack_bot/plugins/reddit_command_plugin.dart";
import "package:slack_bot/plugins/response_plugin.dart";
import "package:slack_bot/plugins/fylter_command_plugin.dart";

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
    if(key == "reddit"){
      YamlMap config = yaml[key];
      final String identifier =  config["identifier"];
      final String secret = config["secret"];
      RedditCommandPlugin reddit = new RedditCommandPlugin(identifier, secret);
      client.registerPlugin(reddit);
    }

    if(key == "fylter"){
      YamlMap config = yaml[key];
      final String loginUrl =  config["login_url"];
      final String bookmarkUrl = config["bookmark_url"];
      FylterCommandPlugin fylter = new FylterCommandPlugin(loginUrl, bookmarkUrl);
      client.registerPlugin(fylter);
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