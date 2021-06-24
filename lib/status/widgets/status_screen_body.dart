import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:techstagram/status/model/status_model.dart';
import 'package:techstagram/status/screens/status_view_page.dart';

class StatusScreenBody extends StatefulWidget {
  const StatusScreenBody({
    Key key,
  }) : super(key: key);

  @override
  _StatusScreenBodyState createState() => _StatusScreenBodyState();
}

class _StatusScreenBodyState extends State<StatusScreenBody> {
  User curUsr = FirebaseAuth.instance.currentUser;
  String curUsrPic;
  bool viewRecent;

  @override
  void initState() {
    fetchUserData();
    viewRecent = true;
    super.initState();
  }

  fetchUserData() async {
    var result = await FirebaseFirestore.instance
        .collection('users')
        .doc(curUsr.uid)
        .get();
    curUsrPic = result.data()["photoURL"];
  }

  @override
  Widget build(BuildContext context) {
    var stream = FirebaseFirestore.instance.collection("story").snapshots();

    void deleteStatus(String id) {
      DateTime currTime = DateTime.now();
      FirebaseFirestore.instance
          .collection("story")
          .doc(id)
          .collection("uploaded status")
          .get()
          .then(
        (snapshot) {
          for (DocumentSnapshot ds in snapshot.docs) {
            DateTime deleteTime = DateTime.tryParse(ds["uploadTime"].toString())
                .add(Duration(days: 1));

            bool timecmp = currTime.isAfter(deleteTime);
            if (timecmp) ds.reference.delete();
          }
        },
      );
    }

    Color recentColour =
        viewRecent ? Colors.deepPurple : Colors.deepPurple[200];
    Color viewedColour =
        !viewRecent ? Colors.deepPurple : Colors.deepPurple[200];

    return StreamBuilder(
      stream: stream,
      builder: (BuildContext ctx, snapShot) {
        switch (snapShot.connectionState) {
          case ConnectionState.none:
            return Center(child: Text("nothing to show"));
          case ConnectionState.waiting:
            return Expanded(
              child: CircularProgressIndicator(),
            );
          default:
            if (Status.viewedStatusList != []) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Column(
                  children: [
                    Card(
                      child: GestureDetector(
                        child: ListTile(
                          leading: Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: NetworkImage(curUsrPic.toString()),
                                  fit: BoxFit.cover),
                            ),
                          ),
                          title: Text(
                            'MyStatus',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => StatusViewScreen(
                                id: curUsr.email,
                                myStatus: true,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Divider(),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            viewRecent = true;
                            Status.getViewedStatus();
                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.center,
                            height: 30,
                            width: 110,
                            decoration: BoxDecoration(
                                color: recentColour,
                                borderRadius: BorderRadius.circular(30)),
                            child: Text(
                              'Recent',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            viewRecent = false;
                            Status.getViewedStatus();
                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.center,
                            height: 30,
                            width: 110,
                            decoration: BoxDecoration(
                                color: viewedColour,
                                borderRadius: BorderRadius.circular(30)),
                            child: Text(
                              'Viewed',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    viewRecent
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapShot.data.docs.length,
                            itemBuilder: (ctx, i) {
                              Status.getViewedStatus();
                              String id = snapShot.data.docs[i].id;
                              print('listview recent id ' + id);
                              deleteStatus(id);

                              if (!Status.viewedStatusList.contains(id)) {
                                print(Status.viewedStatusList);
                                String pic =
                                    snapShot.data.docs[i].data()["photoURL"];
                                DateTime date = DateTime.tryParse(snapShot
                                    .data.docs[i]
                                    .data()["time"]
                                    .toString());

                                return GestureDetector(
                                  child: Card(
                                    child: ListTile(
                                      title: Text(snapShot.data.docs[i]
                                          .data()["displayName"]
                                          .toString()),
                                      leading: Container(
                                        height: 35,
                                        width: 35,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    pic.toString()),
                                                fit: BoxFit.cover)),
                                      ),
                                      trailing:
                                          Text("${date.hour}:${date.minute}"),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                StatusViewScreen(id: id)));
                                  },
                                );
                              }
                            },
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapShot.data.docs.length,
                            itemBuilder: (ctx, i) {
                              Status.getViewedStatus();
                              String id = snapShot.data.docs[i].id;
                              deleteStatus(id);

                              String name = snapShot.data.docs[i]
                                  .data()["displayName"]
                                  .toString();
                              print('viewd screen on ' + id);
                              print(Status.viewedStatusList);
                              if (Status.viewedStatusList.contains(id)) {
                                print('viewed stats : ' + id);
                                String pic =
                                    snapShot.data.docs[i].data()["photoURL"];
                                DateTime date = DateTime.tryParse(snapShot
                                    .data.docs[i]
                                    .data()["time"]
                                    .toString());

                                return GestureDetector(
                                  child: Card(
                                    child: ListTile(
                                      title: Text(name),
                                      leading: Container(
                                        height: 35,
                                        width: 35,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    pic.toString()),
                                                fit: BoxFit.cover)),
                                      ),
                                      trailing:
                                          Text("${date.hour}:${date.minute}"),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                StatusViewScreen(id: id)));
                                  },
                                );
                              }
                            },
                          ),
                  ],
                ),
              );
            }
        }
      },
    );
  }
}
