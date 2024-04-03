enum GameBoardSize {
  small(x: 5, y: 6),
  medium(x: 5, y: 7),
  large(x: 6, y: 8);

  final int x;
  final int y;

  @override
  String toString() => '$x x $y';
  const GameBoardSize({required this.x, required this.y});
}
