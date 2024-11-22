import 'package:game_common/src/gameplay/gameplay_features.dart';
import 'package:rondas_relampago/source/models/gameplay/game_units/game_unit.dart'
    show GameMarker;
import 'package:uuid/uuid.dart';
import 'package:uuid/v1.dart';

class GameAuth {
  final String id;
  final int version = 1;
  final String? roomId;

  const GameAuth(this.id, {this.roomId});

  factory GameAuth.init() => GameAuth(
      UuidValue.fromString(UuidV1().generate().toString()).toFormattedString());

  GameAuth copyWith({String? id, String? roomId}) =>
      GameAuth(id ?? this.id, roomId: roomId ?? this.roomId);

  GameAuth.fromJson(Map<String, dynamic> json)
      : id = UuidValue.fromString(json['id']).toFormattedString(),
        roomId = json['roomId'] == "null"
            ? null
            : UuidValue.fromString(json['roomId']).toFormattedString();

  Map<String, dynamic> toJson() => {'id': id, 'roomId': roomId.toString()};

  @override
  bool operator ==(Object other) =>
      other is GameAuth &&
      other.runtimeType == runtimeType &&
      // other.version == version &&
      other.id == id;

  @override
  int get hashCode => id.hashCode;
}

sealed class GameCommunicationMessage {
  factory GameCommunicationMessage.fromJson(Map<String, dynamic> json) {
    print(json);
    switch (GameCommunicationMessageTypes.fromJson(json['type'])) {
      case GameCommunicationMessageTypes.connection:
        {
          return ConnectionMessage.fromJson(json['message']);
        }
      case GameCommunicationMessageTypes.match:
        {
          return MatchMessage.fromJson(json['message']);
        }
      case GameCommunicationMessageTypes.matchPlay:
        {
          return MatchPlayMessage.fromJson(json['message']);
        }
      case GameCommunicationMessageTypes.serverPlay:
        {
          return ServerPlayMessage.fromJson(json['message']);
        }
      default:
        throw (InvalidGameCommunicationMessageException);
    }
  }

  static Map<String, dynamic> toJson(GameCommunicationMessage message) {
    return switch (message) {
      ConnectionMessage message => {
          'type': GameCommunicationMessageTypes.connection.toJson(),
          'message': message.toJson(message),
        },
      MatchMessage message => {
          'type': GameCommunicationMessageTypes.match.toJson(),
          'message': message.toJson(message),
        },
      MatchPlayMessage message => {
          'type': GameCommunicationMessageTypes.matchPlay.toJson(),
          'message': message.toJson(message),
        },
      ServerPlayMessage message => {
          'type': GameCommunicationMessageTypes.serverPlay.toJson(),
          'message': message.toJson(message),
        },
    };
  }
}

enum GameCommunicationMessageTypes {
  connection("Connection"),
  match("Match"),
  matchPlay("Match Play"),
  serverPlay("Server Play");

  final String value;

  String toJson() => value;

  static GameCommunicationMessageTypes fromJson(
    String json,
  ) {
    switch (json) {
      case "Connection":
        {
          return GameCommunicationMessageTypes.connection;
        }
      case "Match":
        {
          return GameCommunicationMessageTypes.match;
        }
      case "Match Play":
        {
          return GameCommunicationMessageTypes.matchPlay;
        }
      case "Server Play":
        {
          return GameCommunicationMessageTypes.serverPlay;
        }
      default:
        throw (InvalidGameCommunicationMessageTypeException);
    }
  }

  const GameCommunicationMessageTypes(
    this.value,
  );
}

final class ConnectionMessage implements GameCommunicationMessage {
  final GameAuth id;

  const ConnectionMessage({
    required this.id,
  });

  ConnectionMessage.fromJson(
    Map<String, dynamic> json,
  ) : id = GameAuth.fromJson(
          json,
        );

  Map<String, dynamic> toJson(
    GameCommunicationMessage message,
  ) =>
      id.toJson();
}

final class MatchMessage implements GameCommunicationMessage {
  final String textMessage;

  const MatchMessage({
    required this.textMessage,
  });

  MatchMessage.fromJson(
    Map<String, dynamic> json,
  ) : textMessage = json['message'];

  Map<String, dynamic> toJson(
    GameCommunicationMessage message,
  ) =>
      {
        "message": textMessage,
      };

  @override
  String toString() => textMessage;
}

final class MatchPlayMessage implements GameCommunicationMessage {
  final ({
    MatchUnits units,
    MatchMarkers markers,
  }) playerPlay;

  const MatchPlayMessage({
    required this.playerPlay,
  });

  MatchPlayMessage.fromJson(
    Map<String, dynamic> json,
  ) : playerPlay = (
          units: MatchUnits.fromJson(
            json['units'],
          ),
          markers: (json['markers'] as List)
              .map(
                (
                  e,
                ) =>
                    GameMarker.fromJson(
                  e,
                ),
              )
              .toSet(),
        );

  Map<String, dynamic> toJson(
    GameCommunicationMessage message,
  ) =>
      {
        "units": switch (playerPlay.units) {
          CasualMatchUnits units => {
              'type': MatchUnitsTypes.casualMatchUnits.toJson(),
              'units': units.toJson(
                units,
              ),
            },
        },
        "markers": playerPlay.markers.toList(),
      };

  @override
  String toString() => playerPlay.toString();
}

final class ServerPlayMessage implements GameCommunicationMessage {
  final ({
    MatchUnits units,
    MatchMarkers markers,
    String id,
  }) player1Play;

  final ({
    MatchUnits units,
    MatchMarkers markers,
    String id,
  }) player2Play;

  const ServerPlayMessage({
    required this.player1Play,
    required this.player2Play,
  });

  ServerPlayMessage.fromJson(
    Map<String, dynamic> json,
  )   : player1Play = (
          units: MatchUnits.fromJson(json['playerOneUnits']),
          markers: (json['playerOneMarkers'] as List)
              .map((e) => GameMarker.fromJson(e))
              .toSet(),
          id: json['playerOneId'],
        ),
        player2Play = (
          units: MatchUnits.fromJson(json['playerTwoUnits']),
          markers: (json['playerTwoMarkers'] as List)
              .map((e) => GameMarker.fromJson(e))
              .toSet(),
          id: json['playerTwoId'],
        );

  Map<String, dynamic> toJson(
    GameCommunicationMessage message,
  ) =>
      {
        "playerOneId": player1Play.id,
        "playerOneUnits": switch (player1Play.units) {
          CasualMatchUnits units => {
              'type': MatchUnitsTypes.casualMatchUnits.toJson(),
              'units': units.toJson(units),
            },
        },
        "playerOneMarkers": player1Play.markers.toList(),
        "playerTwoId": player2Play.id,
        "playerTwoUnits": switch (player2Play.units) {
          CasualMatchUnits units => {
              'type': MatchUnitsTypes.casualMatchUnits.toJson(),
              'units': units.toJson(units),
            },
        },
        "playerTwoMarkers": player2Play.markers.toList(),
      };

  @override
  String toString() => '${player1Play.toString()}, ${player2Play.toString()}';
}

sealed class InvalidGameCommunicationMessageException implements Exception {}

sealed class InvalidGameCommunicationMessageTypeException
    implements InvalidGameCommunicationMessageException {}
