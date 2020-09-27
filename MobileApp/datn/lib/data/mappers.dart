import 'package:built_collection/built_collection.dart';
import 'package:tuple/tuple.dart';

import '../domain/model/comment.dart';
import '../domain/model/comments.dart';
import '../domain/model/location.dart';
import '../domain/model/movie.dart';
import '../domain/model/show_time.dart';
import '../domain/model/theatre.dart';
import '../domain/model/theatre_and_show_times.dart';
import '../domain/model/user.dart';
import '../utils/date_time.dart';
import '../utils/iterable.dart';
import 'local/user_local.dart';
import 'remote/response/comment_response.dart';
import 'remote/response/comments_response.dart';
import 'remote/response/movie_response.dart';
import 'remote/response/show_time_and_theatre_response.dart';
import 'remote/response/show_time_response.dart';
import 'remote/response/theatre_response.dart';
import 'remote/response/user_response.dart';

UserLocal userResponseToUserLocal(UserResponse response) {
  return UserLocal((b) {
    final locationLocalBuilder = response.location?.latitude != null &&
            response.location?.longitude != null
        ? (LocationLocalBuilder()
          ..latitude = response.location.latitude
          ..longitude = response.location.longitude)
        : null;

    return b
      ..uid = response.uid
      ..email = response.email
      ..phoneNumber = response.phoneNumber
      ..fullName = response.fullName
      ..gender = response.gender
      ..avatar = response.avatar
      ..address = response.address
      ..birthday = response.birthday
      ..location = locationLocalBuilder
      ..isCompleted = response.isCompleted
      ..isActive = response.isActive ?? true;
  });
}

Gender stringToGender(String s) {
  if (s == 'MALE') {
    return Gender.MALE;
  }
  if (s == 'FEMALE') {
    return Gender.FEMALE;
  }
  throw Exception("Cannot convert string '$s' to gender");
}

User userLocalToUserDomain(UserLocal local) {
  return User((b) => b
    ..uid = local.uid
    ..email = local.email
    ..phoneNumber = local.phoneNumber
    ..fullName = local.fullName
    ..gender = stringToGender(local.gender)
    ..avatar = local.avatar
    ..address = local.address
    ..birthday = local.birthday
    ..location = local.location != null
        ? (LocationBuilder()
          ..latitude = local.location.latitude
          ..longitude = local.location.longitude)
        : null
    ..isCompleted = local.isCompleted
    ..isActive = local.isActive ?? true);
}

Movie movieResponseToMovie(MovieResponse res) {
  return Movie(
    (b) => b
      ..id = res.id
      ..isActive = res.is_active ?? true
      ..actors = (b.actors..replace(res.actors))
      ..directors = (b.directors..replace(res.directors))
      ..title = res.title
      ..trailerVideoUrl = res.trailer_video_url
      ..posterUrl = res.poster_url
      ..overview = res.overview
      ..releasedDate = res.released_date
      ..duration = res.duration
      ..originalLanguage = res.original_language
      ..createdAt = res.createdAt
      ..updatedAt = res.updatedAt
      ..ageType = stringToAgeType(res.age_type),
  );
}

AgeType stringToAgeType(String s) {
  return AgeType.values.firstWhere(
    (v) => v.toString().split('.')[1] == s,
    orElse: () => throw Exception("Cannot convert string '$s' to AgeType"),
  );
}

Location locationResponseToLocation(LocationResponse response) {
  return Location((b) => b
    ..longitude = response.longitude
    ..latitude = response.latitude);
}

Theatre theatreResponseToTheatre(TheatreResponse response) {
  return Theatre((b) {
    final locationBuilder = b.location
      ..replace(locationResponseToLocation(response.location));
    final roomsBuilder = b.rooms..replace(response.rooms);

    return b
      ..id = response.id
      ..location = locationBuilder
      ..is_active = response.is_active ?? true
      ..rooms = roomsBuilder
      ..name = response.name
      ..address = response.address
      ..phone_number = response.phone_number
      ..description = response.description
      ..email = response.email
      ..opening_hours = response.opening_hours
      ..room_summary = response.room_summary
      ..createdAt = response.createdAt
      ..updatedAt = response.updatedAt;
  });
}

ShowTime showTimeResponseToShowTime(ShowTimeResponse response) {
  return ShowTime((b) => b
    ..id = response.id
    ..is_active = response.is_active ?? true
    ..movie = response.movie
    ..theatre = response.theatre
    ..room = response.room
    ..end_time = response.end_time
    ..start_time = response.start_time
    ..createdAt = response.createdAt
    ..updatedAt = response.updatedAt);
}

BuiltMap<DateTime, BuiltList<TheatreAndShowTimes>>
    showTimeAndTheatreResponsesToTheatreAndShowTimes(
  BuiltList<ShowTimeAndTheatreResponse> responses,
) {
  final _showTimeAndTheatreResponseToTuple2 =
      (ShowTimeAndTheatreResponse response) => Tuple2(
            theatreResponseToTheatre(response.theatre),
            showTimeResponseToShowTime(response.show_time),
          );

  final _tuplesToMapEntry = (
    DateTime day,
    List<Tuple2<Theatre, ShowTime>> tuples,
  ) {
    final theatreAndShowTimes = tuples
        .groupBy(
          (tuple) => tuple.item1,
          (tuple) => tuple.item2,
        )
        .entries
        .map(
          (entry) => TheatreAndShowTimes(
            (b) {
              final showTimesBuilder = b.showTimes
                ..addAll(entry.value)
                ..sort((l, r) => l.start_time.compareTo(r.start_time));

              final theatreBuilder = b.theatre..replace(entry.key);

              return b
                ..theatre = theatreBuilder
                ..showTimes = showTimesBuilder;
            },
          ),
        )
        .toBuiltList();
    return MapEntry(day, theatreAndShowTimes);
  };

  final showTimesByDate = responses
      .map(_showTimeAndTheatreResponseToTuple2)
      .groupBy(
        (tuple) => startOfDay(tuple.item2.start_time),
        (tuple) => tuple,
      )
      .map(_tuplesToMapEntry);

  return showTimesByDate.build();
}

Comments commentsResponseToComments(CommentsResponse response) {
  return Comments((b) {
    final listBuilder = b.comments
      ..update(
        (cb) => cb.addAll(
          response.comments.map(commentResponseToComment),
        ),
      );

    return b
      ..total = response.total
      ..average = response.average
      ..comments = listBuilder;
  });
}

Comment commentResponseToComment(CommentResponse response) {
  return Comment((b) {
    final userBuilder = b.user..replace(userResponseToUser(response.user));

    return b
      ..id = response.id
      ..is_active = response.is_active ?? true
      ..content = response.content
      ..rate_star = response.rate_star
      ..movie = response.movie
      ..user = userBuilder
      ..createdAt = response.createdAt
      ..updatedAt = response.updatedAt;
  });
}

User userResponseToUser(UserResponse response) {
  return User((b) {
    final locationBuilder = response.location != null &&
            response.location.latitude != null &&
            response.location.longitude != null
        ? (b.location..replace(locationResponseToLocation(response.location)))
        : null;

    return b
      ..uid = response.uid
      ..email = response.email
      ..phoneNumber = response.phoneNumber
      ..fullName = response.fullName
      ..gender = stringToGender(response.gender)
      ..avatar = response.avatar
      ..address = response.address
      ..birthday = response.birthday
      ..location = locationBuilder
      ..isCompleted = response.isCompleted
      ..isActive = response.isActive ?? true;
  });
}
