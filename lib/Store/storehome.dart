import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Store/cart.dart';
import 'package:e_shop/Store/product_page.dart';
import 'package:e_shop/Counters/cartitemcounter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:e_shop/Config/config.dart';
import '../Widgets/loadingWidget.dart';
import '../Widgets/myDrawer.dart';
import '../Widgets/searchBox.dart';
import '../Models/item.dart';

double? width;

class StoreHome extends StatefulWidget {
  @override
  _StoreHomeState createState() => _StoreHomeState();
}

class _StoreHomeState extends State<StoreHome> {
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400,Colors.blue.shade50],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(1.0, 0.0),
                  stops: [0.0,1.0],
                  tileMode: TileMode.clamp,
                )
            ),
          ),
          title: Text(
            "e-shop",
            style: TextStyle(
                fontSize: 55.0,color: Colors.white,fontFamily: "Signatra"
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(onPressed:(){
              showSearch(context: context, delegate: SearchBoxDelegate())
            },
            icon: Icon(Icons.search)
            ),
            Stack(
              children: [
                IconButton(onPressed: (){
                  Route route = MaterialPageRoute(builder: (c)=>CartPage());
                  Navigator.pushReplacement(context, route);
                }, icon: Icon(Icons.shopping_cart,color: Colors.blueGrey,)

                ),
                Positioned(child: Stack(
                  children: [
                    Icon(
                      Icons.brightness_1,
                      size: 20.0,
                      color: Colors.green,
                    )    ,
                  Positioned(
                    top: 3.0,
                    bottom: 4.0,
                    left: 3.5,
                    child: Consumer<CartItemCounter>(
                      builder: (context,counter,_){
                        var txt = counter.count!-1;
                        return Text(
                          txt.toString(),
                          style: TextStyle(color: Colors.white,fontSize: 12.0,fontWeight: FontWeight.w500),
                        );
                      },
                    ),
                  )
                  ],
                ))
              ],
            )
          ],
        ),
        drawer: MyDrawer(),
        body: Column(
          children: [
            Column(
              children: [
                // SliverPersistentHeader(
                //   pinned: true,
                //     delegate: SearchBoxDelegate(),
                // ),
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection("items").limit(15).orderBy("publishedDate",descending: true).snapshots(),
                    builder: (context,dataSnapshot){
                      return dataSnapshot.hasData
                          ?Center(child: circularProgress(),)
                          :ListView.builder(
                          itemBuilder: (context,index){
                            ItemModel model = ItemModel.fromJson(dataSnapshot.data!.docs[index].data() as Map<String, dynamic> );
                            return sourceInfo(model, context);
                          },
                        itemCount: dataSnapshot.data?.docs.length,

                      );
                    }

                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}



Widget sourceInfo(ItemModel model, BuildContext context,
    {Color? background, removeCartFunction}) {
  return InkWell(
    splashColor: Colors.green,
    child: Padding(
      padding: EdgeInsets.all(6.0),
      child:Container(
        height: 190.0,
        width: width,
        child: Row(
          children: [
            Image.network(model.thumbnailUrl,width: 140.0,height: 140.0,),
            SizedBox(width: 4.0,),
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 15.0,),
                    Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                              child: Text(model.title,style: TextStyle(color: Colors.black,fontSize: 14.0),)
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 5.0,),
                    Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                              child: Text(model.shortInfo,style: TextStyle(color: Colors.black54,fontSize: 12.0),)
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 20.0,),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.green
                          ),
                          alignment: Alignment.topLeft,
                          width: 40.0,
                          height: 43.0,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    "50%",
                                  style: TextStyle(fontSize: 15.0,color: Colors.white,fontWeight: FontWeight.normal),

                                ),
                                Text(
                                    "OFF%",
                                  style: TextStyle(fontSize: 12.0,color: Colors.white,fontWeight: FontWeight.normal),

                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 0.0),
                              child: Row(
                                children: [
                                  Text(
                                    r"Original Price: $",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  Text(
                                    (model.price + model.price).toString(),
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.grey,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 5.0),
                              child: Row(
                                children: [
                                  Text(
                                    r"New Price: $",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.grey,
                                    ),
                                  ),

                                  Text(
                                    (model.price).toString(),
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.grey,
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    Flexible(
                        child: Container(),
                    )

                    //to implement the cart item remove feature
                  ],
                )

            )
          ],
        ),
      ) ,
    ),
  );
}



Widget card({Color primaryColor = Colors.redAccent,required String imgPath}) {
  return Container();
}



void checkItemInCart(String productID, BuildContext context)
{
}
