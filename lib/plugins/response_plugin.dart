library slack_bot_response_plugin;

import "package:slack_bot/slack_bot.dart";

/**
 * Responds to phrases that other users say with our phrases.
 *
 * ToDo: store responses into a file so that users can add their own responses
 */
class ResponsePlugin extends IPlugin {

  Map _responses;

  /**
   * The constructor prefills our list of responses
   */
  ResponsePlugin(){
    int mps_in_team_stronach = 6;

    // our list of reponses
    _responses = {
      "Erneuerung": "Erneuerung!",
      "wuzeln?": "Der Slackbot ist ja sooo toll...",
      "Stronach": "Habt's ihr gewusst, dass das Team Stronach immer noch $mps_in_team_stronach Abgeordnete hat?",
      "lounge": "Ich werde jetzt bald auf die Öffentlichkeit losgelassen!"
      "mjam": "https://neos.mjam.net"
    };
  }

  /**
   * Decides if it should response to the message posted to the channel
   *
   * Returns true if it did respond to the message.
   */
  bool respond(Map message){

    // we only look into text messages
    if(message["type"] == "message") {
      String text = message["text"];

      // if it is not a text message, ignore it
      if(text != null){

        // compare all phrases in _responses with the text. if the text contains one of our phrases, this is the key
        String key = _responses.keys.firstWhere((String element) => text.toLowerCase().contains(element.toLowerCase()), orElse:()=>null);

        // if we got a hit, take this response and post it back to the channel from which we received our message
        if(key != null){
          client.postMessage(_responses[key], message["channel"]);
          return true; // return true because we handled the message
        }
      }
    }

    return false; // return false because we didnt handle the message

  }
}
