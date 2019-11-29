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
      title: 'Infoguia El Salvador',
      theme: ThemeData(
        fontFamily: 'ABeeZee'
      ),
      home: MyListScreen(),
    );
  }
}

class MyListScreen extends StatefulWidget {
  @override
  createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> {
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
        return AlertDialog(
          title: new Text(title),
          content: new Text(content),
          actions: <Widget>[
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
                child: Hero(
              tag: posts[index].portada,
                child: Image.network(
                  posts[index].portada,
                  fit: BoxFit.fill,
                ),
            ),
              ),
              subtitle: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                         margin: new EdgeInsets.only(top: 10.0, left: 5.0),
                          child: Text(posts[index].titulo, style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600,), softWrap: false, overflow: TextOverflow.ellipsis, maxLines: 3,),
                  ),
                  Container(
                         margin: new EdgeInsets.only(top: 5.0, left: 5.0),
                          child: Text(posts[index].descripcion, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black54,), softWrap: true, overflow: TextOverflow.ellipsis, maxLines: 3,),
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
              ),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(posts: posts[index],)));
              },
          ),
          elevation: 0.0,
   );
}

  initState() {
    super.initState();
    getPosts('http://192.168.0.13/infoapi/empresa/read.php');
  }

  @override
  build(context) {
        return Scaffold(
          appBar: new AppBar(
            elevation: 0.0,
            backgroundColor: Colors.green[600],
            title: Text('Infoguia El Salvador'), 
            centerTitle: true,
            actions: <Widget>[
              Icon(Icons.search)
            ],
            ),
          backgroundColor: Color.fromRGBO(240, 240, 240, 1),
        body: Container(
          child: new SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: WaterDropMaterialHeader(backgroundColor: Colors.green[600],),
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

class DetailPage extends StatefulWidget {

  DetailPage({Key key, @required this.posts}) : super(key: key);
  final Post posts;

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            height: 300,
            child: Hero(
              tag: '${widget.posts.portada}',
              child: Image.network(
                widget.posts.portada,
                fit: BoxFit.cover,
              ),
            ),
          ),
                    CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                backgroundColor: Colors.transparent,
                actions: <Widget>[
                  PopupMenuButton<String>(
                    onSelected: (String item) { },
                    itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                      _buildMenuItem(Icons.share, 'Tweet recipe'),
                      _buildMenuItem(Icons.people, 'Share on Facebook'),
                    ],
                  ),
                ],
                flexibleSpace: const FlexibleSpaceBar(
                  background: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0.0, -1.0),
                        end: Alignment(0.0, -0.2),
                        colors: <Color>[Color(0x60000000), Color(0x00000000)],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      )
    );
  }

    PopupMenuItem<String> _buildMenuItem(IconData icon, String label) {
    return PopupMenuItem<String>(
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Icon(icon, color: Colors.black54),
          ),
          Text(label),
        ],
      ),
    );
  }
}
