class MazeLevel {
  final int levelNumber;
  final String levelName;
  final int difficulty;
  final List<List<int>> grid; // 0=path, 1=wall, 2=start, 3=end

  MazeLevel({
    required this.levelNumber,
    required this.levelName,
    required this.difficulty,
    required this.grid,
  });
}
