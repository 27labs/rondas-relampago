import 'dart:convert';
import 'dart:io';

import 'package:game_common/game_common.dart';
// import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart' as wssd;
import 'package:uuid/enums.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:uuid/uuid_value.dart';
import 'package:uuid/v1.dart';

import 'game_room.dart';
// import 'package:game_common/game_common.dart';

// Configure routes.
final _router = Router()
  ..get('/', _rootHandler)
  ..get('/ws', wssd.webSocketHandler(_webSocketHandler));

Response _rootHandler(
  Request req,
) {
  return Response.ok('Hello, World!\n');
}

Map<WebSocketChannel, GameAuth?> connections = {};
// Map<UuidValue, WebSocketChannel> users = {};

GameRoomPool rooms = GameRoomPool();

void _webSocketHandler(
  WebSocketChannel channel,
) {
  connections.putIfAbsent(
    channel,
    () => null,
  );

  channel.stream.listen(
    (
      envoy,
    ) {
      print(envoy);
      final message = GameCommunicationMessage.fromJson(
        jsonDecode(
          envoy,
        ),
      );

      if (message is ConnectionMessage) {
        try {
          UuidValue.withValidation(
            message.id.roomId.toString(),
            ValidationMode.strictRFC4122,
          );
          connections[channel] = message.id;
          rooms.joinRoom(
            message.id,
            room: UuidValue.fromString(
              message.id.roomId!,
            ),
            channel: channel,
          );
          channel.sink.add(
            jsonEncode(
              GameCommunicationMessage.toJson(
                ConnectionMessage(
                  id: message.id,
                ),
              ),
            ),
          );
        } on FormatException {
          final roomId = UuidValue.fromString(
            UuidV1().generate().toString(),
          );
          final newId = message.id.copyWith(
            roomId: roomId.toFormattedString(),
          );
          connections[channel] = newId;
          rooms.joinRoom(
            newId,
            room: roomId,
            channel: channel,
          );
          channel.sink.add(
            jsonEncode(
              GameCommunicationMessage.toJson(
                ConnectionMessage(
                  id: newId,
                ),
              ),
            ),
          );
        }

        // _analyticsService(query: {
        //   'connection': null,
        //   'time': DateTime.now().weekday.toString(),
        // });
      }

      if (message is MatchMessage) {
        final senderId = connections[channel];
        if (senderId?.roomId != null) {
          rooms
              .getOtherUsers(
            UuidValue.fromString(
              senderId!.roomId!,
            ),
          )
              .forEach(
            (
              element,
            ) {
              if (element.$1 !=
                  UuidValue.fromString(
                    senderId.id,
                  ))
                element.$2!.sink.add(
                  jsonEncode(
                    GameCommunicationMessage.toJson(
                      message,
                    ),
                  ),
                );
            },
          );
        }
      }

      if (message is MatchPlayMessage) {
        final senderId = connections[channel];

        if (senderId != null) {
          switch (rooms.setPlayerPlay(
            senderId,
            2,
            units: message.playerPlay.units,
            markers: message.playerPlay.markers,
          )) {
            case List<
                  ({
                    Set<GameMarker> markers,
                    UuidValue playerId,
                    MatchUnits units
                  })> plays:
              if (senderId.roomId != null) {
                rooms
                    .getOtherUsers(
                  UuidValue.fromString(
                    senderId.roomId!,
                  ),
                )
                    .forEach(
                  (
                    element,
                  ) {
                    // if (element.$1 !=
                    //     UuidValue.fromString(
                    //       senderId.id,
                    //     )) {
                    element.$2!.sink.add(
                      jsonEncode(
                        GameCommunicationMessage.toJson(
                          ServerPlayMessage(
                            player1Play: (
                              markers: plays[0].markers,
                              units: plays[0].units,
                              id: plays[0].playerId.uuid,
                            ),
                            player2Play: (
                              markers: plays[1].markers,
                              units: plays[1].units,
                              id: plays[1].playerId.uuid,
                            ),
                          ),
                        ),
                      ),
                    );
                    // }
                  },
                );
              }
              break;
            default:
              break;
          }
        }
      }
    },
    onDone: () {
      if (connections[channel] != null) {
        final GameAuth id = connections[channel]!;
        rooms.disconnectPlayer(GameAuthWithChannel(id, channel: channel));
        connections.remove(channel);
      }
    },
  );
}

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // analytics = int.parse(Platform.environment['ANALYTICS'] ?? '8082');

  // Configure a pipeline that logs requests.
  final handler = Pipeline()
      .addMiddleware(logRequests())
      // .addMiddleware(serveAnalytics(analytics))
      .addHandler(_router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}

// Middleware serveAnalytics(int port) => (innerHandler) {
//   return (request) {
//     // print(request.requestedUri.path);
//     if(request.requestedUri.path == "/ws") {
//       print(request);
//     }

//     if(request.requestedUri.path == "/analytics") {
//       print(request.params);
//     }

//     return Future.sync(() => innerHandler(request)).then((response) {
//       return response;
//     });
//   };
// };

// late int analytics;

// void _analyticsService({required Map<String, String?> query}) {
//   http.post(Uri.http('localhost:$analytics', '/analytics', query));
// }