library slack_bot_reddit_command;

import "dart:convert";

import "package:reddit/reddit.dart";
import 'package:http/http.dart' as http;
import "package:logging/logging.dart";

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


  connect() async{
    Reddit.logger.onRecord.listen((LogRecord record){
      print(record.time.toString() + " - " + record.level.toString() + " - " + record.loggerName + ": " + record.message);
    });
  }

  _printNews(Map message) async{
    String channel = message["channel"];

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
    print(result);

    Map map = JSON.decode(result.toString());

    if(map.keys.contains("error")){
      client.postMessage("Dieses Subreddit konnte ich nicht finden.", channel);
      return;
    }

    List elements = map["data"]["children"];

    if(elements.length == 0){
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
}

