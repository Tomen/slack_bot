library slack_bot_response_plugin;

import "package:slack_bot/slack_bot.dart";

class ResponsePlugin extends IPlugin {

  Map responses;

  ResponsePlugin(){
    int mps_in_team_stronach = 6;

    responses = {
      "Erneuerung": "Erneuerung!",
      "wuzeln?": "Der Slackbot ist ja sooo toll...",
      "Stronach": "Habt's ihr gewusst, dass das Team Stronach immer noch $mps_in_team_stronach Abgeordnete hat?",
      "lounge": "Ich werde jetzt bald auf die Öffentlichkeit losgelassen!"
    };
  }

  bool respond(Map message){

    if(message["type"] == "message") {
      String text = message["text"];

      if(text != null){

        String key = responses.keys.firstWhere((String element) => text.toLowerCase().contains(element.toLowerCase()), orElse:()=>null);
        if(key != null){
          client.postMessage(responses[key], message["channel"]);
          return true;
        }
      }
    }

    return false;

  }
}