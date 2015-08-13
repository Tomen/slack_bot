library slack_bot_ots_plugin;

import "package:slack_bot/slack_bot.dart";
import 'package:http/http.dart' as http;
import "dart:convert";

import "package:slack_bot/slack_bot.dart";


class OTSCommandPlugin extends CommandPlugin {
  final String apiKey;


  OTSCommandPlugin(this.apiKey){
    commands = {"ots": printNews};
  }

  List<String> get commandDescriptions {
    return ["!ots - Liefert aktuelle OTS-Meldungen"];
  }


  printNews(Map message){
    String channel = message["channel"];

    http.get("http://www.ots.at/api/liste?app=$apiKey&query=%28neos%29&inhalt=alle&anz=10&format=json").then((http.Response response){
      Map map = JSON.decode(response.body);
      List elements = map["ergebnisse"];

      if(elements.length < 0){
        client.postMessage("Nichts Neues.", channel);
        return;
      }

      client.postMessage("Top-News von OTS:", channel);
      for(Map element in elements.take(3)){
        String title = element["TITEL"];
        String url = element["WEBLINK"];
        client.postMessage("$title – $url", channel);
      }

    });
  }
}

