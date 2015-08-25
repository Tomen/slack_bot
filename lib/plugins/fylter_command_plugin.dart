library slack_bot_fylter_command_plugin;

import "dart:convert";
import 'package:http/http.dart' as http;

import "package:slack_bot/slack_bot.dart";




class FylterCommandPlugin extends CommandPlugin {
  final String _loginUrl;
  final String _bookmarkUrl;
  String _cookie;

  FylterCommandPlugin(this._loginUrl, this._bookmarkUrl){
    commands = {"fylter": printNews};
  }

  List<String> get commandDescriptions {
    return ["!fylter - Liefert aktuelle News aus dem Fylter"];
  }

  connect() async{
    return http.get(_loginUrl).then((http.Response response){
      var cookie = response.headers["set-cookie"];
      List cookies = cookie.split(";");
      _cookie = cookies.firstWhere((String element) => element.contains("JSESSIONID"));

      print(response.headers);
    });
  }

  printNews(Map message){
    String channel = message["channel"];

    http.get(_bookmarkUrl, headers:{"Cookie": _cookie}).then((http.Response response){
      String raw = UTF8.decode(response.bodyBytes);
      //String raw = response.body;
      Map map = JSON.decode(raw);

      print(map);

      List content = map["content"];


      if(content.length == 0){
        client.postMessage("Nichts Neues.", channel);
        return;
      }

      client.postMessage("Top-News von Fylter:", channel);
      for(Map item in content.take(15)){
        String title = item["title"];
        String url = item["url"];
        client.postMessage("$title – $url", channel);
      }
    });

  }
}

