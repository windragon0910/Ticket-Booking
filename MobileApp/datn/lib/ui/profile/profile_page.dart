import 'package:cached_network_image/cached_network_image.dart';
import 'package:datn/locale_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/model/user.dart';
import '../../domain/repository/user_repository.dart';
import '../../generated/l10n.dart';
import '../../utils/optional.dart';
import '../app_scaffold.dart';
import '../login_update_profile/login_update_profile_page.dart';
import 'reservations/reservations_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ValueStream<Optional<User>> user$;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    user$ ??= Provider.of<UserRepository>(context).user$;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RxStreamBuilder<Optional<User>>(
        stream: user$,
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (data == null) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            );
          }

          return data.fold(
            () => NotLoggedIn(),
            (user) => LoggedIn(user),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            AppScaffold.of(context).pushNamedX(ReservationsPage.routeName),
        label: Text(S.of(context).tickets),
        icon: FaIcon(FontAwesomeIcons.ticketAlt),
      ),
    );
  }
}

class LoggedIn extends StatelessWidget {
  final User user;

  LoggedIn(this.user);

  @override
  Widget build(BuildContext context) {
    const height = 170.0;
    const imageSize = 115.0;

    final paddingTop = MediaQuery.of(context).padding.top;

    final detailHeaderStyle = TextStyle(
      color: Theme.of(context).primaryColorDark,
      fontSize: 13,
    );
    final detailInfoStyle =
        Theme.of(context).textTheme.subtitle1.copyWith(fontSize: 17);
    final accentColor = Theme.of(context).accentColor;

    return Stack(
      children: [
        buildGradient(height),
        buildEditButton(paddingTop, context),
        buildLogoutButton(paddingTop, context),
        buildListInfos(
          height,
          imageSize,
          detailHeaderStyle,
          detailInfoStyle,
          accentColor,
          context,
        ),
        buildAvatar(height, imageSize, context),
      ],
    );
  }

  Widget buildListInfos(
    double height,
    double imageSize,
    TextStyle detailHeaderStyle,
    TextStyle detailInfoStyle,
    Color accentColor,
    BuildContext context,
  ) {
    final density = VisualDensity.compact;

    return Positioned.fill(
      top: height + imageSize / 2 - 16,
      left: 0,
      right: 0,
      bottom: 0,
      child: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          ListTile(
            title: Text(
              S.of(context).email,
              style: detailHeaderStyle,
            ),
            subtitle: Text(
              user.email,
              style: detailInfoStyle,
            ),
            dense: true,
            visualDensity: density,
            leading: Icon(
              Icons.email,
              color: accentColor,
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(
              S.of(context).fullName,
              style: detailHeaderStyle,
            ),
            subtitle: Text(
              user.fullName,
              style: detailInfoStyle,
            ),
            dense: true,
            visualDensity: density,
            leading: Icon(
              Icons.person,
              color: accentColor,
            ),
          ),
          const Divider(),
          if (user.phoneNumber != null) ...[
            ListTile(
              title: Text(
                S.of(context).phoneNumber,
                style: detailHeaderStyle,
              ),
              subtitle: Text(
                user.phoneNumber,
                style: detailInfoStyle,
              ),
              dense: true,
              visualDensity: density,
              leading: Icon(
                Icons.phone,
                color: accentColor,
              ),
            ),
            const Divider(),
          ],
          ListTile(
            title: Text(
              S.of(context).gender,
              style: detailHeaderStyle,
            ),
            subtitle: Text(
              user.gender.toString().split('.')[1],
              style: detailInfoStyle,
            ),
            dense: true,
            visualDensity: density,
            leading: FaIcon(
              () {
                switch (user.gender) {
                  case Gender.MALE:
                    return FontAwesomeIcons.mars;
                  case Gender.FEMALE:
                    return FontAwesomeIcons.venus;
                }
              }(),
              color: accentColor,
            ),
          ),
          const Divider(),
          if (user.address != null) ...[
            ListTile(
              title: Text(
                S.of(context).address,
                style: detailHeaderStyle,
              ),
              subtitle: Text(
                user.address,
                style: detailInfoStyle,
              ),
              dense: true,
              visualDensity: density,
              leading: FaIcon(
                FontAwesomeIcons.addressCard,
                color: accentColor,
              ),
            ),
            const Divider(),
          ],
          if (user.birthday != null) ...[
            ListTile(
              title: Text(
                S.of(context).birthday,
                style: detailHeaderStyle,
              ),
              subtitle: Text(
                (DateFormat()..add_yMMMd()).format(user.birthday),
                style: detailInfoStyle,
              ),
              dense: true,
              visualDensity: density,
              leading: FaIcon(
                FontAwesomeIcons.birthdayCake,
                color: accentColor,
              ),
            ),
            const Divider(),
          ],
          const SizedBox(height: 64)
        ],
      ),
    );
  }

  Widget buildEditButton(double paddingTop, BuildContext context) {
    return Positioned(
      top: paddingTop + 16,
      right: 8,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.16),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => AppScaffold.of(context).pushNamedX(
              UpdateProfilePage.routeName,
              arguments: user,
            ),
            customBorder: CircleBorder(),
            splashColor: Colors.white30,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(
                Icons.edit,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAvatar(double height, double imageSize, BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: height - imageSize / 2,
      child: Center(
        child: Container(
          width: imageSize,
          height: imageSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).backgroundColor,
            boxShadow: [
              BoxShadow(
                blurRadius: 16,
                offset: Offset(2, 2),
                color: Colors.grey.shade500,
                spreadRadius: 2,
              )
            ],
          ),
          child: ClipOval(
            child: user.avatar == null
                ? Center(
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: imageSize * 0.7,
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: user.avatar,
                    fit: BoxFit.cover,
                    width: imageSize,
                    height: imageSize,
                    progressIndicatorBuilder: (
                      BuildContext context,
                      String url,
                      progress,
                    ) {
                      return Center(
                        child: CircularProgressIndicator(
                          value: progress.progress,
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      );
                    },
                    errorWidget: (
                      BuildContext context,
                      String url,
                      dynamic error,
                    ) {
                      return Center(
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: imageSize * 0.7,
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget buildGradient(double height) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: CustomPaint(
        painter: BoxShadowPainter(height),
        child: ClipPath(
          clipper: _CustomClipper(height),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: Colors.white,
              gradient: LinearGradient(
                colors: <Color>[
                  const Color(0xffB881F9).withOpacity(0.9),
                  const Color(0xff545AE9).withOpacity(0.9),
                ],
                begin: AlignmentDirectional.topEnd,
                end: AlignmentDirectional.bottomStart,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLogoutButton(double paddingTop, BuildContext context) {
    return Positioned(
      top: paddingTop + 16,
      left: 8,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.16),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(S.of(context).logoutOut),
                    content: Text(S.of(context).areYouSureYouWantToLogout),
                    actions: <Widget>[
                      TextButton(
                        child: Text(S.of(context).cancel),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      TextButton(
                        child: Text('OK'),
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ],
                  );
                },
              );

              if (identical(shouldLogout, true)) {
                // final localeBloc = BlocProvider.of<LocaleBloc>(context);
                final userRepository = Provider.of<UserRepository>(context);

                try {
                  await userRepository.logout();
                  // await localeBloc.resetLocale(S.delegate.supportedLocales[0]);
                  print('>>> logged out');
                } catch (e, s) {
                  print('>>>> logout $e $s');
                }
              }
            },
            customBorder: CircleBorder(),
            splashColor: Colors.white30,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NotLoggedIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container();
}

class _CustomClipper extends CustomClipper<Path> {
  final double maxHeight;

  _CustomClipper(this.maxHeight);

  @override
  Path getClip(Size size) {
    final startY = 0.75;
    final dy = maxHeight * startY;

    return Path()
      ..relativeLineTo(0, dy)
      ..quadraticBezierTo(
        size.width / 2,
        maxHeight * (2 - startY),
        size.width,
        dy,
      )
      ..relativeLineTo(0, -dy)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class BoxShadowPainter extends CustomPainter {
  final double maxHeight;

  BoxShadowPainter(this.maxHeight);

  @override
  void paint(Canvas canvas, Size size) {
    final startY = 0.75;
    final dy = maxHeight * startY;

    final path = Path()
      ..relativeLineTo(0, dy)
      ..quadraticBezierTo(
        size.width / 2,
        maxHeight * (2 - startY),
        size.width,
        dy,
      )
      ..relativeLineTo(0, -dy)
      ..close();

    canvas.drawShadow(path, Colors.grey.shade300, 16, false);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
