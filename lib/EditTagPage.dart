import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:notebook/dao/Note.dart';
import 'package:zefyr/zefyr.dart';

class EditTag extends StatefulWidget {
  bool isNew = false;
  Note tag = Note();
  EditTag(this.isNew, this.tag);

  @override
  _EditTagState createState() => _EditTagState(isNew, tag);
}

class _EditTagState extends State<EditTag> {
  ZefyrController _controller;
  FocusNode _focusNode;
  bool isNew = false;
  Note tag = Note();

  _EditTagState(this.isNew, this.tag);

  String _titleError;
  TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (isNew) {
      tag.createTime = DateTime.now().toString();
    }
    final document = (tag.content == null || tag.content.isEmpty)
        ? new NotusDocument()
        : new NotusDocument.fromJson(json.decode(tag.content));
    _controller = new ZefyrController(document);
    _focusNode = new FocusNode();
    _titleController.value = TextEditingValue(text: tag.title ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Text("编辑"),
              ),
              RaisedButton(
                child: Text("保存"),
                onPressed: () {
                  tag.updateTime = DateTime.now().toString();
                  tag.content = json.encode(_controller.document.toJson());
                  tag.title = _titleController.value.text.trim();
                  if (tag.content.isEmpty || tag.title.isEmpty) {
                    setState(() {
                      //if (tag.content.isEmpty) _contentError = "请输入内容";
                      if (tag.title.isEmpty) _titleError = "请输入标题";
                    });
                    return;
                  }
                  Navigator.pop(context, tag);
                },
              )
            ],
          ),
        ),
        body: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                  labelText: "标题", hintText: "请输入标题", errorText: _titleError),
              controller: _titleController,
              maxLines: 1,
            ),
            Expanded(
              flex: 1,
              child: ZefyrScaffold(
                child: ZefyrEditor(
                  controller: _controller,
                  focusNode: _focusNode,
                ),
              ),
            ),
          ],
        ));
  }
}
