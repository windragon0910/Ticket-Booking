import 'package:flutter/material.dart';
import 'package:movie_admin/ui/movies/movies_page.dart';
import 'package:movie_admin/ui/movies/upload_movie/movie_upload_page.dart';
import 'package:movie_admin/ui/theatres/theatre_page.dart';

import '../../utils/type_defs.dart';
import '../users/manager_users_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: GridView.count(
        primary: false,
        childAspectRatio: 1.5,
        crossAxisCount: 2,
        physics: ClampingScrollPhysics(),
        children: <Widget>[
          card(
            Icons.supervised_user_circle_rounded,
            'Manager users',
            '5 notifiction',
            Colors.red,
            () => Navigator.of(context).pushNamed(ManagerUsersPage.routeName),
          ),
          card(
            Icons.movie_filter_outlined,
            "Manager movie",
            "5 notifiction",
            Colors.red,
            () => Navigator.of(context).pushNamed(MoviePage.routeName),
          ),
          card(
            Icons.add_box_rounded,
            "Upload movie",
            "5 notifiction",
            Colors.red, () => Navigator.of(context).pushNamed(UploadMoviePage.routeName),
          ),
          card(
            Icons.theaters,
            "Manager theatre",
            "5 notifiction",
            Colors.red,
            () => Navigator.of(context).pushNamed(TheatresPage.routeName),
          ),
          card(
            Icons.theaters,
            "Manager show time",
            "5 notifiction",
            Colors.red,
            () => Navigator.of(context).pushNamed(
              TheatresPage.routeName,
              arguments: true,
            ),
          )
        ],
      ),
    );
  }

  Widget card(
      IconData icon, String title, String note, Color color, Function0 onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          color: Colors.white,
          elevation: 14.0,
          borderRadius: BorderRadius.circular(10.0),
          shadowColor: Color(0x802196F3),
          child: Column(
            children: [
              Container(
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            icon,
                            color: Colors.blueAccent,
                            size: 25,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Container(
                            child: Text(
                              title,
                              maxLines: 1,
                              softWrap: true,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                color: Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.notifications_none,
                                size: 10,
                                color: Colors.redAccent,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                note,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                  fontFamily: 'Poppins',
                                  color: Colors.grey,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
