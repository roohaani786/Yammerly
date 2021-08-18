import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  isViewed(String id) async {
    var result = await FirebaseFirestore.instance
        .collection("story")
        .doc(id)
        .collection("uploaded status")
        .get();

    if (result.size.toDouble() > 0) {
      var res = await FirebaseFirestore.instance
          .collection("story")
          .doc(curUsr.email)
          .collection("viewed")
          .doc(id)
          .get();

      return res.exists;
    } else {
      return null;
    }
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
            return Center(
              child: CircularProgressIndicator(),
            );
          default:
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Column(
                children: [
                  MyStatus(
                      curUsrPic: curUsrPic, curUsr: curUsr, snapshot: snapShot),
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
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          viewRecent = false;
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
                            style: TextStyle(color: Colors.white, fontSize: 15),
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
                            String id = snapShot.data.docs[i].id;

                            deleteStatus(id);

                            String pic =
                                snapShot.data.docs[i].data()["photoURL"];
                            DateTime date = DateTime.tryParse(snapShot
                                .data.docs[i]
                                .data()["time"]
                                .toString());

                            return FutureBuilder(
                              future: isViewed(id),
                              builder: (Context, snap) {
                                switch (snap.data.toString()) {
                                  case 'null':
                                    return Text('');
                                  case 'true':
                                    return Text('');
                                  case 'false':
                                    return(snapShot.data.docs[i]
                                        .data()["displayName"]
                                        .toString() == curUsr)? GestureDetector(
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
                                          trailing: Text(
                                              "${date.hour}:${date.minute}"),
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    StatusViewScreen(id: id)));
                                      },
                                    ):Container();
                                }
                              },
                            );
                          },
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapShot.data.docs.length,
                          itemBuilder: (ctx, i) {
                            String id = snapShot.data.docs[i].id;

                            deleteStatus(id);

                            String pic =
                                snapShot.data.docs[i].data()["photoURL"];
                            DateTime date = DateTime.tryParse(snapShot
                                .data.docs[i]
                                .data()["time"]
                                .toString());

                            return FutureBuilder(
                              future: isViewed(id),
                              builder: (Context, snap) {
                                switch (snap.data.toString()) {
                                  case 'null':
                                    return Text('');
                                  case 'false':
                                    return Text('');

                                  case 'true':
                                    return(snapShot.data.docs[i]
                                        .data()["displayName"]
                                        .toString() == curUsr)? GestureDetector(
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
                                          trailing: Text(
                                              "${date.hour}:${date.minute}"),
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    StatusViewScreen(id: id)));
                                      },
                                    ):Container();
                                }
                              },
                            );
                          },
                        )
                ],
              ),
            );
        }
      },
    );
  }
}

class MyStatus extends StatelessWidget {
  const MyStatus({
    Key key,
    @required this.curUsrPic,
    @required this.curUsr,
    @required this.snapshot,
  }) : super(key: key);

  final String curUsrPic;
  final User curUsr;
  final AsyncSnapshot<dynamic> snapshot;

  @override
  Widget build(BuildContext context) {
    isMyStatus() async {
      var result = await FirebaseFirestore.instance
          .collection("story")
          .doc(curUsr.email)
          .collection("uploaded status")
          .get();

      return result.size;
    }

    return FutureBuilder(
      future: isMyStatus(),
      builder: (context, snap) => Card(
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
              'My Status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          onTap: () {
            switch (snap.data) {
              case null:
                return Center(
                  child: Text('nothing to show'),
                );
              default:
                if(snap.data != null){
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => StatusViewScreen(
                      id: curUsr.email,
                      myStatus: true,
                    ),
                  ),
                );
            }
          }
          },
        ),
      ),
    );
  }
}
