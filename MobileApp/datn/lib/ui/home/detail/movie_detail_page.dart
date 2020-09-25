import 'package:flutter/material.dart';

import 'show_times_page.dart';

class MovieDetailPage extends StatefulWidget {
  static const routeName = '/home/detail';

  final String movieId;
  final String title;

  const MovieDetailPage({
    Key key,
    @required this.movieId,
    @required this.title,
  }) : super(key: key);

  @override
  _MovieDetailPageState createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = <Widget>[
      ShowTimesPage(movieId: widget.movieId),
      Container(),
      Container(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.date_range),
              ),
              Tab(
                icon: Icon(Icons.comment),
              ),
              Tab(
                icon: Icon(Icons.info_outlined),
              ),
            ],
          ),
          title: Text(widget.title),
        ),
        body: TabBarView(children: pages),
      ),
    );
  }
}
