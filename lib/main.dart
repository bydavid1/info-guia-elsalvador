import 'dart:convert';
import 'package:flutter/material.dart';
import 'model.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class Api{
  static Future getPosts() async{
  return await http.get('http://192.168.0.13/infoapi/empresa/read.php');

  }//getPosts
}


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  build(context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Http App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyListScreen(),
    );
  }
}

class MyListScreen extends StatefulWidget {
  @override
  createState() => _MyListScreenState();
}

class _MyListScreenState extends State {
  var posts = new List<Post>();

  _getPosts() {
    Api.getPosts().then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        posts = list.map((model) => Post.fromJson(model)).toList();
      });
    });
  }

  initState() {
    super.initState();
    _getPosts();
  }

  dispose() {
    super.dispose();
  }

   ListTile _buildItemsForListView(BuildContext context, int index) {
      return ListTile(
            title: posts[index].portada == null ? null : Image.network(posts[index].portada) ,
            subtitle: Text(posts[index].descripcion),
      );
  }

  @override
  build(context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Post List"),
        ),
        body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (BuildContext context, int index) {
          return new Container(
            child: new Center(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  new Card(
                    child: new Container(
                      child: ListTile(title: posts[index].portada == null ? null : Image.network(posts[index].portada) ,
                      subtitle: Text(posts[index].titulo),),
                      padding: EdgeInsets.all(20),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),);
  }
}