import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Otheruser/other_user.dart';

class CloudFirebaseFirestoreSearch extends StatefulWidget {
  final String displayNamecurrentUser;
  final String uidX;
  CloudFirebaseFirestoreSearch({this.displayNamecurrentUser, this.uidX});
  @override
  _CloudFirebaseFirestoreSearchState createState() => _CloudFirebaseFirestoreSearchState(
      displayNamecurrentUser: displayNamecurrentUser, uidX: uidX);
}

class _CloudFirebaseFirestoreSearchState extends State<CloudFirebaseFirestoreSearch> {
  String fname = "";
  String lname = "";
  String searchKey;
  Stream streamQuery;
  final displayNamecurrentUser;
  final uidX;

  _CloudFirebaseFirestoreSearchState({this.displayNamecurrentUser, this.uidX});

  // Future<void> _showSearch() async {
  //   final searchText = await showSearch<String>(
  //     context: context,
  //     delegate: SearchWithSuggestionDelegate(
  //       onSearchChanged: _getRecentSearchesLike,
  //     ),
  //   );
  //
  //   //Save the searchText to SharedPref so that next time you can use them as recent searches.
  //   await _saveToRecentSearches(searchText);
  //
  //   //Do something with searchText. Note: This is not a result.
  // }

  List<String> allSearches = [];

  Future<List<String>> _getRecentSearchesLike(String query) async {
    final pref = await SharedPreferences.getInstance();
     allSearches = pref.getStringList("recentSearches");
     print("get recent search");
     print(allSearches);
    //return allSearches.where((search) => search.startsWith(query)).toList();
  }

  Future<void> _saveToRecentSearches(String searchText) async {
    if (searchText == null) return; //Should not be null
    final pref = await SharedPreferences.getInstance();

    //Use `Set` to avoid duplication of recentSearches
    Set<String> allSearches =
        pref.getStringList("recentSearches")?.toSet() ?? {};

    //Place it at first in the set
    allSearches = {searchText, ...allSearches};
    pref.setStringList("recentSearches", allSearches.toList());
  }

  searchHistory(String val) async{

    print("search history");

    await _saveToRecentSearches(val);
  }

  String uidf = CloudFirebaseFirestoreSearch().uidX;
  @override
  Widget build(BuildContext context) {
    print("cv");
    print(uidX);
    print("434");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          color: Colors.deepPurple,
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.deepPurple,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Container(
          color: Colors.white,
          child: TextField(
            textInputAction: TextInputAction.search,
              onSubmitted: (val){
                searchHistory(val);
              },
            decoration: InputDecoration(
//                prefixIcon: Icon(Icons.search,color: Colors.white,),
                hintText: ' Search...',
                hintStyle: TextStyle(
                  color: Colors.black,
                )),
            onChanged: (val) {
              setState(() {
//                fname = val;
                searchKey = val;
                streamQuery = FirebaseFirestore.instance
                    .collection('users')
                    .where('displayName', isGreaterThanOrEqualTo: searchKey)
                    .where('displayName', isLessThan: searchKey + 'z')
                    .snapshots();
                _getRecentSearchesLike(val);
                //searchHistory(val);

                //_showSearch();
              });

            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
          stream: (searchKey != "" && searchKey != null)
              ? streamQuery
              :
//        FirebaseFirestore.instance.collection("users").snapshots(),
//        (fname != "" && fname != null)
              FirebaseFirestore.instance
                  .collection('users')
                  .where("searchKeywords", arrayContains: fname)
                  .snapshots(),
//            : FirebaseFirestore.instance.collection("users").snapshots(),
          builder: (context, snapshot) {
            return (snapshot.connectionState == ConnectionState.waiting)
                ? Center(
                    child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/profileedit.png'),
                            fit: BoxFit.cover,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: CircularProgressIndicator()))
                : Column(
                  children: [
            ListView.builder(
              shrinkWrap: true,
            itemCount: allSearches.length,
              itemBuilder: (context, index) {
                return (index<5)?ListTile(
                  leading: Icon(Icons.restore),
                  title: Text("${allSearches[index]}"),
                  //onTap: () => close(context, _oldFilters[index]),
                ):Container();
              },
            ),
                    ListView.builder(
                      shrinkWrap: true,
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
//              DocumentSnapshot sd = snapshot.data.docs[index];
                          searchKey = snapshot.data.docs[index]["displayName"];
                          String photoUrl =
                              snapshot.data.docs[index]["photoURL"];
                          String uid = snapshot.data.docs[index]["uid"];
                          String displayName =
                              snapshot.data.docs[index]["displayName"];
                          print(displayName);
                          return (searchKey != null)
                              ? Row(
                                children: <Widget>[
                                  // SizedBox(
                                  //   width: 25,
                                  // ),
                                  MaterialButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                OtherUserProfile(
                                                    uid: uid,
                                                    displayNamecurrentUser:
                                                        displayNamecurrentUser,
                                                    displayName: displayName,
                                                    uidX: uidX)),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        (photoUrl != null)
                                            ? CircleAvatar(
                                                radius: 20,
                                                backgroundImage:
                                                    NetworkImage(photoUrl),
                                                backgroundColor:
                                                    Colors.transparent,
                                              )
                                            : CircleAvatar(
                                                radius: 20,
                                                child: IconButton(
                                                    icon: Icon(
                                                      FontAwesomeIcons.userCircle,
                                                      color: Colors.deepPurple,
                                                    ),
                                                    onPressed: null),
                                                backgroundColor:
                                                    Colors.transparent,
                                              ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 20.0),
                                          child: Text(
                                            searchKey,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                              : Container();
                        },
                      ),
                  ],
                );
          },
        ),
      ),
    );
  }
}

// search history

// typedef OnSearchChanged = Future<List<String>> Function(String);
//
// class SearchWithSuggestionDelegate extends SearchDelegate<String> {
//   ///[onSearchChanged] gets the [query] as an argument. Then this callback
//   ///should process [query] then return an [List<String>] as suggestions.
//   ///Since its returns a [Future] you get suggestions from server too.
//   final OnSearchChanged onSearchChanged;
//
//   ///This [_oldFilters] used to store the previous suggestions. While waiting
//   ///for [onSearchChanged] to completed, [_oldFilters] are displayed.
//   List<String> _oldFilters = const [];
//
//   SearchWithSuggestionDelegate({String searchFieldLabel, this.onSearchChanged})
//       : super(searchFieldLabel: searchFieldLabel);
//
//   ///
//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//       icon: const Icon(Icons.arrow_back),
//       onPressed: () => Navigator.pop(context),
//     );
//   }
//
//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: Icon(Icons.clear),
//         onPressed: () => query = "",
//       ),
//     ];
//   }
//
//   ///OnSubmit in the keyboard, returns the [query]
//   @override
//   void showResults(BuildContext context) {
//     close(context, query);
//   }
//
//   ///Since [showResults] is overridden we can don't have to build the results.
//   @override
//   Widget buildResults(BuildContext context) => null;
//
//   @override
//   Widget buildSuggestions(BuildContext context) {
//     return Column(
//       children: [
//         FutureBuilder<List<String>>(
//           future: onSearchChanged != null ? onSearchChanged(query) : null,
//           builder: (context, snapshot) {
//             if (snapshot.hasData) _oldFilters = snapshot.data;
//             return ListView.builder(
//               itemCount: _oldFilters.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   leading: Icon(Icons.restore),
//                   title: Text("${_oldFilters[index]}"),
//                   onTap: () => close(context, _oldFilters[index]),
//                 );
//               },
//             );
//           },
//         ),
//       ],
//     );
//   }
// }
