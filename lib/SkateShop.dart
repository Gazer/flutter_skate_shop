import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class SkateShop extends StatefulWidget {
  @override
  _SkateShopState createState() => _SkateShopState();
}

class _SkateShopState extends State<SkateShop> with SingleTickerProviderStateMixin {
  List<SkateBoard> data = null;

  ScrollController _scrollController;
  AnimationController _animationController;

  double rotation = 0;
  double scrollStartAt = 0;

  Color backgroundColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      backgroundColor: backgroundColor,
      body: NotificationListener(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            _animationController.reverse(from: rotation.abs());
          }
          if (notification is ScrollStartNotification) {
            scrollStartAt = _scrollController.offset;
          }

          return false;
        },
        child: ListView(
          controller: _scrollController,
          children: <Widget>[
            for (SkateBoard board in data)
              SkateItemWidget(
                rotation: rotation,
                title: "SLIME MONSTER",
                imagePath: board.imagePath,
                price: "\$240",
                colors: board.colors,
              ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      var dx = _scrollController.offset - scrollStartAt;

      setState(() {
        rotation = dx / 50;
        if (rotation > 1) {
          rotation = 1;
        } else if (rotation < -1) {
          rotation = -1;
        }

        if (_scrollController.offset > 50) {
          backgroundColor = data.last.colors.color;
        } else {
          backgroundColor = data.first.colors.color;
        }
      });
    });

    _animationController = AnimationController(
        vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animationController.addListener(() {
      setState(() {
        rotation = rotation.sign * _animationController.value;
      });
    });

    _initializeColors().then((list) {
      setState(() {
        data = list;

        backgroundColor = data.first.colors.color;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<SkateBoard>> _initializeColors() async {
    var images = [
      "board1.png",
      "board2.png",
      "board3.png",
      "board4.png",
      "board5.png",
      "board6.png"
    ];

    List<SkateBoard> list = [];

    for (String image in images) {
      String imagePath = "assets/$image";
      PaletteGenerator colors =
          await PaletteGenerator.fromImageProvider(AssetImage(imagePath));
      list.add(SkateBoard(imagePath, colors.dominantColor));
    }

    return list;
  }
}

class SkateBoard {
  final String imagePath;
  final PaletteColor colors;

  SkateBoard(this.imagePath, this.colors);
}

class SkateItemWidget extends StatelessWidget {
  final String title;
  final String imagePath;
  final String price;
  final PaletteColor colors;
  final double rotation;

  const SkateItemWidget(
      {Key key, this.rotation, this.title, this.imagePath, this.price, this.colors})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(rotation);
    return Container(
      color: colors.color,
      height: 200,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.bodyTextColor,
                  letterSpacing: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Text(
                price,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.bodyTextColor,
                  letterSpacing: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            RotatedBox(
              quarterTurns: 3,
              child: Transform(
                transform: Matrix4.rotationY(rotation),
                alignment: FractionalOffset.center,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                        color: colors.bodyTextColor,
                        blurRadius: 50,
                        offset: Offset(50 * rotation, 0),
                      ),
                    ]),
                    child: Image.asset(imagePath),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
