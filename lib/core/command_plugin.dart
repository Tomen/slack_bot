part of slack_bot;

abstract class CommandPlugin extends IPlugin {

  Map<String, Function> commands = <String, Function>{};
  List<String> get commandDescriptions;

  CommandPlugin();

  bool respond(Map message){
    if(message["type"] == "message") {
      String text = message["text"];

      if(text != null){
        if(text.startsWith("!")){
          text = text.substring(1);
          List words = text.split(" ");
          if(words.length > 0){
            String command = words[0];
            if(commands.keys.contains(command)){
              commands[command](message);
              return true;
            }
          }
        }
      }
    }

    return false;
  }

}