import 'dart:math';
import 'package:flutter/material.dart';
import '../models/card_model.dart';

/// Renders a cheese card.
/// [showFront] = true  → front face (trap or cheese art is revealed)
/// [showFront] = false → back face  (hole count visible)
/// [isSelectable] / [onTap] → tappable highlight
class CheeseCardWidget extends StatefulWidget {
  const CheeseCardWidget({
    super.key,
    required this.card,
    this.showFront = false,
    this.isSelectable = false,
    this.isHighlighted = false,
    this.isPeeking = false,
    this.onTap,
    this.width = 72,
    this.height = 104,
  });

  final CheeseCard card;
  final bool showFront;
  final bool isSelectable;
  final bool isHighlighted;
  final bool isPeeking; // animate flip to front then back
  final VoidCallback? onTap;
  final double width;
  final double height;

  @override
  State<CheeseCardWidget> createState() => _CheeseCardWidgetState();
}

class _CheeseCardWidgetState extends State<CheeseCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _angle;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _angle = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.showFront) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(CheeseCardWidget old) {
    super.didUpdateWidget(old);
    if (widget.showFront != old.showFront) {
      if (widget.showFront) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isSelectable ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _angle,
        builder: (_, __) {
          final a = _angle.value;
          final isFront = a > pi / 2;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(isFront ? pi - a : a);

          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.isHighlighted
                      ? Colors.orange.shade700
                      : widget.isSelectable
                          ? Colors.white70
                          : Colors.brown.shade400,
                  width: widget.isHighlighted ? 3 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isHighlighted
                        ? Colors.orange.withValues(alpha: 0.6)
                        : Colors.black26,
                    blurRadius: widget.isHighlighted ? 12 : 4,
                    offset: const Offset(2, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.5),
                child: isFront
                    ? _FrontFace(card: widget.card)
                    : _BackFace(card: widget.card),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Back face: yellow with cheese holes ──────────────────────────────────────

class _BackFace extends StatelessWidget {
  const _BackFace({required this.card});
  final CheeseCard card;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFD54F),
      child: CustomPaint(
        painter: _BackPainter(holeCount: card.holeCount),
        child: Center(
          child: Text(
            '${card.holeCount}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D3A00),
            ),
          ),
        ),
      ),
    );
  }
}

class _BackPainter extends CustomPainter {
  const _BackPainter({required this.holeCount});
  final int holeCount;

  @override
  void paint(Canvas canvas, Size size) {
    final holePaint = Paint()..color = const Color(0xFF8D6015);
    final shadowPaint = Paint()..color = const Color(0xFF5D3A00).withValues(alpha: 0.4);

    // Swiss cheese texture: background bubbles
    final bgPaint = Paint()..color = const Color(0xFFFFCA28);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw holes in a 2×3 or 3×2 grid based on count
    final positions = _holePositions(size, holeCount);
    for (final pos in positions) {
      // shadow
      canvas.drawCircle(Offset(pos.dx + 1, pos.dy + 1), 7, shadowPaint);
      // hole
      canvas.drawCircle(pos, 7, holePaint);
    }
  }

  List<Offset> _holePositions(Size size, int count) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    switch (count) {
      case 1:
        return [Offset(cx, cy)];
      case 2:
        return [Offset(cx, cy - 14), Offset(cx, cy + 14)];
      case 3:
        return [
          Offset(cx, cy - 18),
          Offset(cx - 14, cy + 10),
          Offset(cx + 14, cy + 10),
        ];
      case 4:
        return [
          Offset(cx - 14, cy - 14),
          Offset(cx + 14, cy - 14),
          Offset(cx - 14, cy + 14),
          Offset(cx + 14, cy + 14),
        ];
      case 5:
        return [
          Offset(cx - 14, cy - 18),
          Offset(cx + 14, cy - 18),
          Offset(cx, cy),
          Offset(cx - 14, cy + 18),
          Offset(cx + 14, cy + 18),
        ];
      case 6:
        return [
          Offset(cx - 14, cy - 20),
          Offset(cx + 14, cy - 20),
          Offset(cx - 14, cy),
          Offset(cx + 14, cy),
          Offset(cx - 14, cy + 20),
          Offset(cx + 14, cy + 20),
        ];
      default:
        return [];
    }
  }

  @override
  bool shouldRepaint(_BackPainter old) => old.holeCount != holeCount;
}

// ── Front face: trap or cheese ───────────────────────────────────────────────

class _FrontFace extends StatelessWidget {
  const _FrontFace({required this.card});
  final CheeseCard card;

  @override
  Widget build(BuildContext context) {
    return card.isTrap ? const _TrapFace() : const _CheeseFace();
  }
}

class _CheeseFace extends StatelessWidget {
  const _CheeseFace();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF9FBE7), Color(0xFFDCEDC8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🐭', style: TextStyle(fontSize: 26)),
          SizedBox(height: 2),
          Text('🧀', style: TextStyle(fontSize: 22)),
          SizedBox(height: 4),
          Text(
            'SAFE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrapFace extends StatelessWidget {
  const _TrapFace();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFEEEE), Color(0xFFFFCDD2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🪤', style: TextStyle(fontSize: 30)),
          SizedBox(height: 4),
          Text(
            'TRAP!',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFFC62828),
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// A face-down placeholder (no card data needed) for spare pantry slots or
/// deck representation.
class FaceDownCardWidget extends StatelessWidget {
  const FaceDownCardWidget({
    super.key,
    this.width = 72,
    this.height = 104,
    this.opacity = 1.0,
  });

  final double width;
  final double height;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.brown.shade400, width: 1.5),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD54F), Color(0xFFFFC107)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 3)),
          ],
        ),
        child: const Center(
          child: Text('🧀', style: TextStyle(fontSize: 28)),
        ),
      ),
    );
  }
}
