class Note extends Comparable {
  String id;
  String title;
  String content;
  String createTime;
  String updateTime;

  static Note fromMap(Map<String, dynamic> map) {
    Note temp = new Note();
    temp.id = map['id'].toString();
    temp.title = map['title'];
    temp.content = map['content'];
    temp.createTime = map['createTime'];
    temp.updateTime = map['updateTime'];
    return temp;
  }

  static List<Note> fromMapList(dynamic mapList) {
    List<Note> list = new List(mapList.length);
    for (int i = 0; i < mapList.length; i++) {
      list[i] = fromMap(mapList[i]);
    }
    return list;
  }

  Map<String, dynamic> toJson() {
    Map jsonMap = new Map<String, dynamic>();
    if (this.id != null) {
      jsonMap['id'] = int.parse(this.id);
    }
    jsonMap['content'] = this.content;
    jsonMap['title'] = this.title;
    jsonMap['createTime'] = this.createTime;
    jsonMap['updateTime'] = this.updateTime;
    return jsonMap;
  }

  @override
  int compareTo(other) {
    return other.updateTime.compareTo(this.updateTime);
  }

  bool isEmpty() {
    return title == null || title.isEmpty || content == null || content.isEmpty;
  }
}
