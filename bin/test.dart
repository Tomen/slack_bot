import "package:slack_bot/plugins/fylter_command_plugin.dart";

main() async{


  FylterCommandPlugin plugin = new FylterCommandPlugin(url);
  await plugin.connect();
  await plugin.printNews(null);
}