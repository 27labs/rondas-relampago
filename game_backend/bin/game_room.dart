// import 'dart:js_interop';

import 'package:game_common/game_common.dart';
import 'package:rondas_relampago/source/models/gameplay/game_units/game_unit.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_value.dart';
import 'package:uuid/v1.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

export 'package:rondas_relampago/source/models/gameplay/game_units/game_unit.dart';

class GameAuthWithChannel {
  final GameAuth id;
  final WebSocketChannel? channel;
  const GameAuthWithChannel(
    this.id, {
    this.channel,
  });
}

class GameRoomPool {
  Map<
      UuidValue,
      (
        List<
            ({
              Set<GameMarker> markers,
              MatchUnits units,
              UuidValue playerId,
            })>,
        Set<GameAuthWithChannel>
      )> _activeRooms = {};

  void addRooms(
    List<
            (
              UuidValue?,
              Set<GameAuth>,
            )>
        rooms,
  ) {
    for (final value in rooms) {
      final id = value.$1 ??
          UuidValue.fromString(
            UuidV1().generate().toString(),
          );
      _activeRooms[id] = _activeRooms[id] ?? ([], {});
      _activeRooms[id]!.$2.addAll(
            value.$2.map(
              (
                e,
              ) =>
                  GameAuthWithChannel(
                e,
              ),
            ),
          );
    }
  }

  List<
      ({
        Set<GameMarker> markers,
        MatchUnits units,
        UuidValue playerId,
      })>? setPlayerPlay(
    GameAuth id,
    int amountOfPlaysRequired, {
    required MatchUnits units,
    required Set<GameMarker> markers,
  }) {
    if (id.roomId != null) {
      final roomId = UuidValue.fromString(
        id.roomId!,
      );

      if (((_activeRooms[roomId]?.$1.length ?? (amountOfPlaysRequired)) + 1) <=
          amountOfPlaysRequired) {
        _activeRooms[roomId] = (
          _activeRooms[roomId]!.$1
            ..add(
              (
                markers: markers,
                units: units,
                playerId: UuidValue.fromString(
                  id.id,
                ),
              ),
            ),
          _activeRooms[roomId]!.$2,
        );
      }

      print(
        _activeRooms[roomId]?.$1.length,
      );

      if (((_activeRooms[roomId]?.$1.length ?? (amountOfPlaysRequired - 2)) +
              1) >=
          amountOfPlaysRequired) {
        return _activeRooms[roomId]!.$1;
      }
    }

    return null;
  }

  UuidValue _getAvailableRoom() {
    for (final room in _activeRooms.entries) {
      if (room.value.$2.length < 2) return room.key;
    }

    return UuidValue.fromString(
      UuidV1().generate().toString(),
    );
  }

  UuidValue joinRoom(
    GameAuth id, {
    UuidValue? room,
    required WebSocketChannel channel,
  }) {
    final roomId = switch (room) {
      null => _getAvailableRoom(),
      _ => room,
    };
    _activeRooms[roomId] = _activeRooms[roomId] ?? ([], {});
    _activeRooms[roomId]!.$2.add(
          GameAuthWithChannel(
            id,
            channel: channel,
          ),
        );
    return roomId;
  }

  List<
      (
        UuidValue,
        WebSocketChannel?,
      )> _usersInRoom(
    UuidValue roomId,
  ) {
    // if(roomId == null) return null;

    // final roomId = UuidValue.fromString(id.roomId!);
    return _activeRooms[roomId]
            ?.$2
            .map(
              (
                e,
              ) =>
                  (
                UuidValue.fromString(
                  e.id.id,
                ),
                e.channel,
              ),
            )
            .toList() ??
        [];
  }

  List<
      (
        UuidValue,
        WebSocketChannel?,
      )> getOtherUsers(
    UuidValue? roomId,
  ) =>
      roomId == null
          ? []
          : _usersInRoom(
              roomId,
            )
        ..retainWhere(
          (
            element,
          ) =>
              element.$2 != null,
        );

  int get numberOfRooms => _activeRooms.length;

  GameRoomPool();

  factory GameRoomPool.restore(
    List<
            (
              UuidValue?,
              Set<GameAuth>,
            )>
        rooms,
  ) {
    GameRoomPool newServer = GameRoomPool();
    newServer.addRooms(
      rooms,
    );
    return newServer;
  }
}
