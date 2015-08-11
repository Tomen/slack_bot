part of slack_bot;

class CommandPlugin extends IPlugin {

  Map<String, Function> commands = <String, Function>{};

  CommandPlugin();

  bool respond(Map message){
    if(message["type"] == "message") {
      String text = message["text"];

      if(text != null){
        if(text.startsWith("!")){
          String command = text.substring(1);
          if(commands.keys.contains(command)){
            commands[command](message);
            return true;
          }
        }
      }
    }

    return false;
  }

}