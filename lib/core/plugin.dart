part of slack_bot;

abstract class IPlugin {
  SlackClient client;

  Future connect() => new Future.value();
  bool respond(Map message);
}