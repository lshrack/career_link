import 'package:career_find/database.dart';
import 'package:career_find/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'person_page.dart';
import 'database.dart';
import 'profile_page.dart';
import 'package:flutter_sms/flutter_sms.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //this builds and returns the app itself
    return MaterialApp(
      title: 'Career Link',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Home'),
    );
  }
}

//This class displays the app's homepage
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String searchTerm;
  SearchBar searchBar;
  List<Person> people;
  GlobalKey<AnimatedListState> listKey = GlobalKey();

  AppBar buildAppBar(BuildContext context) {
    //This creates the appbar (top bar) of the application
    return new AppBar(title: new Text('Home'), actions: [
      searchBar.getSearchAction(context),
      Padding(
          child: Image(
            image: new AssetImage("assets/images/icon.png"),
            width: 36,
            height: 36,
            color: null,
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
          ),
          padding: EdgeInsets.symmetric(horizontal: 5))
    ]);
  }

  _MyHomePageState() {
    //This creates the searchbar used to search the list of names
    searchBar = new SearchBar(
        inBar: false,
        setState: setState,
        onSubmitted: (value) {
          runSearch(value);
          print(value);
        },
        buildDefaultAppBar: buildAppBar);
  }

  @override
  Widget build(BuildContext context) {
    //This Scaffold represents the home screen
    return new Scaffold(
      appBar: searchBar.build(context),
      body: SingleChildScrollView(
        child: Column(children: [
          //This list will show the results of a user's search
          AnimatedList(
              shrinkWrap: true,
              key: listKey,
              initialItemCount: 0,
              itemBuilder: (context, i, animation) {
                final index = i;
                if (index < people.length) {
                  final person = people[index];
                  return Column(children: [
                    ListTile(
                        title:
                            Text(person.name, style: TextStyle(fontSize: 18)),
                        subtitle: Text(person.profession),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          print("I was tapped!");
                          launchPageFor(person);
                        }),
                    Divider()
                  ]);
                }
                return Container();
              }),
          //This will show what the user searched for, or if they haven't searched
          //anything, it will prompt them to tap the search icon
          Padding(
              child: Text(
                searchTerm == ""
                    ? "Tap the search icon to search the database!"
                    : "You searched for: $searchTerm",
                style: TextStyle(color: Colors.grey, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              padding: EdgeInsets.all(20)),
          //This feature is integrated with SMS to allow users to send bug reports
          FlatButton(
            child: Text("Report a Bug"),
            onPressed: () {
              sendBugReport();
            },
          ),
        ]),
      ),
      //This button hovers over the lower left area of the screen and launches the profile page
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.person),
          onPressed: () {
            launchProfilePage();
          }),
    );
  }

  //This method calls on the _sendSMS method to send a bug report
  void sendBugReport() {
    String message = "Bug found!";
    List<String> recipents = ["7194394561"];

    _sendSMS(message, recipents);
  }

  //This method will send an SMS message
  void _sendSMS(String message, List<String> recipents) async {
    String _result = await sendSMS(message: message, recipients: recipents)
        .catchError((onError) {
      print(onError);
    });
    print(_result);
  }

  //This method runs when the user conducts a search, searching the list of people for matches
  void runSearch(String val) {
    searchTerm = val;
    print("Running search for $searchTerm");
    for (int i = people.length - 1; i >= 0; i--) {
      people.removeAt(i);
      listKey.currentState.removeItem(i, (context, animation) => null);
    }

    if (searchTerm != "") {
      for (int i = 0; i < Globals.people.length; i++) {
        Person person = Globals.people[i];
        print("Checking ${person.name}");
        if (person.name.length >= searchTerm.length &&
            person.name.substring(0, searchTerm.length) == searchTerm) {
          print("Match Found!");
          people.add(person);
          listKey.currentState.insertItem(people.length - 1);
        } else
          print("Match Not Found");
      }
    }
    setState(() {});
  }

  //This launches the PersonPage class when the user wants to see a specific person's
  //information
  void launchPageFor(Person person) {
    Navigator.of(context)
        .push(MaterialPageRoute<bool>(builder: (BuildContext context) {
      return PersonPage(person);
    }));
  }

  //This launches the ProfilePage class when the user wants to edit their own information
  void launchProfilePage() {
    Navigator.of(context)
        .push(MaterialPageRoute<bool>(builder: (BuildContext context) {
      return ProfilePage();
    }));
  }

  //This just clears the database (mostly useful for testing purposes)
  void clearDatabase() {
    DatabaseMethods.clearAll(Globals.personDbInstance);
    print("Database Cleared!");
  }

  //This initializes the class, setting searchTerm to an empty string and the list of
  //people to an empty list
  @override
  void initState() {
    searchTerm = "";
    people = [];
    super.initState();
  }
}

class Person {
  int id;
  String name;
  String profession;
  String company;
  String education;
  String email;
  String phoneNumber;
  String instagram;

  //The constructor will accept parameters for all values, but also has default values at the ready
  Person(
      {this.id = 0,
      this.name = "",
      this.profession = "",
      this.company = "",
      this.education = "",
      this.email = "",
      this.phoneNumber = "",
      this.instagram = ""});

  //This creates a PersonEntry object out of a Person object, so that it can be
  //more easily saved in the local database
  PersonEntry toEntry() {
    PersonEntry entry = PersonEntry.withParams(
        id: id == null ? 0 : id,
        name: name == "" ? "NULLVAL" : name,
        profession: profession == "" ? "NULLVAL" : profession,
        company: company == "" ? "NULLVAL" : company,
        education: education == "" ? "NULLVAL" : education,
        email: email == "" ? "NULLVAL" : email,
        phone: phoneNumber == "" ? "NULLVAL" : phoneNumber);

    return entry;
  }
}

class Globals {
  //These people are solely included for testing purposes; in reality, the list
  //of names would be sourced from the web
  static final List<Person> people = [
    Person(
        name: "James Fletcher",
        email: "jamie.fletcher@gmail.com",
        phoneNumber: "623-555-8091",
        company: "Vancouver Electrics",
        profession: "Electrical Engineer",
        education: "University of Colorado"),
    Person(
        name: "Kara Williams",
        email: "karawilliams03@gmail.com",
        phoneNumber: "601-555-1827",
        company: "Portland Hospital",
        profession: "Neurosurgeon",
        education: "Oregon State University",
        instagram: "karawilliams"),
    Person(
        name: "Aly Stetson",
        email: "stetson.aly@gmail.com",
        phoneNumber: "381-555-1285",
        company: "Murray Security Services",
        profession: "Cybersecurity Intern",
        education: "Pine Creek High School"),
    Person(
        name: "Lexi Simone",
        email: "lexiannsimone@gmail.com",
        phoneNumber: "128-555-1284",
        company: "Lulu's Frozen Yogurt",
        profession: "Fashion Designer",
        education: "Glenwood High School"),
    Person(
        name: "Lucas Allende",
        email: "lucasthehackerr@gmail.com",
        phoneNumber: "182-555-6823",
        company: "N/A",
        profession: "Software Engineer",
        education: "Aspen Valley High School"),
    Person(
        name: "James Rivera",
        email: "jamesrivera61@gmail.com",
        phoneNumber: "623-555-8091",
        company: "Vancouver Electrics",
        profession: "Accountant",
        education: "University of Colorado"),
  ];

  static final personDbInstance = PersonDatabaseHelper.instance;
}
