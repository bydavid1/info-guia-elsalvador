import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/material.dart';
import 'model.dart';
import 'dart:async';
import 'package:http/http.dart' as http;


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  build(context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Http App',
      theme: ThemeData(
        primarySwatch: Colors.green,
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

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async{
    // monitor network fetch
    getPosts('http://192.168.0.13/infoapi/empresa/read.php');
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    _refreshController.loadComplete();
  }
  //----------------------------Funcion para obtener los datos
  void getPosts(String url) async{
      final response = await http.get(url);
      if(response.statusCode == 200) {
      setState(() {
        Iterable list = json.decode(response.body);
        posts = list.map((model) =>Post.fromJson(model)).toList();
      });
      } else if (response.statusCode == 204) {
        _showDialog(context, "Error", "No se encontraron datos", "Ok");
      }else {
        _showDialog(context, "Error", "Ocurrio un error", "Ok");
      }
  }
  //----------------------------Funcion para mostrar una alerta
  void _showDialog(BuildContext context, String title, String content, String button) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: new Text(content),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(button),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

Widget makeCard(BuildContext context, int index){
  return
   Card(
      margin: new EdgeInsets.symmetric(horizontal: 0.0, vertical: 6.0),
        child: ListTile(
          title: Container(
                child: Image.network(
                  posts[index].portada,
                  fit: BoxFit.cover,
                ),
              ),
              subtitle: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                         margin: new EdgeInsets.only(top: 10.0, left: 5.0),
                          child: Text(posts[index].titulo, style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600, fontFamily: 'ABeeZee'), softWrap: false, overflow: TextOverflow.ellipsis, maxLines: 3,),
                  ),
                  Container(
                         margin: new EdgeInsets.only(top: 5.0, left: 5.0),
                          child: Text(posts[index].descripcion, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black54, fontFamily: 'ABeeZee'), softWrap: true, overflow: TextOverflow.ellipsis, maxLines: 3,),
                  ),
                  Container(
                      margin: new EdgeInsets.only(top: 5.0),
                      child:  Row(
                          children: <Widget>[
                            new Column(
                              children: <Widget>[ 
                                Icon(
                                  Icons.location_on,
                                  size: 20.0,
                                  color: Colors.red
                                )
                              ],
                            ),
                            new Column(
                              children: <Widget>[
                                Text(posts[index].ubicacion, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black54), softWrap: true, overflow: TextOverflow.fade, maxLines: 3,)
                              ],
                            )
                          ],
                        ),
                  )
                ],
              )
          ),
   );
}

  initState() {
    super.initState();
    getPosts('http://192.168.0.13/infoapi/empresa/read.php');
  }

  @override
  build(context) {
        return Scaffold(
          backgroundColor: Color.fromRGBO(240, 240, 240, 1),
        body: Container(
          child: new SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: WaterDropMaterialHeader(),
        footer: CustomFooter(
          builder: (BuildContext context,LoadStatus mode){
            Widget body ;
            if(mode==LoadStatus.idle){
              body =  Text("pull up load");
            }
            else if(mode==LoadStatus.loading){
              body =  CupertinoActivityIndicator();
            }
            else if(mode == LoadStatus.failed){
              body = Text("Load Failed!Click retry!");
            }
            else if(mode == LoadStatus.canLoading){
                body = Text("release to load more");
            }
            else{
              body = Text("No more Data");
            }
            return Container(
              height: 55.0,
              child: Center(child:body),
            );
          },
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (BuildContext context, int index) {
          return makeCard(context, index);
        },
      ),
      ),)
    );
  }
}
