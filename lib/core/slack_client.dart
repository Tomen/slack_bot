part of slack_bot;


class SlackClient {

  final String _token;
  SlackModel _model = new SlackModel();
  WebSocket _socket;
  List<IPlugin> plugins = <IPlugin>[];
  Logger log = new Logger("slack_bot.client");

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
    log.fine("calling $uri");
    return http.read(uri).then((result){
      var map = JSON.decode(result);
      log.finer(map);
      return map;
    });
  }

  postMessage(String message, String channel){
    // #lounge C02JBE7BK
    // #test C08PKN9D3
    Map map = {"id": 1, "type": "message", "channel": channel, "text": message};
    log.fine("sending: $map");
    var raw = JSON.encode(map);
    if(_socket.readyState == WebSocket.OPEN)
    {
      _socket.add(raw);
    }
    else{
      log.warning("Cannot add message. Socket is not open. Message: $raw");
    }
  }

  /// connects the web socket
  connect() async{
    Map result = await call("rtm.start");
    _model.start(result);

    var connectFutures = plugins.map((IPlugin plugin) => plugin.connect());
    await Future.wait(connectFutures);

    var connectionUrl = result["url"];
    log.fine("connectionUrl: $connectionUrl");
    await reconnect(connectionUrl);
  }

  reconnect(String url) async{
    var socket = await WebSocket.connect(url);

    _socket = socket;
    log.info("did connect");
    socket.listen((String message){
      log.fine("Received: $message");
      Map map = JSON.decode(message);
      bool close = _processIncomingMessage(map);
      if(close){
        socket.close();
      }
    });
  }

  // true if the connection should be closed
  bool _processIncomingMessage(Map message){
    try {
      //{"type":"reconnect_url","url":"wss://mpmulti-17od.slack-msgs.com/websocket/8hG39fEOcLkXiUvSlEg1H3ZFa0Et7LhzlQEamIm56LUYxPvLmcKNwVpH1PrGtR1bMACgFiAG8hkcviOONvOD69EdK7mhGSgAKywKATBcXgwfcSkwUQhQxPSdnbtCDYmH4KoOt3xSTnX5tN08BddQV-z7Omy4CO2StHiaMAZf4bg="}
      if(message["type"] == "reconnect_url"){
        reconnect(message["url"]);
        return true;
      }

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

    return false;
  }

}

/* post as bot:
    if(channel == null){
      channel = _currentChannel;
        String _currentChannel = "#lounge";
    }

    return this.call("chat.postMessage", {"channel": channel, "text": message});*/