//import 'dart:html';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/DialogBox/loadingDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Store/storehome.dart';
import 'package:e_shop/Config/config.dart';



class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}



class _RegisterState extends State<Register>
{
  final TextEditingController _nametextEditingController=TextEditingController();
  final TextEditingController _emailtextEditingController=TextEditingController();
  final TextEditingController _passwordtextEditingController=TextEditingController();
  final TextEditingController _cpasswordtextEditingController=TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  String userImageUrl = "";
  File? _imageFile;



  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width, _screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(height: 10.0,),
            InkWell(
              onTap: _selectAndPickImage,
              child: CircleAvatar(
                radius: _screenWidth*0.15,
                backgroundColor: Colors.white,
                backgroundImage: _imageFile==null?null:FileImage(_imageFile!),
                child: Icon(Icons.add_a_photo,size: _screenWidth*0.15,color: Colors.grey,)
              ),
            ),
            SizedBox(height: 8.0,),
            Form(
              key: _formkey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _nametextEditingController,
                    data: Icons.person,
                    hintText: "Name",
                    isObsecure: false,
                  ),
                  SizedBox(height: 10.0,),

                  CustomTextField(
                    controller: _emailtextEditingController,
                    data: Icons.email,
                    hintText: "Email",
                    isObsecure: false,
                  ),

                  SizedBox(height: 10.0,),

                      CustomTextField(
                    controller: _passwordtextEditingController,
                    data: Icons.lock,
                    hintText: "Password",
                    isObsecure: true,
                  ),
                  SizedBox(height: 10.0,),
                      CustomTextField(
                    controller: _cpasswordtextEditingController,
                    data: Icons.lock,
                    hintText: "Confirm Password",
                    isObsecure: true,
                  ),

                ],
              ),
            ),

            SizedBox(height: 30.0,),

            ElevatedButton(
                onPressed:(){
                  uploadAndSaveImage();
                },
                style: ButtonStyle(),
                child: Text("Sign up",
                style: TextStyle(color: Colors.blue),),
            ),
            SizedBox(
              height: 30.0,
            ),
            Container(
              height: 4.0,
              width: _screenWidth*0.8,
              color: Colors.lightGreenAccent,
            ),
            SizedBox(
              height: 15.0,
            )
          ],
        ),
      ),
    );
  }

  void _selectAndPickImage() async{
    final ImagePicker _picker = ImagePicker();
    XFile?  _File = await _picker.pickImage(source: ImageSource.gallery);
    final File? file = File(_File!.path);
    setState(() async {
      _imageFile = file;
    });
    print("Picked");
  }


  Future<void> uploadAndSaveImage() async{
    if(_imageFile==null){
      showDialog(context: context, builder: (c){
        return ErrorAlertDialog(message: "Please select an image file.",);
      });
    }
    else{
      _passwordtextEditingController.text==_cpasswordtextEditingController.text
          ? _emailtextEditingController.text.isNotEmpty
          && _passwordtextEditingController.text.isNotEmpty
          && _cpasswordtextEditingController.text.isNotEmpty
          && _nametextEditingController.text.isNotEmpty
          ? uploadToStorage()
          :displayDialog("Please write the right information")
          :displayDialog("Password does not match");
    }
  }

  displayDialog(String msg){
    showDialog(context: context, builder: (c){
      return ErrorAlertDialog(message: msg,);
    });
  }


  uploadToStorage() async{
    showDialog(context: context, builder: (c){
        return LoadingAlertDialog(message: "Please wait...",);
    });
    String imageFileName = DateTime.now().millisecondsSinceEpoch.toString();
   Reference storageReference = FirebaseStorage.instance.ref().child(imageFileName);
   UploadTask storageUploadTask = storageReference.putFile(_imageFile!);
    TaskSnapshot taskSnapshot = await storageUploadTask;
   await taskSnapshot.ref.getDownloadURL().then((urlImage){
       userImageUrl = urlImage;
        _registerUser();
   });
  }

  FirebaseAuth _auth = FirebaseAuth.instance;
  void _registerUser() async{
    User? firebaseUser;
    await _auth.createUserWithEmailAndPassword(email: _emailtextEditingController.text.trim(),
        password: _passwordtextEditingController.text.trim()
    ).then((auth){
      firebaseUser = auth.user!;
    }).catchError((error){
      Navigator.pop(context);
      showDialog(context: context, builder: (c){
        return ErrorAlertDialog(message: error.message.toString(),);
      });
    });
    if(firebaseUser != null){
      saveUserInfoFireStore(firebaseUser!).then((value){
        Navigator.pop(context);
        Route route = MaterialPageRoute(builder: (c)=>StoreHome());
        Navigator.pushReplacement(context, route);
      });
    }
  }
  Future saveUserInfoFireStore(User fUser)async{
    FirebaseFirestore.instance.collection("users").doc(fUser.uid).set({
      "uid":fUser.uid,
      "email":fUser.email,
      "name":_nametextEditingController.text.trim(),
      "url": userImageUrl,                                                                                        //commented
    EcommerceApp.userCartList: ["garbageValue"],
    });
    await EcommerceApp.sharedPreferences?.setString("uid", fUser.uid);
    await EcommerceApp.sharedPreferences?.setString(EcommerceApp.userEmail, fUser.email!);
    await EcommerceApp.sharedPreferences?.setString(EcommerceApp.userName, _nametextEditingController.text);
    await EcommerceApp.sharedPreferences?.setString(EcommerceApp.userAvatarUrl, userImageUrl);                           //commented
    await EcommerceApp.sharedPreferences?.setStringList(EcommerceApp.userCartList, ["garbageValue"]);
  }


}

