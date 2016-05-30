library slack_bot_reddit_command;

import "dart:convert";

import "package:reddit/reddit.dart";
import 'package:http/http.dart' as http;
import "package:logging/logging.dart";

import "package:slack_bot/slack_bot.dart";


class RedditCommandPlugin extends CommandPlugin {
  final String identifier;
  final String secret;

  Logger log = new Logger("slack_bot.command.reddit");


  RedditCommandPlugin(this.identifier, this.secret){
    commands = {"reddit": _printNews};
  }

  List<String> get commandDescriptions {
    return ["!reddit - Liefert aktuelle News von Reddit"];
  }


  connect() async{
  }

  _printNews(Map message) async{
    String channel = message["channel"];

    try{
      String text = message["text"];
      List words = text.split(" ");
      String subredditName = null;
      if(words.length > 1){
        subredditName = words[1];
      }

      Reddit reddit = new Reddit(new http.Client());
      reddit.authSetup(identifier, secret);
      await reddit.authFinish();

      Subreddit sub;
      if(subredditName == null){
        sub = reddit.frontPage;
      }
      else
      {
        sub = reddit.sub(subredditName);
      }

      ListingResult result = await sub.top().limit(5).fetch();
      log.fine(result);

      Map map = JSON.decode(result.toString());

      //if(map.keys.con)

      List elements = map["data"]["children"];

      if(elements.length < 0){
        client.postMessage("Nichts Neues.", channel);
        return;
      }

      //client.postMessage("Top-News von Reddit:", channel);
      for(Map element in elements.take(5)){
        String title = element["data"]["title"];
        String url = element["data"]["url"];
        client.postMessage("$title – $url", channel);
      }
    }
    catch(e, _callstack){
      print(e);
      print(_callstack);
      client.postMessage("Du hast Reddit kaputt gemacht, @reno", channel);
      client.postMessage(e.toString(), channel);
      client.postMessage(_callstack.toString(), channel);
    }
  }
}

