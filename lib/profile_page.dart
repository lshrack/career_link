import 'package:career_find/database.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'dart:async';
import 'database.dart';

//This shows the user's profile page, allowing them to edit their information
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Person whoami;
  bool personSet;
  String name;
  String profession;
  String email;
  String phoneNumber;
  String company;
  String education;

  //These control the text editing fields for user information
  TextEditingController nameCtrl;
  TextEditingController professionCtrl;
  TextEditingController emailCtrl;
  TextEditingController phoneCtrl;
  TextEditingController companyCtrl;
  TextEditingController educationCtrl;

  @override
  Widget build(BuildContext context) {
    //This sets the fields to the user's saved information
    if (whoami != null) {
      nameCtrl.text = whoami.name;
      phoneCtrl.text = whoami.phoneNumber;
      emailCtrl.text = whoami.email;
      companyCtrl.text = whoami.company;
      professionCtrl.text = whoami.profession;
      educationCtrl.text = whoami.education;
    }
    //This Scaffold represents the profile screen
    return Scaffold(
        appBar: AppBar(title: Text("My Profile")),
        body: SingleChildScrollView(
            child: Column(
          children: [
            //Each text field can be used to edit a different piece of user information
            Padding(
                child: TextField(
                  buildCounter: (context,
                      {currentLength, isFocused, maxLength}) {
                    return Text("NAME");
                  },
                  controller: nameCtrl,
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10)),
            Padding(
                child: TextField(
                  buildCounter: (context,
                      {currentLength, isFocused, maxLength}) {
                    return Text("PROFESSION");
                  },
                  controller: professionCtrl,
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10)),
            Padding(
                child: TextField(
                  buildCounter: (context,
                      {currentLength, isFocused, maxLength}) {
                    return Text("EMAIL");
                  },
                  controller: emailCtrl,
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10)),
            Padding(
                child: TextField(
                  buildCounter: (context,
                      {currentLength, isFocused, maxLength}) {
                    return Text("PHONE NUMBER");
                  },
                  controller: phoneCtrl,
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10)),
            Padding(
                child: TextField(
                  buildCounter: (context,
                      {currentLength, isFocused, maxLength}) {
                    return Text("COMPANY");
                  },
                  controller: companyCtrl,
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10)),
            Padding(
                child: TextField(
                  buildCounter: (context,
                      {currentLength, isFocused, maxLength}) {
                    return Text("EDUCATION");
                  },
                  controller: educationCtrl,
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10)),
            //The button will save the user's changes and update them in the local database
            FlatButton(
                child: Text("SAVE CHANGES"),
                onPressed: () {
                  whoami.name = nameCtrl.text;
                  whoami.profession = professionCtrl.text;
                  whoami.company = companyCtrl.text;
                  whoami.email = emailCtrl.text;
                  whoami.phoneNumber = phoneCtrl.text;
                  whoami.education = educationCtrl.text;

                  DatabaseMethods.editItem(
                      Globals.personDbInstance, whoami.toEntry());
                })
          ],
        )));
  }

  @override
  void initState() {
    personSet = false;
    setPerson();
    nameCtrl = TextEditingController();
    professionCtrl = TextEditingController();
    emailCtrl = TextEditingController();
    phoneCtrl = TextEditingController();
    companyCtrl = TextEditingController();
    educationCtrl = TextEditingController();
    super.initState();
  }

  //When the page is opened, this method will go into the database and find the
  //user information to fill the text fields
  void setPerson() async {
    List<Person> people =
        await DatabaseMethods.readAllAsPerson(Globals.personDbInstance);

    if (people.length != 0) {
      whoami = people[0];
    }
    //If the database hasn't been populated with anything, save an empty Person object instead
    else {
      whoami = Person(
          name: "",
          email: "",
          profession: "",
          phoneNumber: "",
          company: "",
          education: "");
      whoami.id = await DatabaseMethods.save(
          whoami.toEntry(), Globals.personDbInstance);
      print("Saved whoami to the database");
    }

    setState(() {});
  }
}
