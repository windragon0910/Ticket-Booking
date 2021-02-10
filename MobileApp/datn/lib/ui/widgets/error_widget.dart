import 'package:flutter/material.dart';

import '../../generated/l10n.dart';

class MyErrorWidget extends StatelessWidget {
  final String errorText;
  final void Function() onPressed;

  const MyErrorWidget({
    Key key,
    @required this.errorText,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          errorText,
          style: Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 15),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: ElevatedButton(
            child: Text(S.of(context).retry),
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 32,
              ),
              primary: Theme.of(context).canvasColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DarkMyErrorWidget extends StatelessWidget {
  final String errorText;
  final void Function() onPressed;

  const DarkMyErrorWidget({
    Key key,
    @required this.errorText,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          errorText,
          style: Theme.of(context).textTheme.subtitle2.copyWith(
                fontSize: 15,
                color: Colors.white,
              ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: ElevatedButton(
            child: Text(
              'Retry',
              style: Theme.of(context)
                  .textTheme
                  .button
                  .copyWith(color: Colors.white),
            ),
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 32,
              ),
              primary: const Color(0xff0ed3f9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
