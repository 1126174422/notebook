import 'package:notebook/dao/table/ITable.dart';

class NoteTable extends ITable {
  @override
  String name = "Notebook";
  @override
  List<String> keys = ["id", "title", "content", "createTime", "updateTime"];
  @override
  List<String> types = ["INTEGER ", "TEXT", "TEXT", "TEXT", "TEXT"];
}
