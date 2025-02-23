import 'package:flutter/material.dart';

const double _kItemWidth = 56.0;
const double _kBarHeight = 64.0;
const double _kBallWidth = 80.0;
const _transitionDuration = Duration(milliseconds: 300);

class BottomNavBar extends StatefulWidget {
  final int currentPage;
  final ValueChanged<int> onChanged;

  const BottomNavBar({
    super.key,
    required this.currentPage,
    required this.onChanged,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final _item1 = GlobalKey();
  final _item2 = GlobalKey();
  final _item3 = GlobalKey();
  double? _position;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _move(_item1, 0);
    });
  }

  void _move(GlobalKey item, int index) {
    final renderBox = item.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    setState(() {
      _position = offset.dx - (_kBallWidth - _kItemWidth) / 2;
    });
    widget.onChanged(index);
  }

  Future<bool> _preventPop() async {
    final canPop = widget.currentPage > 0;
    if (canPop) {
      _move(_item1, 0);
    }
    return !canPop;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: WillPopScope(
        onWillPop: _preventPop,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: SizedBox(
              height: _kBarHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_position != null)
                    AnimatedPositioned(
                      duration: _transitionDuration,
                      curve: Curves.easeInOutSine,
                      left: _position!,
                      width: _kBallWidth,
                      height: _kBarHeight,
                      child: const _IndicatorBall(),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _IconButton(
                        key: _item1,
                        icon: Icons.water_damage_outlined,
                        isSelected: widget.currentPage == 0,
                        onPressed: () => _move(_item1, 0),
                      ),
                      _IconButton(
                        key: _item2,
                        icon: Icons.bar_chart_rounded,
                        isSelected: widget.currentPage == 1,
                        onPressed: () => _move(_item2, 1),
                      ),
                      _IconButton(
                        key: _item3,
                        icon: Icons.settings_outlined,
                        isSelected: widget.currentPage == 2,
                        onPressed: () => _move(_item3, 2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IndicatorBall extends StatelessWidget {
  const _IndicatorBall();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onPressed;

  const _IconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).bottomNavigationBarTheme;
    return TweenAnimationBuilder<Color?>(
      duration: _transitionDuration,
      tween: ColorTween(
        begin: theme.unselectedItemColor,
        end: isSelected ? theme.selectedItemColor : theme.unselectedItemColor,
      ),
      builder: (context, color, child) {
        return GestureDetector(
          onTap: onPressed,
          behavior: HitTestBehavior.translucent,
          child: SizedBox(
            height: _kBarHeight,
            width: _kItemWidth,
            child: Icon(
              icon,
              size: 32,
              color: color,
            ),
          ),
        );
      },
    );
  }
}
