// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

const Set<Song> songs = {
  // Filenames with whitespace break package:audioplayers on iOS
  // (as of February 2022), so we use no whitespace.
  Song('RR-01_(Faded).wav', 'Jumpy', artist: 'Samuel Bidó'),
  Song('RR-02+_(Faded).wav', 'Ham', artist: 'Samuel Bidó'),
  Song('RR-01S.wav', 'Jumpy (w/ Bass)', artist: 'Samuel Bidó'),
};

class Song {
  final String filename;

  final String name;

  final String? artist;

  const Song(this.filename, this.name, {this.artist});

  @override
  String toString() => 'Song<$filename>';
}
