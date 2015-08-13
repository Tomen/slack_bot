library slack_bot_command_listing_plugin;

import "package:slack_bot/slack_bot.dart";

class CommandListingCommandPlugin extends CommandPlugin {

  CommandListingCommandPlugin()
  {
    commands = <String, Function>{"help": listCommands};
  }

  List<String> get commandDescriptions {
    return ["!help - Liefert eine Liste verfügbarer Kommandos"];
  }

  listCommands(Map message){
    String channel = message["channel"];

    client.postMessage("Verfügbare Kommandos:", channel);

    for(IPlugin plugin in client.plugins){
      if(plugin is CommandPlugin){
        CommandPlugin commandPlugin = plugin as CommandPlugin;
        List<String> descriptions = commandPlugin.commandDescriptions;
        for(String description in descriptions){
          client.postMessage(description, channel);
        }
      }
    }
  }
}