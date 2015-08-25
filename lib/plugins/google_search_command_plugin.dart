library google_search_command;

import "package:googleapis_auth/auth_io.dart" as auth;
import "package:googleapis/customsearch/v1.dart" as search;
import "package:http/http.dart" as http;

import "package:slack_bot/slack_bot.dart";


class GoogleSearchCommandPlugin extends CommandPlugin {
  final String apiKey;
  final String customSearchId;
  http.Client searchClient;

  GoogleSearchCommandPlugin(this.apiKey, this.customSearchId){
    commands = {"search": _search};
  }

  List<String> get commandDescriptions {
    return ["!search - Sucht im Web"];
  }


  connect() async{
    //final accountCredentials = new auth.ServiceAccountCredentials.fromJson(credentials);
    //final scopes = [search.CustomsearchApi];

    //searchClient = await auth.clientViaServiceAccount(accountCredentials, ["cse"]);
    searchClient = await auth.clientViaApiKey(apiKey);
  }

  _search(Map message) async{
    String channel = message["channel"];

    String text = message["text"];
    List<String> words = text.split(" ");
    String searchString = null;
    if(words.length > 1){
      searchString = text.substring(words[0].length + 1);
    }
    else
    {
      return;
    }

    search.CustomsearchApi api = new search.CustomsearchApi(searchClient);

    search.Search searchResult = await api.cse.list(searchString, cx:customSearchId);


    if(searchResult.items.length == 0){
      client.postMessage("Keine Ergebnisse.", channel);
      return;
    }

    for(search.Result result in searchResult.items.take(5)){
      String title = result.title;
      String url = result.formattedUrl;
      client.postMessage("$title – $url", channel);
    }

  }
}

