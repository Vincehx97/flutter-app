import 'package:IVAT/data/userData.dart';
import 'package:IVAT/public_func/PublicFunc.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import '../../global_config.dart' show GlobalConfig; //全局设置
import '../settings_config.dart';
import 'package:data_plugin/bmob/bmob_query.dart';
import '../../data/announce.dart';
import 'package:data_plugin/utils/dialog_util.dart';
import 'package:data_plugin/bmob/response/bmob_error.dart';
import '../../data/message.dart';

class MessageInfo extends StatefulWidget {
  @override
  MessageInfoState createState() => MessageInfoState();
}

final List<ChatMessage> _messages = <ChatMessage>[];

class ChatMessage extends StatelessWidget {
  ChatMessage(
      {this.author, this.title, this.content, this.animationController});

  final AnimationController animationController;
  final String author, title, content;
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            //左对齐
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              //头像
              Container(
                margin: const EdgeInsets.only(right: 20.0),
                child: CircleAvatar(
                    child: Text(author[0], style: TextStyle(fontSize: 20))),
              ),
              //发送内容
              Flexible(
                child: Card(
                    shape: SettingConfig.cardShape,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          //发送内容
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              // Container(
                              //   child:
                              //       Text(title, style: TextStyle(fontSize: 18)),
                              // ),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                child: Text('$content',
                                    style: TextStyle(fontSize: 20)),
                              ),
                            ],
                          ),
                          //昵称
                          Container(
                            child: Text(author, style: TextStyle(fontSize: 13)),
                          ),
                        ],
                      ),
                    )),
              )
            ]));
  }
}

class MessageInfoState extends State<MessageInfo> {
  ///等于条件查询
  void _queryWhereEqual(BuildContext context) {
    BmobQuery<Message> query = BmobQuery();
    query.addWhereEqualTo("username", UsrData.usrName);
    query.queryObjects().then((data) {
      PublicFunc.loading = false;
      setState(() {});
      // showSuccess(context, data.toString());
      List<Message> messages = data.map((i) => Message.fromJson(i)).toList();
      for (Message msg in messages) {
        if (msg != null) {
          setState(() {
            _messages.insert(
                0, ChatMessage(author: msg.author, content: msg.content));
          });
        }
      }
    }).catchError((e) {
      PublicFunc.loading = false;
      setState(() {});
      showError(context, BmobError.convert(e).error);
    });
  }

  @override
  void initState() {
    super.initState();
    PublicFunc.loading = true;
    _queryWhereEqual(context);
  }

  @override
  void dispose() {
    super.dispose();
    _messages.clear();
  }

  Widget mainScreen(BuildContext context) {
    return new PublicFunc().show(
        context,
        Container(
          margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            children: <Widget>[
              Flexible(
                child: ListView.builder(
                  reverse: false,
                  itemBuilder: (_, int index) => _messages[index],
                  itemCount: _messages.length,
                ),
              )
            ],
          ),
        ),
        '加载中');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: GlobalConfig.themeData,
      home: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text('消息'),
          leading: IconButton(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            color: Colors.white,
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              PublicFunc.back(context, {});
            },
          ),
        ),
        body: mainScreen(context),
      ),
    );
  }
}
