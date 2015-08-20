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

  }

  _printNews(Map message) async{
    String channel = message["channel"];

    Reddit reddit = new Reddit(new http.Client());
    Reddit.logger.onRecord.listen((LogRecord record){
      print(record.time.toString() + " - " + record.level.toString() + " - " + record.loggerName + ": " + record.message);
    });
    reddit.authSetup(identifier, secret);
    await reddit.authFinish();

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

