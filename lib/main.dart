import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/material.dart';
import 'detailPage.dart';
import 'model.dart';
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
  RefreshController _refreshController = RefreshController(initialRefresh: false);

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
              Container(child: Icon(Icons.search), margin: EdgeInsets.only(right: 10.0),)
            ],
            ),
          backgroundColor: Color.fromRGBO(240, 240, 240, 1),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
               Container(
                 margin: EdgeInsets.only(bottom: 20.0, top: 20.0, left: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Recomendados",
                        style: TextStyle(
                          fontSize: 20.0,
                          letterSpacing: 1.0,
                        )),
                  ],
                ),
              ),
              Stack(
                children: <Widget>[
                  Container(
                    child: _buildCarousel()
                  )
                ],
              ),
               Container(
                 margin: EdgeInsets.only(bottom: 20.0, top: 20.0, left: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Destacados",
                        style: TextStyle(
                          fontSize: 20.0,
                          letterSpacing: 1.0,
                        )),
                  ],
                ),
              ),
            new Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: new TabBar(
              isScrollable: false,
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
             height: 500,
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
                    title: new Text('No se encontraron favoritos'),
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
  

Widget _buildCarousel() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          // you may want to use an aspect ratio here for tablet support
          height: 200.0,
          child: PageView.builder(
            // store this controller in a State to save the carousel scroll position
            controller: PageController(viewportFraction: 0.8),
            itemCount: posts.length,
            itemBuilder: (BuildContext context, int itemIndex) {
              return _buildCarouselItem(context, itemIndex);
            },
          ),
        )
      ],
    );
  }
  
   Widget _buildCarouselItem(BuildContext context, int index) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
        child: Container(
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
                      Image.network(posts[index].portada, fit: BoxFit.cover),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Text(posts[index].titulo,
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
          ),
    );
  }


  void _onRefresh() async{
    getPosts('http://192.168.0.17/infoapi/empresa/read.php');
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
              tag: posts[index].idempresa,
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
    getPosts('http://192.168.0.17/infoapi/empresa/read.php');
        _controller = new TabController(length: 2, vsync: this);
  }
}

