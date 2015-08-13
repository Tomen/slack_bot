import "package:slack_bot/plugins/ots_command_plugin.dart";

main() async{
  OTSCommandPlugin plugin = new OTSCommandPlugin("");
  await plugin.connect();
  await plugin.printNews(null);
}