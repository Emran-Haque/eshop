import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/adminShiftOrders.dart';
import 'package:e_shop/Widgets/loadingWidget.dart';
import 'package:e_shop/main.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as ImD;


class UploadPage extends StatefulWidget
{
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> with AutomaticKeepAliveClientMixin<UploadPage>
{
  bool get wantKeepAlive => true;
  File? file;
  TextEditingController _descriptionTextEditingController = TextEditingController();
  TextEditingController _priceTextEditingController = TextEditingController();
  TextEditingController _tittleTextEditingController = TextEditingController();
  TextEditingController _shortTextEditingController = TextEditingController();
  String productId = DateTime.now().millisecondsSinceEpoch.toString();
  bool uploading = false;

  @override
  Widget build(BuildContext context) {
    return file == null?displayAdminHomeScreen():displayAdminUploadFormScreen();
  }
  displayAdminHomeScreen(){
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: new BoxDecoration(
              gradient: new LinearGradient(
                colors: [Colors.blue.shade400,Colors.blue.shade50],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 0.0),
                stops: [0.0,1.0],
                tileMode: TileMode.clamp,
              )
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.border_color,color: Colors.white,),
          onPressed: (){
            Route route = MaterialPageRoute(builder: (c)=>AdminShiftOrders());
            Navigator.pushReplacement(context, route);
          },
        ),
        actions: [
          TextButton(onPressed: (){
            Route route = MaterialPageRoute(builder: (c)=>SplashScreen());
            Navigator.pushReplacement(context, route);
          }, child: Text(
            "Logout",
            style: TextStyle(color: Colors.white,fontSize: 16.0,fontWeight: FontWeight.bold),
          ))
        ],
      ),
      body: getAdminHomeScreenBody(),
    );
  }
  getAdminHomeScreenBody(){
    return Container(
      decoration: new BoxDecoration(
          gradient: new LinearGradient(
            colors: [Colors.blue.shade400,Colors.blue.shade50],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(1.0, 0.0),
            stops: [0.0,1.0],
            tileMode: TileMode.clamp,
          )
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.shop_two,color: Colors.white,size: 200.0),
            Padding(
                padding: EdgeInsets.only(top: 20.0),
              child: ElevatedButton(
                //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.0)),
                child: Text("Add New Items",style: TextStyle(fontSize: 20.0,color: Colors.white),),
                onPressed: ()=>takeImage(context),
              ),
            
            )
          ],
        ),
      ),
    );
  }

  takeImage(mContext){
    return showDialog(
        context: mContext,
        builder: (con){
          return SimpleDialog(
            title: Text("Item Image",style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold),),
            children: [
              SimpleDialogOption(
                child: Text("Capture with Camera",style: TextStyle(color: Colors.green),),
                onPressed: capturePhotoWithCamera,
              ),
              SimpleDialogOption(
                child: Text("Select From Gallery",style: TextStyle(color: Colors.green),),
                onPressed: pickPhotoFromGallery,
              ),
                   SimpleDialogOption(
                child: Text("Cancel",style: TextStyle(color: Colors.green),),
                onPressed: (){
                  Navigator.pop(context);
                },
              ),


            ],
          );
        }
    );
  }
  capturePhotoWithCamera() async{
    Navigator.pop(context);
   final XFile? image = await ImagePicker().pickImage(source: ImageSource.camera,maxHeight: 680.0,maxWidth: 970.0);
   final File? imageFile = File(image!.path);
   setState(() {
     file = imageFile;
   });
  }
  pickPhotoFromGallery() async{
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    final File? imageFile = File(image!.path);
    setState(() {
      file = imageFile;
    });
  }
  displayAdminUploadFormScreen(){
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: new BoxDecoration(
              gradient: new LinearGradient(
                colors: [Colors.blue.shade400,Colors.blue.shade50],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 0.0),
                stops: [0.0,1.0],
                tileMode: TileMode.clamp,
              )
          ),
        ),
        leading: IconButton(icon: Icon(Icons.arrow_back,color: Colors.white,),onPressed: clearFormInfo,),
        title: Text("New Product",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 24.0),),
        actions: [
          TextButton(
              onPressed: uploading?null:()=> uploadImageAndSaveItemInfo(),
              child: Text("Add",
              style: TextStyle(color: Colors.green,fontSize: 16.0,fontWeight: FontWeight.bold),
              )
          )
        ],
      ),
      body: ListView(
          children: [
            uploading?linearProgress():Text(""),
            Container(
              height: 230.0,
              width: MediaQuery.of(context).size.width*0.8,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 16/9,
                  child: Container(
                    decoration: BoxDecoration(image: DecorationImage(image: FileImage(file!),fit: BoxFit.cover)),
                  ),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 12.0)),
            ListTile(
              leading: Icon(Icons.perm_device_information,color: Colors.lightGreenAccent,),
              title: Container(
                width: 250.0,
                child: TextField(
                  style: TextStyle(color: Colors.deepPurpleAccent),
                  controller: _shortTextEditingController,
                  decoration: InputDecoration(
                    hintText: "Short Info",
                    hintStyle: TextStyle(color: Colors.deepPurpleAccent),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            Divider(color: Colors.lightGreenAccent,),
            ListTile(
              leading: Icon(Icons.perm_device_information,color: Colors.lightGreenAccent,),
              title: Container(
                width: 250.0,
                child: TextField(
                  style: TextStyle(color: Colors.deepPurpleAccent),
                  controller: _tittleTextEditingController,
                  decoration: InputDecoration(
                    hintText: "Tittle",
                    hintStyle: TextStyle(color: Colors.deepPurpleAccent),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            Divider(color: Colors.lightGreenAccent,),
            ListTile(
              leading: Icon(Icons.perm_device_information,color: Colors.lightGreenAccent,),
              title: Container(
                width: 250.0,
                child: TextField(
                  style: TextStyle(color: Colors.deepPurpleAccent),
                  controller: _descriptionTextEditingController,
                  decoration: InputDecoration(
                    hintText: "Description",
                    hintStyle: TextStyle(color: Colors.deepPurpleAccent),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            Divider(color: Colors.lightGreenAccent,),
            ListTile(
              leading: Icon(Icons.perm_device_information,color: Colors.lightGreenAccent,),
              title: Container(
                width: 250.0,
                child: TextField(
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Colors.deepPurpleAccent),
                  controller: _priceTextEditingController,
                  decoration: InputDecoration(
                    hintText: "Price",
                    hintStyle: TextStyle(color: Colors.deepPurpleAccent),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

          ],
      ),
    );
  }
  clearFormInfo(){
      setState(() {
        file = null;
        _descriptionTextEditingController.clear();
        _priceTextEditingController.clear();
        _shortTextEditingController.clear();
        _tittleTextEditingController.clear();
      });
  }
  uploadImageAndSaveItemInfo()async{
    setState(() {
      uploading = true;
    });
    String imageDownloadUrl= await uploadItemImage(file);
    saveItemInfo(imageDownloadUrl);
  }

  Future<String> uploadItemImage(mfile) async{
    final Reference storageReference = FirebaseStorage.instance.ref().child("Items");
    UploadTask uploadTask = storageReference.child("product_$productId.jpg").putFile(mfile);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }
  saveItemInfo(String downloadUrl){
    final itemsRef = FirebaseFirestore.instance.collection("items");
    itemsRef.doc(productId).set({
        "shortInfo": _shortTextEditingController.text.trim(),
        "longDescription": _descriptionTextEditingController.text.trim(),
        "title": _tittleTextEditingController.text.trim(),
        "publishedDate": DateTime.now(),
        "thumbnailUrl": downloadUrl,
        "status": "available",
        "price": int.parse(_priceTextEditingController.text.trim()),
    });
    setState(() {
      file = null;
      uploading = false;
      productId = DateTime.now().millisecondsSinceEpoch.toString();
      _descriptionTextEditingController.clear();
      _tittleTextEditingController.clear();
      _shortTextEditingController.clear();
      _priceTextEditingController.clear();
    });

  }
  
  
}
