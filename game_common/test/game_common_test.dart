import 'dart:convert';

import 'package:game_common/game_common.dart';
import 'package:rondas_relampago/source/models/gameplay/game_units/game_unit.dart';
// import 'package:rondas_relampago/source/models/gameplay/game_units/game_unit.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid_value.dart';
import 'package:uuid/v1.dart';

void main() {
  group('GameAuth Serializations', () {
    final id = GameAuth.init();

    {
      final serialized = id.toJson();

      test('Auth ID Serialization', () {
        expect(
          id.id ==
              GameAuth.fromJson(
                serialized,
              ).id,
          isTrue,
        );
      });

      test('Null Room ID Serialization', () {
        expect(
          id.roomId ==
              GameAuth.fromJson(
                serialized,
              ).roomId,
          isTrue,
        );
      });
    }

    // setUp(() {
    //   // Additional setup goes here.
    // });
    {
      final idInRoom = id.copyWith(
        roomId: UuidValue.fromString(
          UuidV1().toString(),
        ).toFormattedString(),
      );

      final serialized = idInRoom.toJson();

      test('Valid Room ID Serialization', () {
        expect(
          idInRoom.roomId ==
              GameAuth.fromJson(
                serialized,
              ).roomId,
          isTrue,
        );
      });
    }
  });

  group('Game Messages Serializations', () {
    {
      final message = ConnectionMessage(
        id: GameAuth.init(),
      );

      final serialized = GameCommunicationMessage.toJson(
        message,
      );

      test('Connection Message Serialization', () {
        expect(
          message.id ==
              (GameCommunicationMessage.fromJson(
                serialized,
              ) as ConnectionMessage)
                  .id,
          isTrue,
        );
      });
    }

    {
      final message = MatchMessage(
        textMessage: "textMessage",
      );

      final serialized = GameCommunicationMessage.toJson(
        message,
      );

      test('Match Message Serialization', () {
        expect(
          message.textMessage ==
              (GameCommunicationMessage.fromJson(
                serialized,
              ) as MatchMessage)
                  .textMessage,
          isTrue,
        );
      });
    }

    {
      final message = MatchPlayMessage(
        playerPlay: (
          markers: {
            GameMarker(
              xCoordinate: 1,
              yCoordinate: 2,
            )
          },
          units: CasualMatchUnits(
            (
              GameUnitLarge(2, 2, GameUnitOrientation.horizontal),
              GameUnitMedium(3, 3, GameUnitOrientation.vertical),
              null,
            ),
          ),
        ),
      );

      final serialized = GameCommunicationMessage.toJson(
        message,
      );

      test('Match Play Message Serialization - Player Units', () {
        expect(
          message.playerPlay.units.hitBoxes
              .difference((GameCommunicationMessage.fromJson(
                serialized,
              ) as MatchPlayMessage)
                  .playerPlay
                  .units
                  .hitBoxes)
              .isEmpty,
          isTrue,
        );
      });

      test('Match Play Message Serialization - Player Markers', () {
        expect(
          message.playerPlay.markers
              .difference((GameCommunicationMessage.fromJson(
                serialized,
              ) as MatchPlayMessage)
                  .playerPlay
                  .markers)
              .isEmpty,
          isTrue,
        );
      });
    }
  });

  group('Game Units Serializations', () {
    {
      final unit = GameUnit.fromSize(
        GameUnitSize.medium,
        GameUnitOrientation.horizontal,
        x: 3,
        y: 6,
      );

      final serialized = jsonEncode(unit);

      print(serialized);

      test('Connection Message Serialization', () {
        expect(
          unit == GameUnit.fromJson(jsonDecode(serialized)),
          isTrue,
        );
      });
    }
  });
}
