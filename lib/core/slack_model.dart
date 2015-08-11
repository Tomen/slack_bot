part of slack_bot;

/// not really in use yet
class SlackModel{

  List<SlackUser> users;

  SlackModel();

  start(Map map){
    List users = map["users"];
    this.users = users.map((Map raw) => new SlackUser.fromJSON(raw)).toList();
  }
}

class SlackUser {
  String id;
  String name;
  bool is_bot;

  SlackUser.fromJSON(Map json){
    id = json["id"];
    name = json["name"];
    is_bot = json["is_bot"];
  }
}