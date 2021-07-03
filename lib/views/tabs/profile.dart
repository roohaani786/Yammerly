//import 'package:flutter/cupertino.dart';
//import 'package:flutter/material.dart';
//import 'package:techstagram/model/user.dart';
//import 'package:techstagram/utils/colors.dart';
////import 'package:line_icons/line_icons.dart';
//
//class ProfilePage extends StatelessWidget {
//  final User user = users[0];
//
//  @override
//  Widget build(BuildContext context) {
//    final hr = Divider();
//    final userStats = Positioned(
//      bottom: 10.0,
//      left: 40.0,
//      right: 40.0,
//      child: Row(
//        mainAxisAlignment: MainAxisAlignment.spaceAround,
//        children: <Widget>[
//          _buildUserStats('VISITORS', '2305'),
//          _buildUserStats('LIKED', '276'),
//          _buildUserStats('MATCHED', '51'),
//        ],
//      ),
//    );
//
//    final userImage = Container(
//      height: 100.0,
//      width: 100.0,
//      decoration: BoxDecoration(
//        image: DecorationImage(
//          image: AssetImage(user.photo),
//          fit: BoxFit.cover,
//        ),
//        shape: BoxShape.circle,
//      ),
//    );
//
//    final userNameLocation = Container(
//      child: Column(
//        mainAxisAlignment: MainAxisAlignment.center,
//        crossAxisAlignment: CrossAxisAlignment.start,
//        children: <Widget>[
//          Text(
//            user.name,
//            style: TextStyle(
//              fontSize: 24.0,
//              fontWeight: FontWeight.w900,
//            ),
//          ),
//          Text(
//            user.location,
//            style: TextStyle(
//              color: Colors.grey.withOpacity(0.6),
//              fontSize: 20.0,
//              fontWeight: FontWeight.w600,
//            ),
//          ),
//        ],
//      ),
//    );
//
//    final userInfo = Stack(
//      children: <Widget>[
//        Padding(
//          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
//          child: Material(
//            elevation: 5.0,
//            borderRadius: BorderRadius.circular(8.0),
//            shadowColor: Colors.white,
//            child: Container(
//              height: 220.0,
//              width: MediaQuery.of(context).size.width,
//              decoration: BoxDecoration(
//                borderRadius: BorderRadius.circular(8.0),
//                border: Border.all(
//                  color: Colors.grey.withOpacity(0.2),
//                ),
//                color: Colors.white,
//              ),
//              child: Padding(
//                padding: const EdgeInsets.only(left: 20.0, bottom: 20.0),
//                child: Row(
//                  children: <Widget>[
//                    userImage,
//                    SizedBox(width: 10.0),
//                    userNameLocation
//                  ],
//                ),
//              ),
//            ),
//          ),
//        ),
//        userStats
//      ],
//    );
//
//    final secondCard = Padding(
//      padding: EdgeInsets.only(right: 20.0, left: 20.0, bottom: 30.0),
//      child: Material(
//        elevation: 5.0,
//        borderRadius: BorderRadius.circular(8.0),
//        shadowColor: Colors.white,
//        child: Container(
//          height: 200.0,
//          decoration: BoxDecoration(
//            color: Colors.white,
//            borderRadius: BorderRadius.circular(8.0),
//          ),
//          child: Column(
//            children: <Widget>[
//              _buildIconTile(Icons.favorite, Colors.red, 'Likes'),
//              hr,
//              _buildIconTile(Icons.remove_red_eye, Colors.green, 'Visitors'),
//              hr,
//              _buildIconTile(
//                  Icons.account_circle, Colors.purpleAccent, 'Groups'),
//            ],
//          ),
//        ),
//      ),
//    );
//
//    final thirdCard = Padding(
//      padding: EdgeInsets.only(right: 20.0, left: 20.0, bottom: 30.0),
//      child: Material(
//        elevation: 5.0,
//        borderRadius: BorderRadius.circular(8.0),
//        shadowColor: Colors.white,
//        child: Container(
//          height: 350.0,
//          decoration: BoxDecoration(
//            color: Colors.white,
//            borderRadius: BorderRadius.circular(8.0),
//          ),
//          child: Column(
//            children: <Widget>[
//              _buildIconTile(Icons.attach_money, Colors.red, 'My Wallet'),
//              hr,
//              _buildIconTile(Icons.streetview, Colors.blue, 'VIP Center'),
//              hr,
//              _buildIconTile(Icons.supervised_user_circle, Colors.orangeAccent,
//                  'Find Friends'),
//              hr,
//              _buildIconTile(Icons.account_circle, Colors.black, 'Blacklist'),
//              hr,
//              _buildIconTile(
//                  Icons.settings, Colors.grey.withOpacity(0.6), 'Settings'),
//            ],
//          ),
//        ),
//      ),
//    );
//
//    return Scaffold(
//      body: SingleChildScrollView(
//        child: Column(
//          children: <Widget>[
//            Container(
//              width: MediaQuery.of(context).size.width,
//              child: Column(
//                children: <Widget>[
//                  Stack(
//                    children: <Widget>[
//                      Container(
//                        height: 350.0,
//                      ),
//                      Container(
//                        height: 250.0,
//                        decoration: BoxDecoration(gradient: primaryGradient),
//                      ),
//                      Positioned(top: 100, right: 0, left: 0, child: userInfo)
//                    ],
//                  ),
//                  secondCard,
//                  thirdCard
//                ],
//              ),
//            ),
//          ],
//        ),
//      ),
//    );
//  }
//
//  Widget _buildUserStats(String name, String value) {
//    return Column(
//      children: <Widget>[
//        Text(
//          name,
//          style: TextStyle(
//            color: Colors.grey.withOpacity(0.6),
//            fontWeight: FontWeight.w600,
//            fontSize: 16.0,
//          ),
//        ),
//        Text(
//          value,
//          style: TextStyle(
//            color: Colors.black87,
//            fontWeight: FontWeight.w900,
//            fontSize: 20.0,
//          ),
//        ),
//      ],
//    );
//  }
//
//  Widget _buildIconTile(IconData icon, Color color, String title) {
//    return ListTile(
//      title: Text(
//        title,
//        style: TextStyle(fontWeight: FontWeight.bold),
//      ),
//      leading: Container(
//        height: 30.0,
//        width: 30.0,
//        decoration: BoxDecoration(
//          color: color,
//          borderRadius: BorderRadius.circular(10.0),
//        ),
//        child: Center(
//          child: Icon(
//            icon,
//            color: Colors.white,
//          ),
//        ),
//      ),
//      trailing: Icon(Icons.play_circle_outline),
//    );
//  }
//}
