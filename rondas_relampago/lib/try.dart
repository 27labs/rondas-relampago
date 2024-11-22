import 'dart:convert';

import 'package:game_common/game_common.dart'
    show CasualMatchUnits, GameCommunicationMessage, MatchPlayMessage;
import 'package:rondas_relampago/source/models/gameplay/game_units/game_unit.dart';
import 'package:uuid/v1.dart';

import 'package:http/http.dart' as http;

final message = MatchPlayMessage(
  playerPlay: (
    markers: {GameMarker(xCoordinate: 2, yCoordinate: 2)},
    units: CasualMatchUnits(
      (
        // GameUnitLarge(1, 1, GameUnitOrientation.horizontal),
        null,
        null,
        null,
      ),
    ),
  ),
);

final serialized = GameCommunicationMessage.toJson(
  message,
);

main() async {
  print((GameCommunicationMessage.fromJson(serialized) as MatchPlayMessage)
      .playerPlay
      .units
      .hitBoxes);
  print(message.playerPlay.units.hitBoxes);
  print((GameCommunicationMessage.fromJson(serialized) as MatchPlayMessage)
          .playerPlay
          .units
          .hitBoxes ==
      message.playerPlay.units.hitBoxes);

  print(const UuidV1().generate().toString());

  print((await http.get(Uri.parse('http://10.0.0.5:8080/'))).body);

  // final unit = GameUnit.fromSize(
  //   GameUnitSize.medium,
  //   GameUnitOrientation.horizontal,
  //   x: 3,
  //   y: 6,
  // );

  final markers = [
    const GameMarker(
      xCoordinate: 3,
      yCoordinate: 2,
    )
  ];

  final serial = jsonEncode(markers);

  print([
    serial,
    (jsonDecode(serial) as List).map((e) => GameMarker.fromJson(e)),
  ]);
}
