import 'package:flutter/material.dart';
import 'main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

//This class displays profile information for a given person
class PersonPage extends StatefulWidget {
  //The class constructor accepts a Person object
  final Person person;
  PersonPage(this.person);
  @override
  _PersonPageState createState() => _PersonPageState();
}

class _PersonPageState extends State<PersonPage> {
  @override
  Widget build(BuildContext context) {
    TextStyle genStyle = TextStyle(
      fontSize: 18,
    );
    //The class returns a scaffold showing the appropriate screen
    return Scaffold(
        appBar: AppBar(title: Text(widget.person.name)),
        body: Padding(
            child: Column(
              children: [
                Padding(
                    child: Text("Profession: ${widget.person.profession}",
                        style: genStyle),
                    padding: EdgeInsets.all(5)),
                Padding(
                    child:
                        Text("Email: ${widget.person.email}", style: genStyle),
                    padding: EdgeInsets.all(5)),
                Padding(
                    child: Text("Phone Number: ${widget.person.phoneNumber}",
                        style: genStyle),
                    padding: EdgeInsets.all(5)),
                Padding(
                    child: Text("Company: ${widget.person.company}",
                        style: genStyle),
                    padding: EdgeInsets.all(5)),
                Padding(
                    child: Text("Education: ${widget.person.education}",
                        style: genStyle),
                    padding: EdgeInsets.all(5)),
                //If the person has an instagram account, display the button
                widget.person.instagram != ""
                    ? Padding(
                        //This button will open a person's Instagram account
                        child: FloatingActionButton(
                          child: Image.asset(
                            "assets/images/instagram.jpg",
                          ),
                          onPressed: () {
                            openInstagram();
                          },
                        ),
                        padding: EdgeInsets.all(10))
                    : Container()
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            padding: EdgeInsets.all(10)));
  }

  //This function opens a user's Instagram account
  void openInstagram() async {
    String url = "https://instagram.com/";
    if (widget.person.instagram != "")
      url += widget.person.instagram;
    else
      url += "coloradofbla";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
