library slack_bot_reddit_command;

import "dart:convert";

import "package:reddit/reddit.dart";
import 'package:http/http.dart' as http;

import "package:slack_bot/slack_bot.dart";


class RedditCommandPlugin extends CommandPlugin {
  final String identifier;
  final String secret;


  RedditCommandPlugin(this.identifier, this.secret){
    commands = {"reddit": _printNews};
  }

  List<String> get commandDescriptions {
    return ["!reddit - Liefert aktuelle News von Reddit"];
  }

  Reddit reddit = new Reddit(new http.Client());

  connect() async{
    reddit.authSetup(identifier, secret);
    await reddit.authFinish();
  }

  _printNews(Map message){
    String channel = message["channel"];

    reddit.sub("worldnews").top().limit(5).fetch().then((result) {
      print(result);
      Map map = JSON.decode(result.toString());
      List elements = map["data"]["children"];

      if(elements.length < 0){
        client.postMessage("Nichts Neues.", channel);
        return;
      }

      client.postMessage("Top-News von Reddit:", channel);
      for(Map element in elements.take(5)){
        String title = element["data"]["title"];
        String url = element["data"]["url"];
        client.postMessage("$title – $url", channel);
      }
    });
  }
}

