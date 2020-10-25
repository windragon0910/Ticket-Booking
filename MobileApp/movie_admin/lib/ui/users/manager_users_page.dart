import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'manage_user_state.dart';

import '../../domain/model/user.dart';
import 'manager_users_bloc.dart';

class ManagerUsersPage extends StatefulWidget {
  static const routeName = '/manager_users';

  @override
  _ManagerUsersPageState createState() => _ManagerUsersPageState();
}

class _ManagerUsersPageState extends State<ManagerUsersPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isOpeningSlide = false;
  ScrollController _listUserController;

  SlidableController _slidableController;

  ManagerUsersBloc _bloc;

  final _listUsers = <User>[];

  @override
  @protected
  void initState() {
    super.initState();
    _slidableController = SlidableController(
      onSlideAnimationChanged: (_) {},
      onSlideIsOpenChanged: (isOpen) {
        setState(() => _isOpeningSlide = isOpen);
      },
    );
    _listUserController = ScrollController()
      ..addListener(() {
        if (_listUserController.position.pixels ==
            _listUserController.position.maxScrollExtent) {
          _bloc.loadUsers(_listUsers.length);
        }
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bloc == null) {
      _bloc = BlocProvider.of<ManagerUsersBloc>(context);
      _bloc.loadUsers(_listUsers.length);
    }
  }

  Widget _buildSearchUser() {
    return SizedBox(width: 10, height: 10);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Users'),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildSearchUser(),
          _buildListUsers(_bloc),
        ],
      ),
      floatingActionButton: _isOpeningSlide == true
          ? null
          : FloatingActionButton(
              onPressed: null,
              child: Icon(Icons.add),
            ),
    );
  }

  bool _isHasUserInList(User user, List<User> listUser) =>
      listUser.map((e) => e.uid).contains(user.uid);

  Widget _buildListUsers(ManagerUsersBloc bloc) {
    return StreamBuilder<ManageUserState>(
        stream: bloc.renderListStream$,
        builder: (context, snapShort) {
          print(snapShort.data.toString() + '>>>>>>>>');
          if (snapShort.data is LoadUserSuccess) {
            final data = snapShort.data as LoadUserSuccess;
            _listUsers.addAll(
              data.users.where(
                (user) => !_isHasUserInList(user, _listUsers),
              ),
            );
          }
          if (snapShort.data is DeleteUserSuccess) {
            final data = snapShort.data as DeleteUserSuccess;
            _listUsers.removeWhere((e) => e.uid == data.idUserDelete);
          }
          if (snapShort.data is BlockUserSuccess) {
            final data = snapShort.data as BlockUserSuccess;
            final index = _listUsers
                .indexWhere((element) => element.uid == data.user.uid);
            if (index != -1) {
              _listUsers.removeAt(index);
              _listUsers.insert(index, data.user);
            }
          }
          if (snapShort.data is UnblockUserSuccess) {
            final data = snapShort.data as UnblockUserSuccess;
            final index = _listUsers
                .indexWhere((element) => element.uid == data.user.uid);
            if (index != -1) {
              _listUsers.removeAt(index);
              _listUsers.insert(index, data.user);
            }
          }
          return Expanded(
            child: ListView.builder(
              controller: _listUserController,
              itemBuilder: (context, index) => index == _listUsers.length
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [CircularProgressIndicator()],
                    )
                  : _buildItemUserByIndex(_listUsers[index]),
              itemCount: snapShort.data is LoadingUsersState
                  ? _listUsers.length + 1
                  : _listUsers.length,
            ),
          );
        });
  }

  Future<bool> _showDialogConfirm(String text, String description) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(text),
          content: Text(description),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            FlatButton(
              child: Text('Ok'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  Widget _buildItemUserByIndex(User user) {
    return user.uid == null
        ? Text('Error')
        : StreamBuilder<Map<String, DestroyUserType>>(
            stream: _bloc.renderItemRemove$,
            builder: (context, snapShort) {
              return Slidable.builder(
                key: Key(user.uid),
                controller: _slidableController,
                actionPane: SlidableScrollActionPane(),
                actionExtentRatio: 0.2,
                child: UserItemWidget(user),
                secondaryActionDelegate: SlideActionBuilderDelegate(
                  actionCount: 2,
                  builder: (context, index, animation, renderingMode) {
                    final isContainsUser =
                        snapShort.data?.containsKey(user.uid) ?? false;
                    final data = snapShort.data ?? {};
                    final iconBlock = isContainsUser &&
                            (data[user.uid] == DestroyUserType.BLOCK ||
                                data[user.uid] == DestroyUserType.UNBLOCK)
                        ? Center(child: CircularProgressIndicator())
                        : IconSlideAction(
                            caption: user.isActive ? 'Block' : 'Unblock',
                            color:
                                user.isActive ? Colors.limeAccent : Colors.grey,
                            icon: Icons.block,
                            onTap: () async {
                              final isDismiss = await _showDialogConfirm(
                                user.isActive
                                    ? 'Block this user'
                                    : 'Unblock this user',
                                user.isActive
                                    ? 'User will be block '
                                    : 'User will be unblock ',
                              );
                              if (isDismiss) {
                                _bloc.destroyUser(
                                    MapEntry(user, user.isActive ? DestroyUserType.BLOCK : DestroyUserType.UNBLOCK));
                              }
                            },
                          );
                    final iconRemove = isContainsUser &&
                            data[user.uid] == DestroyUserType.REMOVE
                        ? Center(child: CircularProgressIndicator())
                        : IconSlideAction(
                            caption: 'Delete',
                            color: Colors.red,
                            icon: Icons.delete,
                            onTap: () async {
                              final isDismiss = await _showDialogConfirm(
                                'Delete this user',
                                'User will be deleted ',
                              );
                              if (isDismiss) {
                                _bloc.destroyUser(
                                    MapEntry(user, DestroyUserType.REMOVE));
                              }
                            },
                          );
                    return index == 0 ? iconBlock : iconRemove;
                  },
                ),
              );
            },
          );
  }

  void _showSnackBar(BuildContext context, String text) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class UserItemWidget extends StatelessWidget {
  UserItemWidget(this.user);

  final User user;

  @override
  Widget build(BuildContext context) {
    final slide = Slidable.of(context);
    return GestureDetector(
      onTap: () => slide?.renderingMode == SlidableRenderingMode.none
          ? slide?.open()
          : slide?.close(),
      child: Container(
          color: Colors.white,
          child: Row(
            children: [
              _buildAvatar(70, context),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(user.email),
                  SizedBox(height: 5),
                  _buildStatusUser(user.isActive),
                ],
              )
            ],
          )),
    );
  }

  Widget _buildAvatar(double imageSize, BuildContext context) {
    return Container(
      width: imageSize,
      height: imageSize,
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).backgroundColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            offset: Offset(0.0, 1.0),
            color: Colors.grey.shade500,
            spreadRadius: 1,
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
    );
  }

  Widget _buildStatusUser(bool isActive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'status: ',
          style: TextStyle(fontSize: 8),
        ),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
              color: isActive ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(3)),
        )
      ],
    );
  }
}