import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DiceWidget extends StatefulWidget {
  const DiceWidget({
    super.key,
    required this.value,
    required this.isRolling,
    this.onTap,
    this.enabled = true,
  });

  final int? value;
  final bool isRolling;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  State<DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends State<DiceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinCtrl;

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void didUpdateWidget(DiceWidget old) {
    super.didUpdateWidget(old);
    if (widget.isRolling && !old.isRolling) {
      _spinCtrl.repeat();
    } else if (!widget.isRolling && old.isRolling) {
      _spinCtrl.stop();
      _spinCtrl.value = 0;
    }
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _spinCtrl,
        builder: (_, child) {
          final angle = widget.isRolling ? _spinCtrl.value * 2 * pi : 0.0;
          return Transform.rotate(
            angle: angle,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.enabled
                  ? Colors.brown.shade500
                  : Colors.brown.shade200,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withValues(alpha: widget.enabled ? 0.4 : 0.15),
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: widget.isRolling
              ? const Center(
                  child: Text('🎲', style: TextStyle(fontSize: 30)))
              : widget.value == null
                  ? Center(
                      child: Text(
                        'Roll!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: widget.enabled
                              ? Colors.brown.shade700
                              : Colors.brown.shade300,
                        ),
                      ),
                    )
                  : CustomPaint(
                      painter: _DiceFacePainter(value: widget.value!),
                    ),
        ),
      )
          .animate(target: widget.enabled && widget.value == null ? 1 : 0)
          .shimmer(
            duration: 1500.ms,
            color: Colors.orange.withValues(alpha: 0.3),
          ),
    );
  }
}

class _DiceFacePainter extends CustomPainter {
  const _DiceFacePainter({required this.value});
  final int value;

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = const Color(0xFF3E2723);

    final cx = size.width / 2;
    final cy = size.height / 2;
    const r = 5.5;
    const sp = 16.0; // spacing

    final dots = _dotPositions(cx, cy, sp);
    for (final dot in dots[value - 1]) {
      canvas.drawCircle(dot, r, dotPaint);
    }
  }

  List<List<Offset>> _dotPositions(double cx, double cy, double sp) => [
        // 1
        [Offset(cx, cy)],
        // 2
        [Offset(cx - sp, cy - sp), Offset(cx + sp, cy + sp)],
        // 3
        [Offset(cx - sp, cy - sp), Offset(cx, cy), Offset(cx + sp, cy + sp)],
        // 4
        [
          Offset(cx - sp, cy - sp),
          Offset(cx + sp, cy - sp),
          Offset(cx - sp, cy + sp),
          Offset(cx + sp, cy + sp),
        ],
        // 5
        [
          Offset(cx - sp, cy - sp),
          Offset(cx + sp, cy - sp),
          Offset(cx, cy),
          Offset(cx - sp, cy + sp),
          Offset(cx + sp, cy + sp),
        ],
        // 6
        [
          Offset(cx - sp, cy - sp),
          Offset(cx + sp, cy - sp),
          Offset(cx - sp, cy),
          Offset(cx + sp, cy),
          Offset(cx - sp, cy + sp),
          Offset(cx + sp, cy + sp),
        ],
      ];

  @override
  bool shouldRepaint(_DiceFacePainter old) => old.value != value;
}
