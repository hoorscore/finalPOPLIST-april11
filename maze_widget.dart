import 'package:flutter/material.dart';
import 'maze_level_model.dart';
import 'main.dart';

class MazeWidget extends StatefulWidget {
  final MazeLevel level;
  const MazeWidget({Key? key, required this.level}) : super(key: key);

  @override
  State<MazeWidget> createState() => _MazeWidgetState();
}

class _MazeWidgetState extends State<MazeWidget> {
  late List<List<int>> mazeGrid;
  late int playerRow;
  late int playerCol;
  late int endRow;
  late int endCol;

  @override
  void initState() {
    super.initState();
    initializeMaze();
  }

  void initializeMaze() {
    mazeGrid = widget.level.grid;
    for (int i = 0; i < mazeGrid.length; i++) {
      for (int j = 0; j < mazeGrid[i].length; j++) {
        if (mazeGrid[i][j] == 2) {
          playerRow = i;
          playerCol = j;
        } else if (mazeGrid[i][j] == 3) {
          endRow = i;
          endCol = j;
        }
      }
    }
  }

  void movePlayer(int newRow, int newCol) {
    if (newRow >= 0 && newRow < mazeGrid.length &&
        newCol >= 0 && newCol < mazeGrid[0].length &&
        (mazeGrid[newRow][newCol] == 0 || mazeGrid[newRow][newCol] == 3)) {
      setState(() {
        playerRow = newRow;
        playerCol = newCol;
      });

      if (playerRow == endRow && playerCol == endCol) {
        showDialog(
          context: context,
          builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: const Text('مبروك!', textAlign: TextAlign.right),
              content: const Text('لقد أكملت المستوى بنجاح!', textAlign: TextAlign.right),
              actionsAlignment: MainAxisAlignment.start,
              actions: [
                TextButton(
                  onPressed: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => TaskEntryScreen())),
                  child: const Text('حسناً'),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  Widget _buildDirectionButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 65,
      height: 65,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFCC63),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 32),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cellSize = (screenWidth / mazeGrid[0].length).clamp(30.0, 60.0);

    return Column(
      children: [
        SizedBox(
          width: screenWidth,
          height: cellSize * mazeGrid.length,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: mazeGrid[0].length,
              childAspectRatio: 1.0,
            ),
            itemCount: mazeGrid.length * mazeGrid[0].length,
            itemBuilder: (context, index) {
              final row = index ~/ mazeGrid[0].length;
              final col = index % mazeGrid[0].length;
              final cell = mazeGrid[row][col];
              final isPath = cell == 0 || cell == 2 || cell == 3;
              final isCurrentCell = row == playerRow && col == playerCol;
              final isEndCell = row == endRow && col == endCol;

              return GestureDetector(
                onTap: () => movePlayer(row, col),
                child: Container(
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: isPath ? Colors.white : Colors.transparent,
                    border: Border.all(
                      color: isPath ? Colors.blue[200]! : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isCurrentCell
                      ? Center(
                    child: Image.asset(
                      'assets/goldfish.png',
                      width: cellSize * 0.7,
                      height: cellSize * 0.7,
                    ),
                  )
                      : isEndCell
                      ? Center(
                    child: Icon(
                      Icons.flag,
                      color: Colors.green,
                      size: cellSize * 0.5,
                    ),
                  )
                      : null,
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDirectionButton(Icons.arrow_upward, () => movePlayer(playerRow - 1, playerCol)),
              _buildDirectionButton(Icons.arrow_back, () => movePlayer(playerRow, playerCol - 1)),
              _buildDirectionButton(Icons.arrow_forward, () => movePlayer(playerRow, playerCol + 1)),
              _buildDirectionButton(Icons.arrow_downward, () => movePlayer(playerRow + 1, playerCol)),
            ],
          ),
        ),
      ],
    );
  }
}
