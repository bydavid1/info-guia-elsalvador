import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/material.dart';
import 'detailPage.dart';
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

var cardAspectRatio = 12.0 / 16.0;
var widgetAspectRatio = cardAspectRatio * 1.2;
 var posts = new List<Post>();

class MyListScreen extends StatefulWidget {
  @override
  createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> with SingleTickerProviderStateMixin {
  TabController _controller;

  RefreshController _refreshController =
 RefreshController(initialRefresh: false);

  void _onRefresh() async{
    getPosts('http://192.168.0.13/infoapi/empresa/read.php');
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
        setState(() {
         _showDialog(context, "Error", "No se encontraron datos", "Ok");
        });
      }else {
        setState(() {
         _showDialog(context, "Error", "Ocurrio un error", "Ok");
        });
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
        _controller = new TabController(length: 2, vsync: this);
  }
   var currentPage = 1 + 1.0;
  @override
  build(context) {

      PageController controller = PageController(initialPage: posts.length - 1);
    controller.addListener(() {
      setState(() {
        currentPage = controller.page;
      });
    });
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
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
               Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Cerca de ti",
                        style: TextStyle(
                          fontSize: 30.0,
                          letterSpacing: 1.0,
                        )),
                  ],
                ),
              ),
              Stack(
                children: <Widget>[
                  CardScrollWidget(currentPage),
                  Positioned.fill(
                    child: PageView.builder(
                      itemCount: posts.length,
                      controller: controller,
                      reverse: true,
                      itemBuilder: (context, index) {
                        return Container();
                      },
                    ),
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Destacados",
                        style: TextStyle(
                          fontSize: 30.0,
                          letterSpacing: 1.0,
                        )),
                  ],
                ),
              ),
            new Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: new TabBar(
              indicatorColor: Colors.green,
              labelColor: Colors.green,
              controller: _controller,
              tabs: [
                new Tab(
                  text: 'Destacados',
                ),
                new Tab(
                  text: 'Favoritos',
                ),
              ],
            ),
          ),
           new Container(
             height: 100,
            child: new TabBarView(
              controller: _controller,
              children: <Widget>[
               new Container(
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
      ),
      ),
                new Card(
                  child: new ListTile(
                    leading: const Icon(Icons.location_on),
                    title: new Text('Latitude: 48.09342\nLongitude: 11.23403'),
                    trailing: new IconButton(icon: const Icon(Icons.my_location), onPressed: () {}),
                  ),
                ),
              ],
            ),
          ),
            ],
          ),
        )
    );
  }
}

class CardScrollWidget extends StatelessWidget {
  var currentPage;
  var padding = 20.0;
  var verticalInset = 20.0;

  CardScrollWidget(this.currentPage);

  @override
  Widget build(BuildContext context) {
    return new AspectRatio(
      aspectRatio: widgetAspectRatio,
      child: LayoutBuilder(builder: (context, contraints) {
        var width = contraints.maxWidth;
        var height = contraints.maxHeight;

        var safeWidth = width - 2 * padding;
        var safeHeight = height - 2 * padding;

        var heightOfPrimaryCard = safeHeight;
        var widthOfPrimaryCard = heightOfPrimaryCard * cardAspectRatio;

        var primaryCardLeft = safeWidth - widthOfPrimaryCard;
        var horizontalInset = primaryCardLeft / 2;

        List<Widget> cardList = new List();

        for (var i = 0; i < posts.length; i++) {
          var delta = i - currentPage;
          bool isOnRight = delta > 0;

          var start = padding +
              max(
                  primaryCardLeft -
                      horizontalInset * -delta * (isOnRight ? 15 : 1),
                  0.0);

          var cardItem = Positioned.directional(
            top: padding + verticalInset * max(-delta, 0.0),
            bottom: padding + verticalInset * max(-delta, 0.0),
            start: start,
            textDirection: TextDirection.rtl,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      offset: Offset(3.0, 6.0),
                      blurRadius: 10.0)
                ]),
                child: AspectRatio(
                  aspectRatio: cardAspectRatio,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      Image.network(posts[i].portada, fit: BoxFit.cover),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Text(posts[i].titulo,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 25.0,)),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 12.0, bottom: 12.0),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 22.0, vertical: 6.0),
                                decoration: BoxDecoration(
                                    color: Colors.blueAccent,
                                    borderRadius: BorderRadius.circular(20.0)),
                                child: Text("Ver informacion",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
          cardList.add(cardItem);
        }
        return Stack(
          children: cardList,
        );
      }),
    );
  }
}
  