import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notebook/EditTagPage.dart';
import 'package:notebook/common/StringUtil.dart';
import 'package:notebook/dao/Note.dart';
import 'package:notebook/db/DatabaseHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: StringUtil.NOTE_BOOK),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const String key = "myTags";
  static List<Note> tags;
  static List<Note> allTags;
  TextEditingController _searchController = new TextEditingController();
  static List<int> selected;
  bool showSelect = false;
  var db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    tags = new List();
    allTags = new List();
    selected = new List();
    getLocalDatas();
  }

  getLocalDatas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.
    setState(() {
      List<dynamic> values = json.decode(prefs.get(key));
      if (values.length > 0) {
        tags.clear();
        for (Map value in values) {
          tags.add(Note.fromMap(value));
        }
      }
      allTags.addAll(tags);
    });
  }

  void _incrementCounter(Note tag) async {
    var result = await Navigator.push(
        context,
        new CupertinoPageRoute(
            builder: (context) =>
                new EditTag(tag == null ? true : false, tag ?? Note())));
    if (result != null && result is Note && !result.isEmpty()) {
      setState(() {
        if (tag != null) {
          tags.remove(tag);
          allTags.remove(tag);
        }
        tags.insert(0, result);
        allTags.insert(0, result);
        saveTags();
      });
    }
  }

  void saveTags() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, json.encode(allTags));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (showSelect) {
            setState(() {
              showSelect = false;
            });
            return false;
          }
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: (allTags == null || allTags.isEmpty)
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: _getContentWidget(),
                ),
              ],
            ),
          ),
          persistentFooterButtons: <Widget>[
            Offstage(
              offstage: !showSelect,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    child: Icon(Icons.delete),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("是否删除选中项？"),
                              actions: <Widget>[
                                FlatButton(
                                    onPressed: () {
                                      setState(() {
                                        //首先总列表中删除显示列表中的选中项
                                        allTags.removeWhere((node) {
                                          int index = tags.indexOf(node);
                                          return selected.contains(index);
                                        });
                                        tags.removeWhere((node) {
                                          int index = tags.indexOf(node);
                                          return selected.contains(index);
                                        });
                                        selected.clear();
                                        showSelect = false;
                                        saveTags();
                                      });
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("确定")),
                                FlatButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text("取消"),
                                )
                              ],
                            );
                          });
                    },
                  ),
                  GestureDetector(
                    child: Icon(Icons.select_all,
                        color: selected.length == tags.length
                            ? Colors.blue
                            : Colors.grey),
                    onTap: () {
                      setState(() {
                        if (selected.length == tags.length) {
                          selected.clear();
                        } else {
                          selected.clear();
                          for (int i = 0; i < tags.length; i++) {
                            selected.add(i);
                          }
                        }
                      });
                    },
                  )
                ],
              ),
            )
          ],
          floatingActionButton: FloatingActionButton(
            onPressed: () => _incrementCounter(null),
            tooltip: 'Increment',
            child: Icon(Icons.add),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        ));
  }

  _getContentWidget() {
    if (allTags == null || allTags.isEmpty) {
      return Text("还没有创建任何记事本");
    } else {
      List<Widget> list = new List();
      list.add(DecoratedBox(
          decoration: BoxDecoration(color: Colors.orangeAccent),
          child: Padding(
            padding: EdgeInsets.all(5),
            child: TextField(
              controller: _searchController,
              onSubmitted: (String searchStr) => doSearch(searchStr),
              onChanged: (String searchStr) => doSearch(searchStr),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                  hintText: "关键字搜索便签",
                  icon: Icon(
                    Icons.search,
                    color: Colors.amber,
                  )),
            ),
          )));
      if (tags == null || tags.isEmpty) {
        return Column(
          children: <Widget>[
            list[0],
            Expanded(
              flex: 1,
              child: Center(
                child: Container(
                  child: Text(
                    "没有找到相关便签！",
                  ),
                ),
              ),
            )
          ],
        );
      }
      tags.sort();
      list.add(Expanded(
          flex: 1,
          child: ListView.builder(
              itemCount: tags.length,
              itemExtent: 60,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () => _incrementCounter(tags[index]),
                  onLongPress: () {
                    setState(() {
                      showSelect = true;
                      selected.add(index);
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.all(5),
                    width: double.infinity,
                    height: 50,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.amberAccent,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black54,
                              offset: Offset(2, 2),
                              blurRadius: 4)
                        ],
                      ),
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        width: double.infinity,
                                        child: Text(
                                          tags[index]
                                              .updateTime
                                              .substring(0, 19),
                                          textScaleFactor: 0.8,
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        child: Text(tags[index].title),
                                      )
                                    ],
                                  )),
                            ),
                            Offstage(
                              offstage: !showSelect,
                              child: Checkbox(
                                onChanged: (select) {
                                  setState(() {
                                    if (select) {
                                      selected.add(index);
                                    } else {
                                      selected.remove(index);
                                    }
                                  });
                                },
                                value: selected.contains(index),
                              ),
                            )
                          ],
                        ),
                      ), /**/
                    ),
                  ),
                );
              })));
      /* for (Tag tag in tags) {
        list.add();
      }*/
      return DecoratedBox(
        decoration: BoxDecoration(color: Colors.yellow[100]),
        child: Column(
          children: list,
        ),
      );
    }
  }

  doSearch(String searchStr) {
    List<Note> result = new List();
    for (Note tag in allTags) {
      if (tag.title.contains(searchStr) || tag.content.contains(searchStr)) {
        result.add(tag);
      }
    }
    setState(() {
      tags.clear();
      tags.addAll(result);
    });
  }
}
