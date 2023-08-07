import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/uploadItems.dart';
import 'package:e_shop/Authentication/authenication.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:flutter/material.dart';




class AdminSignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
        title: Text(
          "e-shop",
          style: TextStyle(
              fontSize: 55.0,color: Colors.white,fontFamily: "Signatra"
          ),
        ),
        centerTitle: true,
      ),
      body: AdminSignInScreen(),
    );
  }
}


class AdminSignInScreen extends StatefulWidget {

  @override
  _AdminSignInScreenState createState() => _AdminSignInScreenState();
}

class _AdminSignInScreenState extends State<AdminSignInScreen>
{
  final TextEditingController _adminIDtextEditingController=TextEditingController();
  final TextEditingController _passwordtextEditingController=TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width, _screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400,Colors.blue.shade50],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 0.0),
              stops: [0.0,1.0],
              tileMode: TileMode.clamp,
            )
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                'images/admin.png',
                height: 240.0,
                width: 240.0,
              ),
            ),
            Padding(padding: EdgeInsets.all(8.0),
              child: Text(
                "Admin",
                style: TextStyle(color: Colors.white,fontSize: 28.0,fontWeight: FontWeight.bold),
              ),
            ),
            Form(
              key: _formkey,
              child: Column(
                children: [


                  CustomTextField(
                    controller: _adminIDtextEditingController,
                    data: Icons.person,
                    hintText: "id",
                    isObsecure: false,
                  ),

                  SizedBox(height: 10.0,),

                  CustomTextField(
                    controller: _passwordtextEditingController,
                    data: Icons.lock,
                    hintText: "Password",
                    isObsecure: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 25.0,),
            ElevatedButton(
              onPressed: () {
                _adminIDtextEditingController.text.isNotEmpty &&
                    _passwordtextEditingController.text.isNotEmpty
                    ? loginAdmin()
                    : showDialog(context: context, builder: (c) {
                  return ErrorAlertDialog(
                      message: "Please write email and password.");
                });
              },
              style: ButtonStyle(),
              child: Text("Log in",
                style: TextStyle(color: Colors.blue),),
            ),
            SizedBox(
              height: 50.0,
            ),
            Container(
              height: 4.0,
              width: _screenWidth * 0.8,
              color: Colors.lightGreenAccent,
            ),
            SizedBox(
              height: 20.0,
            ),
            TextButton(onPressed: () =>
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AuthenticScreen())),
              child: Text("i'm not Admin",
                style: TextStyle(
                    color: Colors.pink,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
            SizedBox(height: 50.0,),
          ],
        ),
      ),
    );

  }
  loginAdmin(){
        FirebaseFirestore.instance.collection("admins").get().then((snapshot){
          snapshot.docs.forEach((result) {
            if(result.data()["id"]!=_adminIDtextEditingController.text.trim()){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("your id is not correct.")));
            }
             else if(result.data()["password"]!=_passwordtextEditingController.text.trim()){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("password is not correct.")));
            }
               else{
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Welcome Dear Admin,"+result.data()["name"])));
            setState(() {
              _adminIDtextEditingController.text = "";
              _passwordtextEditingController.text = "";
            });

              Route route = MaterialPageRoute(builder: (c)=>UploadPage());
              Navigator.pushReplacement(context, route);

               }

          });
        });

  }
}
