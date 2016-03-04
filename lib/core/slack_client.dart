part of slack_bot;


class SlackClient {

  final String _token;
  SlackModel _model = new SlackModel();
  WebSocket _socket;
  List<IPlugin> plugins = <IPlugin>[];
  Logger log = new Logger("slack_bot.clinet");

  SlackClient(this._token);

  /// register the plugin
  registerPlugin(IPlugin plugin){
    plugin.client = this;
    plugins.add(plugin);
  }

  /// Calls a web service method
  Future<Map<String, Object>> call(String apiMethod, [Map<String, String> params]){
    if(params == null){
      params = {};
    }

    params["token"] = _token;
    Uri uri = new Uri.https("slack.com", "/api/$apiMethod", params);
    print(uri);
    return http.read(uri).then((result){
      var map = JSON.decode(result);
      print(map);
      return map;
    });
  }

  postMessage(String message, String channel){
    // #lounge C02JBE7BK
    // #test C08PKN9D3
    Map map = {"id": 1, "type": "message", "channel": channel, "text": message};
    print("sending: $map");
    var raw = JSON.encode(map);
    _socket.add(raw);
  }

  /// connects the web socket
  connect(){
    return call("rtm.start").then((Map result){
      _model.start(result);
      return WebSocket.connect(result["url"]).then((socket) async {

        var connectFutures = plugins.map((IPlugin plugin) => plugin.connect());
        await Future.wait(connectFutures);

        _socket = socket;
        print("did connect");
        socket.listen((String message){
          print("Received: $message");
          Map map = JSON.decode(message);
          _processIncomingMessage(map);
        });
      });
    });
  }

  _processIncomingMessage(Map message){
    try {
      for(IPlugin plugin in plugins){
        if(plugin.respond(message)){
          break;
        }
      }
    }
    catch(e, callstack){
      log.warning(e);
      log.warning(callstack);
    }
  }

}

/* post as bot:
    if(channel == null){
      channel = _currentChannel;
        String _currentChannel = "#lounge";
    }

    return this.call("chat.postMessage", {"channel": channel, "text": message});*/