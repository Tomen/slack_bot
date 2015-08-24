import "package:slack_bot/plugins/ots_command_plugin.dart";

import "dart:io" as io;
import "package:yaml/yaml.dart";
import 'package:slack_bot/slack_bot.dart';


main() async{
  String raw = new io.File("config.yaml").readAsStringSync();
  YamlMap yaml = loadYaml(raw);

  YamlMap slackConfig = yaml["slack"];
  if(slackConfig == null){
    print("no slack_token provided in config.yaml. Exiting");
    return;
  }

  var client = new SlackClient(slackConfig["token"]);


  await client.connect().then((_){
    var params;
    params = {"channel": "D08S51WSU", "ts": "1440109049.000068"};
    client.call("chat.delete", params);
  });
}